# Production Roadmap

Goal: turn the university prototype into an app anyone can install from Google Play.
Stack after migration: Flutter (latest stable) · GetX (state, DI, routing) · Firebase (Auth, Firestore, Functions, FCM, Crashlytics) · Stripe (server-side intents).

Each sprint ends with a working, runnable app and a ready-to-use commit message.

## Decisions (18 Nov 2026)
| Topic | Decision |
|-------|----------|
| App name | **Your Shop** |
| Package / bundle ID | `com.sbfrusho.yourshop` (Dart package `your_shop`) |
| Firebase | Keep project `nabilrayhanshopping` for now; production project later |
| Admin | Separate admin app, out of scope until this app is done |
| Payments | `PaymentGateway` interface. Now: Cash on Delivery plus a **demo card gateway** (simulated). Stripe test mode turns on automatically once a server endpoint exists. bKash / SSLCommerz are added as further gateways in Sprint 7 |
| Non-functional | Must be scalable: feature modules, repositories, paginated queries, server-side money logic |

### Payment providers (for Sprint 7)
- **bKash Tokenized Checkout**: needs a bKash merchant account. Sandbox credentials are available for development, but the `app_key`/`app_secret`/`username`/`password` are secrets, so the grant-token / create / execute calls must run in a Cloud Function. The app only opens the returned `bkashURL` in a WebView.
- **SSLCommerz**: free sandbox store (covers bKash, Nagad, Rocket and cards in BD). Same rule: session creation and IPN validation happen on the server.
- **Stripe**: test mode is free. PaymentIntent creation must be server-side. Not available for BD merchants.
- All of the above need Cloud Functions, which requires the Firebase **Blaze** plan (free tier allowance, card on file). Alternative: any small HTTPS backend; set `PAYMENT_BACKEND_URL`.

---

## Audit summary (baseline, Nov 2026)

### Critical: security
| # | Issue | Where |
|---|-------|-------|
| S1 | Stripe **secret key** hard-coded in the client app (anyone who unpacks the APK can charge or refund on the account) | `lib/controller/payment-controller.dart` |
| S2 | Gmail SMTP password hard-coded in the client | `lib/screens/user/checkout-screen.dart` (`sendEmail`) |
| S3 | User passwords stored **in plain text** in Firestore `users/{uid}.password` and read back for the "biometric login" | `sign-up-controller.dart`, `home-screen.dart`, `welcome-screen.dart` |
| S4 | All of the above are in git history and the GitHub repo, so they must be **revoked/rotated**. Removing them from the code is not enough | git history |
| S5 | No Firestore security rules in the repo; the client queries other users' data by email | `firebase.json` |

### Critical: correctness
| # | Bug | Where |
|---|-----|-------|
| B1 | Card payment: `makePayment()` returns `true` even when the user **cancels** the payment sheet, so the order is placed without payment | `payment-controller.dart` |
| B2 | Stock is decremented item by item *before* the order is written, with no transaction or rollback. A failure mid-way loses stock, and concurrent buyers can oversell | `cart-controller.dart#placeOrder` |
| B3 | `addToWishlist()` calls `_wishlistItems.clear()`, so adding an item **wipes the wishlist** | `wishlist-controller.dart` |
| B4 | Cart is in memory only (lost on app restart); adding the same product twice creates duplicate lines; no size stored | `cart-model-controller.dart` |
| B5 | One `sellerEmail` for the whole cart, so multi-seller carts are attributed to the last seller | `cart-controller.dart` |
| B6 | Checkout spinner never resets on failure or cancel | `checkout-screen.dart` |
| B7 | Splash uses `push` instead of `pushReplacement` (back button returns to splash); admin users get stuck on splash | `splash-scree.dart` |
| B8 | Search downloads the entire `products` collection on every keystroke | `search-controller.dart` |
| B9 | Prices and quantities stored as `String` and parsed everywhere | models |

### Architecture / code health
- Mixed state management: Provider (`ChangeNotifierProvider`) + GetX + `setState`; `Get.put` scattered inside widgets; `BindingsBuilder` in `main` is created but never used.
- Firestore calls made directly from widgets; no repository/service layer.
- Imperative `Navigator.push(MaterialPageRoute…)` everywhere; bottom nav pushes new copies of screens onto the stack.
- Inconsistent file names (`splash-scree.dart`, `My Cart/` with a space, `Categories.dart`), dead code (`dummy.dart`, `place-order.dart`, `popular-controller` duplicates).
- 332 analyzer issues; many `ignore_for_file`; `print` everywhere.
- Unused or obsolete dependencies: `provider`, `sqflite`, `mailer`, `email_auth`, `email_otp`, `image_card`, `flutter_time_picker_spinner`.
- Repo bloat: ~11 screenshots in the root, iOS/watchkit/iMessage icon sets inside `assets/`.

