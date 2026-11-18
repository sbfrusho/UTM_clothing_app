/**
 * Your Shop server side (Firebase Functions v2).
 *
 *  - createPaymentIntent  HTTPS: Stripe PaymentIntent for a stored order,
 *                         amount computed here from live product prices.
 *  - stripeWebhook        HTTPS: marks orders paid; refunds payments that
 *                         arrive for orders already released.
 *  - expireUnpaidOrders   every 10 min: releases card orders left unpaid
 *                         past the payment window and puts stock back.
 *  - onOrderWritten       Firestore: keeps statusHistory, queues order
 *                         emails (`mail`, Trigger Email extension) and sends
 *                         push notifications to the customer's devices.
 *  - placeOrder           HTTPS: creates an order from the cart with live
 *                         prices, reserves stock, empties the cart.
 *  - cancelOrder          HTTPS: customer cancellation with restock and,
 *                         for Stripe-paid orders, a refund.
 *  - deleteAccount        HTTPS: deletes the caller's profile, cart,
 *                         wishlist, addresses, avatar and Auth account.
 *                         Orders are kept (anonymised) for accounting.
 *
 * With `firestore.rules` deployed, these are the only way stock, orders and
 * payment state change for customers.
 *
 * Secrets: `firebase functions:secrets:set STRIPE_SECRET_KEY` and
 * `STRIPE_WEBHOOK_SECRET`. See docs/BACKEND.md.
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getMessaging } from "firebase-admin/messaging";
import { getStorage } from "firebase-admin/storage";
import {
  FieldValue,
  getFirestore,
  Timestamp,
  type DocumentReference,
  type Transaction,
} from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineSecret, defineString } from "firebase-functions/params";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onRequest, type Request } from "firebase-functions/v2/https";
import type { Response } from "express";
import { onSchedule } from "firebase-functions/v2/scheduler";
import Stripe from "stripe";

import {
  cancelDecision,
  deletionBlocker,
  isRecentLogin,
  canPay,
  cartKey,
  checkStock,
  livePrice,
  parseLines,
  computeTotal,
  isExpired,
  OrderStatus,
  PaymentStatus,
  restockPlan,
  sameAmount,
  toLine,
  toMinorUnits,
  toNumber,
  type OrderLine,
} from "./rules";

initializeApp();
const db = getFirestore();

const REGION = "asia-southeast1";
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");
const CURRENCY = defineString("CURRENCY", { default: "bdt" });
const SHOP_NAME = defineString("SHOP_NAME", { default: "Your Shop" });

// API version is pinned by the installed stripe SDK.
const stripe = () => new Stripe(STRIPE_SECRET_KEY.value());

const orders = () => db.collection("orders");
const products = () => db.collection("products");

/** Verifies the Firebase ID token; responds 401 and returns null if bad. */
async function callerOf(req: Request, res: Response) {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Use POST." });
    return null;
  }
  const token = (req.header("Authorization") ?? "").replace(/^Bearer /, "");
  try {
    return await getAuth().verifyIdToken(token);
  } catch {
    res.status(401).json({ error: "Please sign in again." });
    return null;
  }
}

async function orderLines(orderId: string): Promise<OrderLine[]> {
  const items = await orders().doc(orderId).collection("items").get();
  return items.docs.map((d) => toLine(d.data()));
}

// ---------------------------------------------------------------------------
// Payments
// ---------------------------------------------------------------------------

