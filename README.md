# Your Shop

A Flutter e-commerce app for clothing and merchandise, built on Firebase with GetX for state management, dependency injection and routing.

> Status: being moved from a university project to a production Play Store release. See [docs/ROADMAP.md](docs/ROADMAP.md) for the sprint plan.

## Features
- Email/password and Google sign-in, with an email verification gate and password reset
- Optional biometric app lock (fingerprint / Face ID)
- Product catalogue: categories, sort and filters, ranked search, zoomable gallery, related products
- Cart and wishlist synced to the account (offline-ready, checked against live price and stock)
- Address book; checkout with Cash on Delivery or card (Stripe through Cloud Functions, or the test gateway)
- Live order history with status timeline, payment retry and cancellation

## Tech stack
| Layer | Choice |
|-------|--------|
| UI | Flutter (Material 3), custom grey/cream design system, light + dark |
| Architecture | MVVM (`data/` = Model, `*ViewModel` = GetX controllers, `GetView` views) |
| State, DI, routing | GetX |
| Backend | Firebase Auth, Cloud Firestore, Cloud Messaging |
| Payments | Pluggable `PaymentGateway`: demo gateway now; Stripe, bKash or SSLCommerz through a server backend |

## Screenshots
<p>
  <img src="docs/screenshots/01_welcome.png" width="180">
  <img src="docs/screenshots/03_home.png" width="180">
  <img src="docs/screenshots/05_product.png" width="180">
  <img src="docs/screenshots/06_cart.png" width="180">
  <img src="docs/screenshots/07_profile.png" width="180">
  <img src="docs/screenshots/09_home_dark.png" width="180">
</p>

Regenerate with `flutter test tool/screenshots_test.dart --update-goldens` (renders the real views with fake data).

## Getting started

Requirements: Flutter stable (3.47 or later), JDK 17 or later, Android SDK 36.

```sh
git clone https://github.com/sbfrusho/UTM_clothing_app.git
cd UTM_clothing_app
flutter pub get
cp env/example.json env/dev.json   # then fill in values if needed
flutter run --dart-define-from-file=env/dev.json
```

In VS Code, choose the **Your Shop (dev)** launch configuration.

### Environment values (`env/*.json`)
| Key | Purpose |
|-----|---------|
| `APP_ENV` | `dev`, `staging` or `prod` |
| `CURRENCY` / `CURRENCY_SYMBOL` | Pricing currency, e.g. `MYR` / `RM` |
| `STRIPE_PUBLISHABLE_KEY` | Stripe `pk_...` key (publishable only) |
| `PAYMENT_BACKEND_URL` | Server endpoint that creates PaymentIntents |
| `GOOGLE_SERVER_CLIENT_ID` | Firebase OAuth **Web** client ID; empty hides Google sign-in |

If `STRIPE_PUBLISHABLE_KEY` or `PAYMENT_BACKEND_URL` is empty, card payments use the **demo gateway**: a simulated payment that charges nothing.

> **Never put secret keys** (Stripe `sk_...`, SMTP passwords, service accounts) in the app or in `env/`. Anything compiled into an APK can be extracted. Secrets belong in Cloud Functions.

### Firebase
The Android app ID is `com.sbfrusho.yourshop`. Register it in the Firebase console, then download `google-services.json` into `android/app/` (or run `flutterfire configure`).

## Brand assets
The logo is vector code (`lib/core/widgets/brand/brand_mark_painter.dart`). After changing it:
```sh
flutter test tool/generate_brand_assets_test.dart   # renders assets/branding/*.png
dart run flutter_launcher_icons                      # launcher + adaptive icons
dart run flutter_native_splash:create                # native splash
```
Fonts: Manrope and Playfair Display (SIL OFL, bundled in `assets/fonts`).

## Testing
```sh
flutter analyze
flutter test
```

## Backend
Cloud Functions for payments, order expiry and emails: see [docs/BACKEND.md](docs/BACKEND.md).

## Release
See [docs/RELEASE.md](docs/RELEASE.md).

## Author
Developed by **Sakib Bin Faruque Rusho**: [rushocseru28@gmail.com](mailto:rushocseru28@gmail.com) · [GitHub](https://github.com/sbfrusho)