### Play Store blockers
- `applicationId com.example.shopping_app`: Play rejects `com.example.*`.
- Release build signed with the **debug key**.
- No in-app **account deletion** (Play policy requirement for apps with accounts).
- No privacy policy or Data Safety declaration.
- Must target the current Play-required API level; `ndkVersion`, Java 8 and the deprecated `play:core` dependency need updating.

---

## Sprint plan

### Sprint 1: Security hardening and foundation ✅
- Removed the Stripe secret key, SMTP credentials and plain-text password storage from the client; sign-in deletes the legacy `password` field from existing user docs.
- Replaced the fake biometric login with a real **biometric app lock** (`BiometricService`, `AppLockScreen`, toggle in the drawer).
- `AppConfig` driven by `--dart-define-from-file=env/<env>.json`.
- `PaymentGateway` abstraction (demo and server-backed Stripe); fixed B1 (cancelled payment placed the order) and B6 (stuck spinner).
- Wishlist moved from Provider to GetX (fixed B3); Provider removed; `InitialBinding` registers cart and wishlist once.
- Upgraded every package to its latest major version (Firebase core 5 / auth 7 / firestore 7, Stripe 15, local_auth 3…); dropped 13 unused packages.
- Android moved to Kotlin DSL, AGP 9.1, Gradle 9.3, Java 17, release signing through `key.properties`; renamed to Your Shop / `com.sbfrusho.yourshop`.
- `AppLogger` (silent in release) replaces all `print`; analyzer issues down from 332 to 85 (the rest are file-naming and style notes fixed in Sprint 2).
- Deleted dead code, unused bundled assets and generated icon sets; screenshots moved to `docs/`.
- Deferred to Sprint 2: strict lint set (needs the file renames first).

### Sprint 2: Architecture restructure (GetX + MVVM) ✅
```
lib/
  main.dart                      # bootstraps Firebase, Stripe, BiometricService
  app/
    app.dart                     # GetMaterialApp
    bindings/initial_binding.dart
    middlewares/auth_middleware.dart
    routes/ app_routes.dart, app_pages.dart
  core/                          # no feature knowledge
    config/ constants/ errors/ theme/ utils/
    services/ auth, biometric, payment/*, push_token
    widgets/ product_card, app_network_image, state_views, loading_button…
  data/                          # MVVM Model layer
    models/        product, category, user, address, cart_item, wishlist_item, order
    repositories/  auth, user, catalog, wishlist, address, order
  modules/<feature>/             # splash auth shell home catalog product search
    bindings/                    # cart wishlist checkout orders profile
    view_models/                 # XxxViewModel extends GetxController
    views/                       # GetView<XxxViewModel>
```
- **MVVM** with GetX: Views only render `Obx` state and forward events; ViewModels hold state and call repositories; no Firestore outside `data/`.
- Named routes (`AppRoutes`/`AppPages`) with per-route Bindings; `AuthMiddleware` guards signed-in routes.
- One bottom-navigation **shell** (`IndexedStack` + `NavigationBar` with cart badge) replaces 12 copy-pasted nav bars and the drawer; the Profile tab hosts orders, address, edit profile, password reset, app lock, log out.
- Typed models tolerant of the admin app's string-typed numbers; Firestore field names unchanged (shared DB).
- `placeOrder` is a **Firestore transaction** (atomic stock check, decrement, order and items write); `verifyCart` re-checks stock and prices before payment (fixes B2).
- Cart keyed by product + size with stock limits (fixes B4, B5: all sellers recorded in `sellerIds`).
- Cursor pagination for category products; debounced search behind `CatalogRepository.search` (fixes B8; indexed search in Sprint 5).
- Login: email verification gate with resend, admin accounts rejected; register: validation and password confirmation.
- Removed `flutter_screenutil`, `fluttertoast`, `font_awesome_flutter`; WhatsApp contact uses `SUPPORT_WHATSAPP` config instead of a hard-coded personal number.
- Stricter lints (`strict-casts`, `strict-raw-types` and more), 0 analyzer issues, 19 unit tests (models, cart, payment).