export const createPaymentIntent = onRequest(
  { region: REGION, secrets: [STRIPE_SECRET_KEY], cors: false },
  async (req, res) => {
    const caller = await callerOf(req, res);
    if (!caller) return;
    const uid = caller.uid;

    const orderId = String(req.body?.orderId ?? "");
    const orderRef = orders().doc(orderId);
    const snap = orderId ? await orderRef.get() : null;
    const order = snap?.data();
    if (!order) {
      res.status(404).json({ error: "Order not found." });
      return;
    }
    const check = canPay(order, uid);
    if (!check.ok) {
      res.status(check.status).json({ error: check.error });
      return;
    }

    // Charge what the products cost now, and only if it matches the order.
    const lines = await orderLines(orderId);
    const docs = await db.getAll(...lines.map((l) => products().doc(l.productId)));
    const byId = new Map(docs.map((d) => [d.id, d.data()]));
    const total = computeTotal(lines, byId);
    if (total === null || !sameAmount(total, toNumber(order.totalPrice))) {
      res.status(409).json({
        error: "Prices changed since you ordered. Please cancel and order again.",
      });
      return;
    }

    const amount = toMinorUnits(total);
    const currency = CURRENCY.value();
    const s = stripe();

    // Reuse an open intent so retries don't create duplicates.
    let intent: Stripe.PaymentIntent | null = null;
    if (typeof order.paymentIntentId === "string") {
      const existing = await s.paymentIntents.retrieve(order.paymentIntentId);
      if (
        existing.amount === amount &&
        ["requires_payment_method", "requires_confirmation", "requires_action"]
          .includes(existing.status)
      ) {
        intent = existing;
      }
    }
    intent ??= await s.paymentIntents.create(
      {
        amount,
        currency,
        automatic_payment_methods: { enabled: true },
        metadata: { orderId, uid },
        description: `${SHOP_NAME.value()} order ${orderId.slice(0, 6).toUpperCase()}`,
      },
      { idempotencyKey: `order-${orderId}-${amount}` },
    );
    await orderRef.update({ paymentIntentId: intent.id });

    res.json({
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
      amount,
      currency,
    });
  },
);

export const stripeWebhook = onRequest(
  { region: REGION, secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET] },
  async (req, res) => {
    let event: Stripe.Event;
    try {
      event = stripe().webhooks.constructEvent(
        req.rawBody,
        req.header("stripe-signature") ?? "",
        STRIPE_WEBHOOK_SECRET.value(),
      );
    } catch (e) {
      logger.warn("Rejected webhook with a bad signature", e);
      res.status(400).send("Bad signature");
      return;
    }

    if (event.type === "payment_intent.succeeded") {
      const intent = event.data.object;
      const orderId = intent.metadata?.orderId;
      if (orderId) await settlePaidOrder(orderId, intent);
    } else if (event.type === "payment_intent.payment_failed") {
      logger.info("Payment failed", event.data.object.id);
    }
    res.json({ received: true });
  },
);

async function settlePaidOrder(orderId: string, intent: Stripe.PaymentIntent) {
  const ref = orders().doc(orderId);
  const outcome = await db.runTransaction(async (tx) => {
    const order = (await tx.get(ref)).data();
    if (!order) return "missing";
    if (order.paymentStatus === PaymentStatus.paid) return "duplicate";
    if (order.status === OrderStatus.cancelled) return "refund";
    tx.update(ref, {
      paymentStatus: PaymentStatus.paid,
      paymentReference: intent.id,
      paidAt: FieldValue.serverTimestamp(),
    });
    return "paid";
  });
  if (outcome === "refund") {
    // Paid after the order was released: give the money back.
    await stripe().refunds.create(
      { payment_intent: intent.id },
      { idempotencyKey: `refund-${intent.id}` },
    );
    await ref.update({
      paymentStatus: PaymentStatus.refunded,
      paymentReference: intent.id,
    });
    logger.info(`Refunded late payment for released order ${orderId}`);
  }
}

// ---------------------------------------------------------------------------
// Expiry
// ---------------------------------------------------------------------------

/** Cancels the order and puts its stock back inside [tx]. */
async function releaseOrder(
  tx: Transaction,
  ref: DocumentReference,
  lines: OrderLine[],
  by: string,
) {
  const plan = restockPlan(lines);
  const productRefs = [...plan.keys()].map((id) => products().doc(id));
  const productSnaps = productRefs.length ? await tx.getAll(...productRefs) : [];
  for (const p of productSnaps) {
    if (!p.exists) continue;
    const stock = toNumber(p.data()?.quantity);
    // Stock is stored as a string by the admin app.
    tx.update(p.ref, { quantity: String(stock + (plan.get(p.id) ?? 0)) });
  }
  tx.update(ref, {
    status: OrderStatus.cancelled,
    paymentStatus: PaymentStatus.voided,
    cancelledBy: by,
    [`statusHistory.${OrderStatus.cancelled}`]: FieldValue.serverTimestamp(),
  });
}

