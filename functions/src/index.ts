/**
 * Your Shop server side (Firebase Functions v2).
 *
 *  - createPaymentIntent  HTTPS: Stripe PaymentIntent for a stored order,
 *                         amount computed here from live product prices.
 *  - stripeWebhook        HTTPS: marks orders paid; refunds payments that
 *                         arrive for orders already released.
 *  - expireUnpaidOrders   every 10 min: releases card orders left unpaid
 *                         past the payment window and puts stock back.
 *  - onOrderWritten       Firestore: keeps statusHistory and queues order
 *                         emails for the "Trigger Email" extension (`mail`).
 *
 * Secrets: `firebase functions:secrets:set STRIPE_SECRET_KEY` and
 * `STRIPE_WEBHOOK_SECRET`. See docs/BACKEND.md.
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
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
import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import Stripe from "stripe";

import {
  canPay,
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
const CURRENCY = defineString("CURRENCY", { default: "myr" });
const SHOP_NAME = defineString("SHOP_NAME", { default: "Your Shop" });

// API version is pinned by the installed stripe SDK.
const stripe = () => new Stripe(STRIPE_SECRET_KEY.value());

const orders = () => db.collection("orders");
const products = () => db.collection("products");

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
    if (req.method !== "POST") {
      res.status(405).json({ error: "Use POST." });
      return;
    }
    const token = (req.header("Authorization") ?? "").replace(/^Bearer /, "");
    let uid: string;
    try {
      uid = (await getAuth().verifyIdToken(token)).uid;
    } catch {
      res.status(401).json({ error: "Please sign in again." });
      return;
    }

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
// History and email
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

    const to = String(after.uniqueId ?? "");
    if (!to) return;
    const shortId = event.params.orderId.slice(0, 6).toUpperCase();
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
