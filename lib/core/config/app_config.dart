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

  /// HTTPS endpoint (Cloud Function) that creates a Stripe PaymentIntent
  /// using the secret key on the server and returns `{ "clientSecret": ... }`.
  static const String paymentBackendUrl = String.fromEnvironment(
    'PAYMENT_BACKEND_URL',
  );

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

  /// Real card payments need both the publishable key and a backend.
  /// Without them the app falls back to the demo gateway.
  static bool get isStripeConfigured =>
      stripePublishableKey.isNotEmpty && paymentBackendUrl.isNotEmpty;
}