export const expireUnpaidOrders = onSchedule(
  { region: REGION, schedule: "every 10 minutes", secrets: [STRIPE_SECRET_KEY] },
  async () => {
    const now = new Date();
    const stale = await orders()
      .where("paymentStatus", "==", PaymentStatus.awaitingPayment)
      .get();
    for (const doc of stale.docs) {
      const createdAt = (doc.get("createdAt") as Timestamp | undefined)?.toDate() ?? null;
      if (!isExpired(createdAt, now)) continue;
      const lines = await orderLines(doc.id);
      const released = await db.runTransaction(async (tx) => {
        const fresh = await tx.get(doc.ref);
        if (fresh.get("paymentStatus") !== PaymentStatus.awaitingPayment) {
          return false; // paid or cancelled meanwhile
        }
        await releaseOrder(tx, doc.ref, lines, "system");
        return true;
      });
      const intentId = doc.get("paymentIntentId");
      if (released && typeof intentId === "string") {
        try {
          await stripe().paymentIntents.cancel(intentId);
        } catch (e) {
          logger.warn(`Could not cancel intent ${intentId}`, e);
        }
      }
      if (released) logger.info(`Released unpaid order ${doc.id}`);
    }
  },
);

// ---------------------------------------------------------------------------
// Orders
// ---------------------------------------------------------------------------

class HttpError extends Error {
  constructor(readonly status: number, message: string) {
    super(message);
  }
}

export const placeOrder = onRequest(
  { region: REGION },
  async (req, res) => {
    const caller = await callerOf(req, res);
    if (!caller) return;
    const uid = caller.uid;
    if (!caller.email_verified && caller.firebase.sign_in_provider === "password") {
      res.status(403).json({ error: "Please verify your email first." });
      return;
    }

    const lines = parseLines(req.body?.items);
    if (typeof lines === "string") {
      res.status(400).json({ error: lines });
      return;
    }
    const b = req.body ?? {};
    const isCard = b.paymentMethod === "card";
    const address = (b.address ?? {}) as Record<string, unknown>;
    const name = String(address.fullName ?? "").trim();
    const phone = String(address.phone ?? "").trim();
    const formatted = String(address.formatted ?? "").trim();
    if (!name || !phone || !formatted) {
      res.status(400).json({ error: "Add a delivery address." });
      return;
    }

    try {
      const result = await db.runTransaction(async (tx) => {
        const productRefs = [...new Set(lines.map((l) => l.productId))]
          .map((id) => products().doc(id));
        const [userSnap, ...productSnaps] = await tx.getAll(
          db.collection("users").doc(uid),
          ...productRefs,
        );
        const byId = new Map(productSnaps.map((p) => [p.id, p.data()]));
        const stock = checkStock(lines, byId);
        if (!stock.ok) throw new HttpError(409, stock.error);

        // Live prices; the client total is only compared, never stored.
        const clientTotal = toNumber(b.expectedTotal);
        let total = 0;
        const orderRef = orders().doc();
        for (const l of lines) {
          const p = byId.get(l.productId)!;
          const price = livePrice(p);
          total += price * l.quantity;
          tx.set(orderRef.collection("items").doc(), {
            product_id: l.productId,
            product_name: String(p.productName ?? ""),
            price: String(price),
            quantity: l.quantity,
            size: l.size,
            product_image: Array.isArray(p.productImages) ? String(p.productImages[0] ?? "") : "",
          });
        }
        total = Math.round(total * 100) / 100;
        if (clientTotal > 0 && !sameAmount(total, clientTotal)) {
          throw new HttpError(409, "Prices changed. Please review your cart.");
        }

        for (const [id, qty] of restockPlan(lines)) {
          const current = Math.trunc(toNumber(byId.get(id)!.quantity));
          tx.update(products().doc(id), { quantity: String(current - qty) });
        }

        const sellers = [...new Set(productSnaps
          .map((p) => String(p.get("email") ?? ""))
          .filter((e) => e))];
        tx.set(orderRef, {
          customerId: uid,
          uniqueId: caller.email ?? "",
          customerName: name,
          customerPhone: phone,
          customerAddress: formatted,
          customerDeviceToken: String(userSnap.get("deviceToken") ?? ""),
          paymentMethod: isCard ? "Card" : "Cash on Delivery",
          paymentStatus: isCard ? PaymentStatus.awaitingPayment : PaymentStatus.unpaid,
          paymentGateway: isCard ? "stripe" : "cod",
          paymentReference: null,
          deliveryTime: String(b.deliveryDate ?? ""),
          deliveryType: String(b.deliveryType ?? ""),
          totalPrice: total,
          status: OrderStatus.pending,
          statusHistory: { [OrderStatus.pending]: FieldValue.serverTimestamp() },
          sellerId: sellers[0] ?? "",
          sellerIds: sellers,
          createdAt: FieldValue.serverTimestamp(),
          source: "server",
        });

        const cart = db.collection("users").doc(uid).collection("cart");
        for (const l of lines) tx.delete(cart.doc(cartKey(l.productId, l.size)));
        return { orderId: orderRef.id, total };
      });
      res.json(result);
    } catch (e) {
      if (e instanceof HttpError) {
        res.status(e.status).json({ error: e.message });
      } else {
        logger.error("placeOrder failed", e);
        res.status(500).json({ error: "Could not place the order. Please try again." });
      }
    }
  },
);