### Sprint 3: Design system and redesign ✅
- New original brand: **Your Shop** mark (bag + "Y") drawn as vector (`BrandMarkPainter`), wordmark in Playfair Display; all UTM logos and images removed.
- Grey and cream palette (`AppColors`), semantic `AppPalette` theme extension (success/warning/info/accent/skeleton), full **light and dark** `ColorScheme`s; System/Light/Dark switch in Profile (`ThemeService`, persisted).
- Typography: Manrope (UI) + Playfair Display (headlines), bundled under SIL OFL.
- Modern top bars: page-colored, no tint, hairline on scroll; `AppTopBar.large` serif headers on tabs, soft-square back/action buttons (`AppIconButton`); home has a greeting header, logo, cart badge and search pill instead of an app bar; product page uses floating controls over a full-bleed image.
- Component theming: inputs, buttons, cards, chips, navigation bar, dialogs, sheets, date picker, snackbars.
- Skeleton loaders (home, grids, lists), redesigned empty/error states, stock and order-status indicators from the palette.
- Launcher icon (adaptive + Android 13 themed/monochrome + iOS), Play Store icon and native splash (light/dark, Android 12+) generated from the same painter (`tool/generate_brand_assets_test.dart`).
- Screenshot harness `tool/screenshots_test.dart` renders the real views with fake data; caught and fixed a skeleton overflow on 360 dp phones and a segmented-button wrap.
- Found: product images in Firebase Storage return 402 because Storage now requires the Blaze plan. The UI falls back to placeholders; images return once the project is on Blaze.

### Sprint 4: Authentication ✅
- Email/password sign up and sign in with validation (8+ chars, letters and numbers), password reset.
- Email verification gate: users stay signed in on a verify screen that polls every 5 s; resend has a 60 s cooldown.
- Google Sign-In (`google_sign_in` 7), hidden until `GOOGLE_SERVER_CLIENT_ID` is set; creates the profile on first sign-in.
- User profile document keyed by `uid` only. (Wishlist and addresses are still keyed by email; they move in Sprints 6 and 7.)
- `SessionService`: one place for launch/sign-in routing, admin rejection, the device token, redirecting to welcome when the session ends from any screen, and re-locking after 30 s in the background.
- `AuthMiddleware` also requires a verified email. Sign-out clears the device token and the app lock. Back can't bypass the lock screen.
- Profile shows the sign-in method; "Change password" only appears for password accounts.
- **To enable Google:** in Firebase, enable the Google provider, add the debug and release SHA-1 for `com.sbfrusho.yourshop`, download the new `google-services.json`, and put the Web client ID into `env/*.json`.

### Sprint 5: Catalogue (home, categories, product, search) ✅
- Home: banners, categories, **On sale** rail, new arrivals, "See all" into filtered lists.
- Product list (`/products`, replaces `/category`): any category, all products or a preset; sort (newest, price, discount, name) and a filter sheet (price range, sizes, on sale, in stock) with a live result count; infinite scroll; pull-to-refresh.
- Product details: full-screen gallery (swipe, pinch and double-tap zoom), sizes in wearing order, stock indicator, "You may also like".
- Search: ranked, tokenised (prefix and plural matching across name, category and description), debounced, recent searches, category shortcuts.
- **Catalogue snapshot:** the admin app stores prices as strings and writes no search keywords, so Firestore can't sort by price or search text. `CatalogRepository` keeps a 5-minute cached snapshot (read in pages of 200, up to 2,000 products) and filters, sorts and searches in the app. `CatalogSource` isolates Firestore. **Revisit** when the catalogue nears 2,000 products, or when the admin app writes a numeric `price` and `searchKeywords`: switch `browse` to cursor queries and `search` to Algolia/Typesense. Screens don't change.
- Fixes: selected chip labels were unreadable (dark on dark), the filter sheet had a duplicate handle, and a literal `"null"` from the admin app is now read as empty.

