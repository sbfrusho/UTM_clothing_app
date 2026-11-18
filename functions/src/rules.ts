/**
 * Pure order and payment rules, shared by the functions and unit tested
 * without Firebase. Field names match the app and the admin app.
 */

export const PaymentStatus = {
  unpaid: "unpaid",
  awaitingPayment: "awaiting_payment",
  paid: "paid",
  refunded: "refunded",
  voided: "void",
} as const;

export const OrderStatus = {
  pending: "Pending",
  confirmed: "Confirmed",
  shipped: "Shipped",
  delivered: "Delivered",
  cancelled: "Cancelled",
} as const;

/** Card orders reserve stock this long before they are released. */
export const PAYMENT_WINDOW_MS = 30 * 60 * 1000;

/** The admin app stores numbers as strings ("12.50"). */
export function toNumber(value: unknown): number {
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const n = Number.parseFloat(value.trim());
    return Number.isFinite(n) ? n : 0;
  }
  return 0;
}

/** Price the customer pays: sale price when set, else full price. */
export function livePrice(product: Record<string, unknown>): number {
  const sale = toNumber(product.salePrice);
  return sale > 0 ? sale : toNumber(product.fullPrice);
}

/**
 * Major units → integer minor units (sen, cents), rounding half up.
 * `toFixed(6)` first absorbs float noise (1.005 * 100 = 100.4999…).
 * Must match `toMinorUnits` in the app (lib/core/utils/money.dart).
 */
export function toMinorUnits(amount: number): number {
  return Math.round(Number((amount * 100).toFixed(6)));
}

export interface OrderLine {
  productId: string;
  quantity: number;
}

/** Reads `orders/{id}/items` documents (legacy field names). */
export function toLine(item: Record<string, unknown>): OrderLine {
  return {
    productId: String(item.product_id ?? ""),
    quantity: Math.max(1, Math.trunc(toNumber(item.quantity))),
  };
}

/**
 * Server-side total from live product prices. Never trust the total the
 * client wrote. Returns null when a product no longer exists.
 */
export function computeTotal(
  lines: OrderLine[],
  products: Map<string, Record<string, unknown> | undefined>,
): number | null {
  let total = 0;
  for (const line of lines) {
    const p = products.get(line.productId);
    if (!p) return null;
    total += livePrice(p) * line.quantity;
  }
  return Math.round(total * 100) / 100;
}

/** Units to put back per product (sizes share one stock counter). */
export function restockPlan(lines: OrderLine[]): Map<string, number> {
  const plan = new Map<string, number>();
  for (const l of lines) {
    plan.set(l.productId, (plan.get(l.productId) ?? 0) + l.quantity);
  }
  return plan;
}

export function isExpired(createdAt: Date | null, now: Date): boolean {
  return createdAt !== null &&
    now.getTime() - createdAt.getTime() >= PAYMENT_WINDOW_MS;
}

export type PayCheck =
  | { ok: true }
  | { ok: false; status: number; error: string };

/** Whether [uid] may pay for this order now. */
export function canPay(order: Record<string, unknown>, uid: string): PayCheck {
  if (order.customerId !== uid) {
    return { ok: false, status: 403, error: "This is not your order." };
  }
  if (order.status === OrderStatus.cancelled) {
    return { ok: false, status: 409, error: "This order was cancelled." };
  }
  if (order.paymentStatus === PaymentStatus.paid) {
    return { ok: false, status: 409, error: "This order is already paid." };
  }
  if (order.paymentStatus !== PaymentStatus.awaitingPayment) {
    return { ok: false, status: 409, error: "This order is not awaiting payment." };
  }
  if (order.paymentGateway !== "stripe") {
    return { ok: false, status: 409, error: "This order uses another payment method." };
  }
  return { ok: true };
}

export function sameAmount(a: number, b: number): boolean {
  return Math.abs(a - b) < 0.005;
}

// ---------------------------------------------------------------------------
// Order creation and cancellation
// ---------------------------------------------------------------------------

export interface RequestedLine {
  productId: string;
  size: string;
  quantity: number;
}

/** Validates the checkout request body. Returns an error message or lines. */
export function parseLines(raw: unknown): RequestedLine[] | string {
  if (!Array.isArray(raw) || raw.length === 0) return "Your cart is empty.";
  if (raw.length > 50) return "Too many items in one order.";
  const lines: RequestedLine[] = [];
  for (const r of raw) {
    const productId = String((r as Record<string, unknown>)?.productId ?? "");
    const size = String((r as Record<string, unknown>)?.size ?? "");
    const quantity = Math.trunc(toNumber((r as Record<string, unknown>)?.quantity));
    if (!productId || quantity < 1 || quantity > 99) return "Invalid cart item.";
    lines.push({ productId, size, quantity });
  }
  return lines;
}

/** Same key as the app's `CartItemModel.keyFor`. */
export function cartKey(productId: string, size: string): string {
  return `${productId}__${encodeURIComponent(size)}`;
}

export type StockCheck = { ok: true } | { ok: false; error: string };

/** Every product exists, is not oversold (sizes share stock). */
export function checkStock(
  lines: RequestedLine[],
  products: Map<string, Record<string, unknown> | undefined>,
): StockCheck {
  const needed = restockPlan(lines);
  for (const [id, qty] of needed) {
    const p = products.get(id);
    if (!p) return { ok: false, error: "An item in your cart is no longer available." };
    const stock = Math.trunc(toNumber(p.quantity));
    const name = String(p.productName ?? "An item");
    if (stock < qty) {
      return {
        ok: false,
        error: stock <= 0 ? `"${name}" is out of stock.` : `Only ${stock} of "${name}" left in stock.`,
      };
    }
  }
  return { ok: true };
}

/**
 * Customers may cancel while the order is Pending. Card payments taken by
 * Stripe are refunded by the server; nothing else may be cancelled.
 */
export function cancelDecision(
  order: Record<string, unknown>,
  uid: string,
): { ok: true; refund: boolean } | { ok: false; status: number; error: string } {
  if (order.customerId !== uid) {
    return { ok: false, status: 403, error: "You can only cancel your own orders." };
  }
  if (order.status !== OrderStatus.pending) {
    return { ok: false, status: 409, error: "This order can no longer be cancelled." };
  }
  const paid = order.paymentStatus === PaymentStatus.paid;
  return { ok: true, refund: paid && order.paymentGateway === "stripe" };
}

/** Account deletion needs a sign-in this recent (Firebase `auth_time`). */
export const RECENT_LOGIN_MS = 5 * 60 * 1000;

export function isRecentLogin(authTimeSeconds: unknown, now: Date): boolean {
  const t = Number(authTimeSeconds);
  return Number.isFinite(t) && now.getTime() - t * 1000 <= RECENT_LOGIN_MS;
}

/**
 * An account can't be deleted while one of its orders is still in progress
 * (someone has to receive, refund or cancel it). Returns the error, or null.
 */
export function deletionBlocker(orderStatuses: unknown[]): string | null {
  const open = orderStatuses.filter(
    (s) => s !== OrderStatus.delivered && s !== OrderStatus.cancelled,
  ).length;
  if (open === 0) return null;
  return open === 1
    ? "You have an order in progress. Cancel it or wait until it is delivered, then try again."
    : `You have ${open} orders in progress. Cancel them or wait until they are delivered, then try again.`;
}