export const cancelOrder = onRequest(
  { region: REGION, secrets: [STRIPE_SECRET_KEY] },
  async (req, res) => {
    const caller = await callerOf(req, res);
    if (!caller) return;
    const orderId = String(req.body?.orderId ?? "");
    const ref = orders().doc(orderId);
    const lines = orderId ? await orderLines(orderId) : [];

    try {
      const refundIntent = await db.runTransaction(async (tx) => {
        const order = (await tx.get(ref)).data();
        if (!order) throw new HttpError(404, "Order not found.");
        const decision = cancelDecision(order, caller.uid);
        if (!decision.ok) throw new HttpError(decision.status, decision.error);
        await releaseOrder(tx, ref, lines, "customer");
        if (decision.refund) {
          tx.update(ref, { paymentStatus: PaymentStatus.refunded });
          return String(order.paymentReference ?? order.paymentIntentId ?? "");
        }
        return null;
      });
      if (refundIntent) {
        await stripe().refunds.create(
          { payment_intent: refundIntent },
          { idempotencyKey: `refund-${refundIntent}` },
        );
      } else {
        // Cancel an open intent so a late payment can't happen.
        const snap = await ref.get();
        const intentId = snap.get("paymentIntentId");
        if (typeof intentId === "string" && snap.get("paymentStatus") === PaymentStatus.voided) {
          await stripe().paymentIntents.cancel(intentId).catch(() => undefined);
        }
      }
      res.json({ cancelled: true, refunded: Boolean(refundIntent) });
    } catch (e) {
      if (e instanceof HttpError) {
        res.status(e.status).json({ error: e.message });
      } else {
        logger.error("cancelOrder failed", e);
        res.status(500).json({ error: "Could not cancel the order. Please try again." });
      }
    }
  },
);

// ---------------------------------------------------------------------------
// Account deletion (Google Play requires it in the app)
// ---------------------------------------------------------------------------

export const deleteAccount = onRequest(
  { region: REGION },
  async (req, res) => {
    const caller = await callerOf(req, res);
    if (!caller) return;
    if (!isRecentLogin(caller.auth_time, new Date())) {
      res.status(401).json({ error: "Please sign in again to delete your account." });
      return;
    }
    const uid = caller.uid;
    try {
      const own = await orders().where("customerId", "==", uid).get();
      const blocker = deletionBlocker(own.docs.map((d) => d.get("status")));
      if (blocker) {
        res.status(409).json({ error: blocker });
        return;
      }

      // Orders stay for tax records, without personal details.
      const writer = db.bulkWriter();
      for (const order of own.docs) {
        writer.update(order.ref, {
          customerDeleted: true,
          customerName: "Deleted user",
          customerEmail: FieldValue.delete(),
          customerPhone: FieldValue.delete(),
          customerAddress: FieldValue.delete(),
          customerDeviceToken: FieldValue.delete(),
        });
      }
      const email = caller.email;
      if (email) {
        writer.delete(db.collection("wishlist").doc(email));
        const legacy = await db.collection("addresses").where("email", "==", email).get();
        legacy.docs.forEach((d) => writer.delete(d.ref));
      }
      await writer.close();

      // Profile plus cart, wishlist and addresses subcollections.
      await db.recursiveDelete(db.collection("users").doc(uid));
      await getStorage()
        .bucket()
        .deleteFiles({ prefix: `users/${uid}/` })
        .catch((e) => logger.warn("avatar cleanup failed", e));
      await getAuth().deleteUser(uid);
      res.json({ deleted: true });
    } catch (e) {
      logger.error("deleteAccount failed", e);
      res.status(500).json({ error: "Could not delete your account. Please try again." });
    }
  },
);