### Sprint 6: Cart and wishlist ✅
- Cart in `users/{uid}/cart/{productId__size}` (Firestore offline cache: works offline and syncs between devices). Edits apply instantly and are written in the background.
- On open (and on pull-to-refresh) the cart is checked against the live catalogue: prices and names are updated, quantities are lowered to stock (shared across sizes), and removed or sold-out products are flagged. A banner says what changed. Checkout is blocked until unavailable lines are removed.
- The order transaction deletes the purchased cart lines in the same atomic commit, so an order can't be placed twice.
- Wishlist in `users/{uid}/wishlist/{productId}` (one document per item, so a toggle can't wipe the list). Toggles are optimistic with undo, flicker-free while syncing. The Saved tab shows live price, "Price dropped", sold-out and removed products, and "Add to cart".
- One-time migration from the legacy `wishlist/{email}` document, flagged with `wishlistMigrated` on the profile. The legacy document is left untouched for the admin app.
- Badges: cart (available units) and Saved (count).
- **Sprint 8:** security rules must allow each user to read and write only their own `users/{uid}/cart` and `users/{uid}/wishlist`.

### Sprint 7: Checkout, payments and orders ✅
- Address book in `users/{uid}/addresses` (add, edit, delete, one default, picked at checkout). One-time migration from the legacy `addresses` collection, flagged with `addressesMigrated`.
- **Order-first checkout:** one transaction verifies stock and prices, reserves stock, writes the order and empties the cart. Card orders start as `awaiting_payment` and are paid afterwards, so a customer can never pay for an order that failed to be created (closes the old "refund needed" gap).
- Payment gateway pays a stored order. Stripe uses the `createPaymentIntent` function (amount computed on the server from live prices) and the webhook marks the order paid. The demo gateway records test payments in the app.
- Unpaid card orders: the order page offers **Pay** and **Cancel** for 30 minutes; after that `expireUnpaidOrders` releases the stock.
- Orders: live list and detail (status changes appear at once), status timeline from `statusHistory`, customer cancellation with restock while Pending and no real money taken.
- Cloud Functions in `functions/` (TypeScript, 8 unit tests): `createPaymentIntent`, `stripeWebhook` (refunds late payments for released orders), `expireUnpaidOrders`, `onOrderWritten` (status history and order emails via the Trigger Email extension). **Not deployed yet:** needs the Blaze plan. See [BACKEND.md](BACKEND.md).
- App and server share the same money rounding (`toMinorUnits`), tested on both sides.
- bKash and SSLCommerz are deferred: both need merchant or sandbox credentials. The `PaymentGateway` interface is ready for them.

### Sprint 8: Backend hardening and notifications (mostly done)
- Done: `firestore.rules` (18 emulator tests in test/firestore_rules), `firestore.indexes.json`, `placeOrder`/`cancelOrder` functions (the app uses them when `FUNCTIONS_BASE_URL` is set), multi-device FCM tokens, push on status change, contextual permission, "Order updates" channel and icon.
- Not done yet: App Check, Crashlytics, Analytics.
- `firestore.rules` (users read/write only their own data; products read-only for customers) and `firestore.indexes.json`, both in the repo.
- FCM push notifications for order status changes (Cloud Function trigger), notification permission flow (Android 13+).
- Firebase App Check, Crashlytics, Analytics events (view_item, add_to_cart, purchase).

### Sprint 9: Profile, settings, compliance and polish
- Edit profile and avatar (Firebase Storage).
- **Delete account** (Auth plus user data, through a Cloud Function).
- Privacy policy and terms screens with links.
- Theme toggle, language (English / Bahasa Melayu via GetX translations).
- Offline banner (connectivity), accessibility pass (contrast, semantics, text scaling).

### Sprint 10: Testing and CI
- Unit tests for controllers and repositories (`fake_cloud_firestore`, `firebase_auth_mocks`, `mocktail`).
- Widget tests for key screens; one integration test for the purchase flow.
- GitHub Actions: analyze, test, build an appbundle on each PR.

### Sprint 11: Release to Google Play
- New `applicationId` (for example `com.<yourname>.<appname>`), new Firebase Android app and `google-services.json`.
- Upload keystore plus a git-ignored `key.properties`; release `signingConfig`; R8 rules for Stripe and Firebase.
- Versioning strategy, `flutter build appbundle`.
- Store listing: icon, feature graphic, screenshots, description, privacy policy URL, Data Safety form, content rating.
- Internal testing → closed testing (Play requires 12 testers for 14 days on new personal accounts) → production.

---

## Do now, outside the code (owner action)
1. **Revoke** the Stripe test keys in the Stripe Dashboard (Developers → API keys → Roll keys).
2. **Change the Gmail password** of `ealumnimobileapp@gmail.com` and enable 2FA.
3. Plain-text passwords exist in Firestore `users` docs: delete that field from all documents.
