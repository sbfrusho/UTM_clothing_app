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