// ---------------------------------------------------------------------------
// History, email and push
// ---------------------------------------------------------------------------

export const onOrderWritten = onDocumentWritten(
  { region: REGION, document: "orders/{orderId}" },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after) return;
    const ref = event.data!.after.ref;
    const status = String(after.status ?? OrderStatus.pending);

    // Admin-app status changes: record when they happened.
    const history = (after.statusHistory ?? {}) as Record<string, unknown>;
    if (before?.status !== status && !history[status]) {
      await ref.update({
        [`statusHistory.${status}`]: FieldValue.serverTimestamp(),
      });
    }

    const shortId = event.params.orderId.slice(0, 6).toUpperCase();
    if (before && before.status !== status) {
      await notifyCustomer(String(after.customerId ?? ""), {
        title: `Order #${shortId} ${status.toLowerCase()}`,
        body: statusMessage(status),
        orderId: event.params.orderId,
      });
    }

    const to = String(after.uniqueId ?? "");
    if (!to) return;
    const shop = SHOP_NAME.value();
    let subject: string | null = null;
    let text = "";
    if (!before) {
      subject = `${shop}: order #${shortId} received`;
      text = `Thanks for your order #${shortId}. Total ${toNumber(after.totalPrice).toFixed(2)}. ` +
        "We'll let you know when it ships.";
    } else if (before.paymentStatus !== after.paymentStatus &&
        after.paymentStatus === PaymentStatus.paid) {
      subject = `${shop}: payment received for #${shortId}`;
      text = `We received your payment for order #${shortId}.`;
    } else if (before.status !== status && status !== OrderStatus.pending) {
      subject = `${shop}: order #${shortId} is ${status.toLowerCase()}`;
      text = `Your order #${shortId} is now ${status.toLowerCase()}.`;
    }
    if (subject) {
      // Picked up by the Firebase "Trigger Email from Firestore" extension.
      await db.collection("mail").add({
        to,
        message: { subject, text },
        orderId: event.params.orderId,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  },
);

function statusMessage(status: string): string {
  switch (status) {
    case OrderStatus.confirmed: return "The shop confirmed your order.";
    case OrderStatus.shipped: return "Your order is on the way.";
    case OrderStatus.delivered: return "Your order was delivered. Enjoy!";
    case OrderStatus.cancelled: return "Your order was cancelled.";
    default: return `Your order is now ${status.toLowerCase()}.`;
  }
}

/** Sends to every device the customer is signed in on; prunes dead tokens. */
async function notifyCustomer(
  uid: string,
  msg: { title: string; body: string; orderId: string },
) {
  if (!uid) return;
  const userRef = db.collection("users").doc(uid);
  const user = (await userRef.get()).data() ?? {};
  const tokens = [...new Set([
    ...((user.fcmTokens as string[] | undefined) ?? []),
    String(user.deviceToken ?? ""),
  ].filter((t) => t))];
  if (tokens.length === 0) return;

  const result = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title: msg.title, body: msg.body },
    data: { type: "order", orderId: msg.orderId },
    android: { priority: "high", notification: { channelId: "orders" } },
  });
  const dead = result.responses
    .map((r, i) => (r.error?.code === "messaging/registration-token-not-registered" ||
      r.error?.code === "messaging/invalid-registration-token" ? tokens[i] : null))
    .filter((t): t is string => t !== null);
  if (dead.length) {
    await userRef.update({ fcmTokens: FieldValue.arrayRemove(...dead) });
  }
}
