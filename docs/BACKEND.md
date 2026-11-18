# Backend (Cloud Functions)

The app works without the backend: card payments then use the **demo gateway** (no money moves). Deploy the backend to take real card payments, release unpaid orders automatically and send order emails.

Code: [`functions/`](../functions) (TypeScript, Firebase Functions v2, region `asia-southeast1`).

| Function | Trigger | What it does |
|----------|---------|--------------|
| `createPaymentIntent` | HTTPS `POST {orderId}` with the user's Firebase ID token | Checks the order belongs to the caller and is awaiting payment, **recomputes the total from live product prices**, refuses if it differs from the order, and creates (or reuses) a Stripe PaymentIntent. |
| `stripeWebhook` | HTTPS from Stripe | Verifies the signature. On `payment_intent.succeeded`, marks the order `paid`. A payment arriving after the order was released is refunded automatically. |
| `expireUnpaidOrders` | Every 10 minutes | Card orders still `awaiting_payment` after 30 minutes are cancelled, their stock is put back and the PaymentIntent is cancelled. |
| `placeOrder` / `cancelOrder` | HTTPS with the user's ID token | Create orders from the cart at live prices with stock reserved; cancel pending orders with restock and Stripe refund. |
| `deleteAccount` | HTTPS with a sign-in from the last 5 minutes | Refuses while an order is in progress. Deletes the profile, cart, wishlist, addresses, legacy wishlist/addresses and `users/{uid}/` files in Storage, anonymises past orders, then deletes the Auth user. |
| `onOrderWritten` | Firestore `orders/{id}` | Records `statusHistory.<Status>` when the admin app changes the status, and queues emails (order received, payment received, status changes) in `mail`. |

## How a card order flows

1. The app creates the order in one transaction: stock is reserved, the cart is emptied, and `paymentStatus` is set to `awaiting_payment`.
2. The app calls `createPaymentIntent`. The server charges what the products cost, never a number sent by the app.
3. The customer pays in the Stripe sheet. `stripeWebhook` marks the order `paid`.
4. If they cancel or the payment fails, the order page offers **Pay** or **Cancel** until the 30-minute window ends. After that, `expireUnpaidOrders` releases the stock.

## Deploy

Requirements: Firebase **Blaze** plan (Functions, Scheduler and outbound network need it), Node 22, the Firebase CLI (`npm i -g firebase-tools`) and a Stripe account.

```sh
firebase login
firebase use nabilrayhanshopping

# Secrets (stored in Google Secret Manager, never in the repo)
firebase functions:secrets:set STRIPE_SECRET_KEY        # sk_test_... first
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET    # whsec_..., see below

cd functions && npm ci && npm test && cd ..
firebase deploy --only functions,firestore,storage
```

Optional parameters (prompted on first deploy, or set in `functions/.env`): `CURRENCY` (default `bdt`) and `SHOP_NAME` (default `Your Shop`).

### Stripe webhook
In the Stripe Dashboard, go to **Developers → Webhooks → Add endpoint**:
- URL: `https://asia-southeast1-nabilrayhanshopping.cloudfunctions.net/stripeWebhook`
- Events: `payment_intent.succeeded`, `payment_intent.payment_failed`

Copy the signing secret (`whsec_...`) into `STRIPE_WEBHOOK_SECRET` and redeploy.

### Point the app at it
In `env/dev.json` (and `env/prod.json` with live keys):
```json
"STRIPE_PUBLISHABLE_KEY": "pk_test_...",
"FUNCTIONS_BASE_URL": "https://asia-southeast1-nabilrayhanshopping.cloudfunctions.net"
```
With both set, the app switches from the demo gateway to Stripe automatically. `FUNCTIONS_BASE_URL` alone moves ordering, cancelling and account deletion to the server.

### Order emails
Install the **Trigger Email from Firestore** extension (`firebase ext:install firebase/firestore-send-email`) with collection `mail` and your SMTP provider (for example SendGrid, Mailgun or Gmail with an app password). The functions already write the documents it sends.

## Test it end to end (Stripe test mode)
1. Place a card order in the app and pay with `4242 4242 4242 4242`, any future date and any CVC.
2. The order page shows **Paid** within a few seconds (that's the webhook).
3. Place another card order and close the sheet. The order shows **Awaiting payment** with a Pay button. After 30 minutes it becomes **Cancelled** and the stock is back.

## Storage
Profile photos are stored at `users/{uid}/avatar.jpg`. `storage.rules` lets only the owner write them (images under 5 MB). Enable Storage in the Firebase console first. New projects need the Blaze plan for a default bucket.

## Still to do
- bKash and SSLCommerz: add a `PaymentGateway` in the app and a matching session/IPN function here. Both need merchant (or sandbox) credentials.
