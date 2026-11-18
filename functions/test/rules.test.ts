import assert from "node:assert/strict";
import { test } from "node:test";

import {
  canPay,
  deletionBlocker,
  isRecentLogin,
  computeTotal,
  isExpired,
  livePrice,
  PAYMENT_WINDOW_MS,
  restockPlan,
  toLine,
  toMinorUnits,
  toNumber,
} from "../src/rules";

test("numbers stored as strings are read", () => {
  assert.equal(toNumber("12.50"), 12.5);
  assert.equal(toNumber(" 7 "), 7);
  assert.equal(toNumber("abc"), 0);
  assert.equal(toNumber(undefined), 0);
});

test("sale price wins when set", () => {
  assert.equal(livePrice({ salePrice: "89", fullPrice: "119" }), 89);
  assert.equal(livePrice({ salePrice: "0", fullPrice: "35" }), 35);
});

test("minor units round correctly", () => {
  assert.equal(toMinorUnits(19.99), 1999);
  assert.equal(toMinorUnits(0.1 + 0.2), 30);
  assert.equal(toMinorUnits(1.005), 101);
});

test("server total uses live prices and rejects missing products", () => {
  const lines = [
    { productId: "a", quantity: 2 },
    { productId: "b", quantity: 1 },
  ];
  const live = new Map<string, Record<string, unknown> | undefined>([
    ["a", { salePrice: "10.25" }],
    ["b", { salePrice: "0", fullPrice: "5" }],
  ]);
  assert.equal(computeTotal(lines, live), 25.5);
  live.delete("b");
  assert.equal(computeTotal(lines, live), null);
});

test("legacy item fields map to lines", () => {
  assert.deepEqual(toLine({ product_id: "p1", quantity: "3" }), {
    productId: "p1",
    quantity: 3,
  });
});

test("restock sums sizes of the same product", () => {
  const plan = restockPlan([
    { productId: "a", quantity: 2 },
    { productId: "a", quantity: 1 },
    { productId: "b", quantity: 4 },
  ]);
  assert.equal(plan.get("a"), 3);
  assert.equal(plan.get("b"), 4);
});

test("expiry after the payment window", () => {
  const now = new Date("2026-11-18T12:00:00Z");
  const fresh = new Date(now.getTime() - PAYMENT_WINDOW_MS + 1000);
  const stale = new Date(now.getTime() - PAYMENT_WINDOW_MS);
  assert.equal(isExpired(fresh, now), false);
  assert.equal(isExpired(stale, now), true);
  assert.equal(isExpired(null, now), false);
});

test("only the owner can pay an awaiting stripe order", () => {
  const order = {
    customerId: "u1",
    status: "Pending",
    paymentStatus: "awaiting_payment",
    paymentGateway: "stripe",
  };
  assert.deepEqual(canPay(order, "u1"), { ok: true });
  assert.equal(canPay(order, "u2").ok, false);
  assert.equal(canPay({ ...order, paymentStatus: "paid" }, "u1").ok, false);
  assert.equal(canPay({ ...order, status: "Cancelled" }, "u1").ok, false);
  assert.equal(canPay({ ...order, paymentGateway: "demo" }, "u1").ok, false);
});

import { cancelDecision, cartKey, checkStock, parseLines } from "../src/rules";

test("checkout lines are validated", () => {
  assert.equal(parseLines([]), "Your cart is empty.");
  assert.equal(parseLines([{ productId: "", quantity: 1 }]), "Invalid cart item.");
  assert.equal(parseLines([{ productId: "a", quantity: 0 }]), "Invalid cart item.");
  assert.deepEqual(parseLines([{ productId: "a", size: "M", quantity: "2" }]), [
    { productId: "a", size: "M", quantity: 2 },
  ]);
});

test("cart keys match the app", () => {
  assert.equal(cartKey("p1", ""), "p1__");
  assert.equal(cartKey("p1", "UK 8/9"), "p1__UK%208%2F9");
});

test("stock is shared across sizes", () => {
  const products = new Map<string, Record<string, unknown> | undefined>([
    ["a", { quantity: "3", productName: "Tee" }],
  ]);
  const lines = [
    { productId: "a", size: "S", quantity: 2 },
    { productId: "a", size: "M", quantity: 2 },
  ];
  const r = checkStock(lines, products);
  assert.equal(r.ok, false);
  assert.match((r as { error: string }).error, /Only 3/);
  assert.equal(checkStock(lines.slice(0, 1), products).ok, true);
  assert.equal(checkStock([{ productId: "x", size: "", quantity: 1 }], products).ok, false);
});

test("cancel rules: owner, pending, refund only for stripe-paid", () => {
  const base = { customerId: "u1", status: "Pending", paymentStatus: "unpaid", paymentGateway: "cod" };
  assert.deepEqual(cancelDecision(base, "u1"), { ok: true, refund: false });
  assert.equal(cancelDecision(base, "u2").ok, false);
  assert.equal(cancelDecision({ ...base, status: "Shipped" }, "u1").ok, false);
  assert.deepEqual(
    cancelDecision({ ...base, paymentStatus: "paid", paymentGateway: "stripe" }, "u1"),
    { ok: true, refund: true },
  );
});

test("account deletion: recent sign-in and no open orders", () => {
  const now = new Date("2026-01-01T00:10:00Z");
  const sec = (iso: string) => Date.parse(iso) / 1000;
  assert.equal(isRecentLogin(sec("2026-01-01T00:06:00Z"), now), true);
  assert.equal(isRecentLogin(sec("2026-01-01T00:04:00Z"), now), false);
  assert.equal(isRecentLogin(undefined, now), false);
  assert.equal(deletionBlocker([]), null);
  assert.equal(deletionBlocker(["Delivered", "Cancelled"]), null);
  assert.match(deletionBlocker(["Delivered", "Shipped"]) ?? "", /an order in progress/);
  assert.match(deletionBlocker(["Pending", "Confirmed"]) ?? "", /2 orders/);
});
