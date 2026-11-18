// Security rules tests. Run: cd test/firestore_rules && npm test
// (starts the Firestore emulator; needs Java 11+).
import { readFileSync } from "node:fs";
import { after, before, beforeEach, describe, test } from "node:test";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";

let env;
const alice = { uid: "alice", email: "alice@example.com" };
const bob = { uid: "bob", email: "bob@example.com" };
const admin = { uid: "admin", email: "admin@shop.com" };

const as = (u) => env.authenticatedContext(u.uid, { email: u.email }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-your-shop",
    firestore: { rules: readFileSync("../../firestore.rules", "utf8") },
  });
});
after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "users/alice"), { uId: "alice", email: alice.email, isAdmin: false });
    await setDoc(doc(db, "users/bob"), { uId: "bob", email: bob.email, isAdmin: false });
    await setDoc(doc(db, "users/admin"), { uId: "admin", email: admin.email, isAdmin: true });
    await setDoc(doc(db, "products/p1"), { productName: "Cap", salePrice: "35", quantity: "5" });
    await setDoc(doc(db, "orders/o1"), { customerId: "alice", status: "Pending", paymentStatus: "unpaid", totalPrice: 35 });
    await setDoc(doc(db, "orders/o1/items/i1"), { product_id: "p1", quantity: 1 });
    await setDoc(doc(db, "wishlist/alice@example.com"), { wishlist: [] });
    await setDoc(doc(db, "addresses/legacy1"), { email: alice.email, city: "JB" });
  });
});

describe("catalogue", () => {
  test("anyone can read products", async () => {
    await assertSucceeds(getDoc(doc(anon(), "products/p1")));
  });
  test("customers cannot change price or stock", async () => {
    await assertFails(updateDoc(doc(as(alice), "products/p1"), { quantity: "999" }));
    await assertFails(updateDoc(doc(as(alice), "products/p1"), { salePrice: "1" }));
  });
  test("admins can edit products", async () => {
    await assertSucceeds(updateDoc(doc(as(admin), "products/p1"), { quantity: "4" }));
  });
});

describe("profiles", () => {
  test("own profile readable, others not", async () => {
    await assertSucceeds(getDoc(doc(as(alice), "users/alice")));
    await assertFails(getDoc(doc(as(alice), "users/bob")));
  });
  test("cannot make yourself admin", async () => {
    await assertFails(updateDoc(doc(as(alice), "users/alice"), { isAdmin: true }));
    await assertFails(setDoc(doc(as({ uid: "eve", email: "e@x.com" }), "users/eve"), { isAdmin: true }));
  });
  test("can edit own name, tokens and flags", async () => {
    await assertSucceeds(updateDoc(doc(as(alice), "users/alice"), {
      name: "Alice", deviceToken: "t", fcmTokens: ["t"], wishlistMigrated: true,
    }));
  });
  test("new profile without admin flag is allowed", async () => {
    await assertSucceeds(setDoc(doc(as({ uid: "eve", email: "e@x.com" }), "users/eve"), { name: "Eve", isAdmin: false }));
  });
});

describe("cart, wishlist, addresses", () => {
  test("own cart with valid quantity", async () => {
    const ref = doc(as(alice), "users/alice/cart/p1__");
    await assertSucceeds(setDoc(ref, { productId: "p1", quantity: 2 }));
    await assertFails(setDoc(ref, { productId: "p1", quantity: 0 }));
    await assertFails(setDoc(ref, { productId: "p1", quantity: 500 }));
    await assertSucceeds(deleteDoc(ref));
  });
  test("someone else's cart is off limits", async () => {
    await assertFails(getDoc(doc(as(bob), "users/alice/cart/p1__")));
    await assertFails(setDoc(doc(as(bob), "users/alice/cart/p1__"), { productId: "p1", quantity: 1 }));
  });
  test("wishlist doc id must match its product", async () => {
    await assertSucceeds(setDoc(doc(as(alice), "users/alice/wishlist/p1"), { productId: "p1" }));
    await assertFails(setDoc(doc(as(alice), "users/alice/wishlist/p1"), { productId: "p2" }));
  });
  test("addresses are private", async () => {
    await assertSucceeds(setDoc(doc(as(alice), "users/alice/addresses/a1"), { city: "JB" }));
    await assertFails(getDoc(doc(as(bob), "users/alice/addresses/a1")));
  });
});

describe("orders", () => {
  test("customers read only their own orders and items", async () => {
    await assertSucceeds(getDoc(doc(as(alice), "orders/o1")));
    await assertSucceeds(getDocs(collection(as(alice), "orders/o1/items")));
    await assertFails(getDoc(doc(as(bob), "orders/o1")));
    await assertFails(getDocs(collection(as(bob), "orders/o1/items")));
  });
  test("the order list query is allowed for its owner", async () => {
    const q = query(collection(as(alice), "orders"), where("customerId", "==", "alice"));
    await assertSucceeds(getDocs(q));
    const all = query(collection(as(alice), "orders"));
    await assertFails(getDocs(all));
  });
  test("customers cannot create, pay or cancel orders directly", async () => {
    await assertFails(setDoc(doc(as(alice), "orders/o2"), { customerId: "alice", status: "Pending" }));
    await assertFails(updateDoc(doc(as(alice), "orders/o1"), { paymentStatus: "paid" }));
    await assertFails(updateDoc(doc(as(alice), "orders/o1"), { status: "Cancelled" }));
  });
  test("admins update order status", async () => {
    await assertSucceeds(updateDoc(doc(as(admin), "orders/o1"), { status: "Shipped" }));
  });
});

describe("legacy data and server collections", () => {
  test("owner reads legacy wishlist and addresses for migration", async () => {
    await assertSucceeds(getDoc(doc(as(alice), "wishlist/alice@example.com")));
    await assertFails(getDoc(doc(as(bob), "wishlist/alice@example.com")));
    const q = query(collection(as(alice), "addresses"), where("email", "==", alice.email));
    await assertSucceeds(getDocs(q));
    await assertFails(setDoc(doc(as(alice), "wishlist/alice@example.com"), { wishlist: [] }));
  });
  test("customers can't read or send mail", async () => {
    await assertFails(setDoc(doc(as(alice), "mail/m1"), { to: "x" }));
    await assertFails(getDoc(doc(as(alice), "mail/m1")));
  });
  test("unknown collections are admin only", async () => {
    await assertFails(getDoc(doc(as(alice), "secrets/x")));
    await assertSucceeds(getDoc(doc(as(admin), "secrets/x")));
  });
});
