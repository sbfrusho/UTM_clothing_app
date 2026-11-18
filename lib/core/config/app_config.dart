/// Build-time configuration.
///
/// Values are injected with `--dart-define-from-file=env/<env>.json`
/// (see `env/example.json`). Nothing secret may ever live here: everything
/// compiled into the app can be extracted from the APK. Secret keys belong on
/// the server (Cloud Functions).
abstract final class AppConfig {
  static const String appName = 'Your Shop';

  /// `dev`, `staging` or `prod`.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static bool get isProduction => environment == 'prod';

  /// ISO-4217 currency used for prices and payments.
  static const String currency = String.fromEnvironment(
    'CURRENCY',
    defaultValue: 'MYR',
  );

  static const String currencySymbol = String.fromEnvironment(
    'CURRENCY_SYMBOL',
    defaultValue: 'RM',
  );

  /// Stripe **publishable** key (`pk_...`). Safe to ship in the client.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  /// Base URL of the deployed Cloud Functions, e.g.
  /// `https://asia-southeast1-<project>.cloudfunctions.net`
  /// (see docs/BACKEND.md). When set, orders, cancellations and card
  /// payments go through the server; required once `firestore.rules` is
  /// deployed.
  static const String functionsBaseUrl = String.fromEnvironment(
    'FUNCTIONS_BASE_URL',
  );

  static bool get isBackendConfigured => functionsBaseUrl.isNotEmpty;

  /// WhatsApp number (international format, digits only) for "Contact us".
  /// Empty hides the button.
  static const String supportWhatsApp = String.fromEnvironment(
    'SUPPORT_WHATSAPP',
  );

  /// OAuth **Web** client ID of the Firebase project (Firebase console >
  /// Authentication > Sign-in method > Google > Web SDK configuration).
  /// Public, not a secret. Empty hides "Continue with Google".
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static bool get isGoogleSignInEnabled => googleServerClientId.isNotEmpty;

  /// Hosted privacy policy and terms (required on the Play Store listing).
  /// Host docs/PRIVACY_POLICY.md and docs/TERMS.md, e.g. on GitHub Pages or
  /// Firebase Hosting. The app always shows its own copy; when set, the
  /// screens also offer "Open in browser".
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
  );
  static const String termsUrl = String.fromEnvironment('TERMS_URL');

  /// Shown in the privacy policy and on the delete-account screen.
  /// Required before release: Play needs a contact for privacy requests.
  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  /// Real card payments need both the publishable key and the backend.
  /// Without them the app falls back to the demo gateway.
  static bool get isStripeConfigured =>
      stripePublishableKey.isNotEmpty && isBackendConfigured;
}
