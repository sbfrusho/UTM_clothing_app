import '../../core/config/app_config.dart';

/// A legal document shown in the app. The same text lives in
/// docs/PRIVACY_POLICY.md and docs/TERMS.md for hosting; keep them in sync.
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.updated,
    required this.sections,
    required this.url,
  });

  final String title;
  final String updated;
  final List<(String heading, String body)> sections;

  /// Hosted copy, empty when not configured.
  final String url;
}

/// Route argument for [AppRoutes.legal].
enum LegalPage { privacy, terms }

abstract final class LegalContent {
  static const _updated = '18 November 2026';

  static String get _contact => AppConfig.supportEmail.isEmpty
      ? 'through the contact details on our Google Play listing'
      : 'at ${AppConfig.supportEmail}';

  static LegalDocument of(LegalPage page) => switch (page) {
    LegalPage.privacy => privacy,
    LegalPage.terms => terms,
  };

  static LegalDocument get privacy => LegalDocument(
    title: 'Privacy policy',
    updated: _updated,
    url: AppConfig.privacyPolicyUrl,
    sections: [
      (
        'Who we are',
        '${AppConfig.appName} is an online clothing shop. This policy '
            'explains what personal data the app collects, why, and the '
            'choices you have. It follows the laws of Bangladesh.',
      ),
      (
        'What we collect',
        '• Account: your name, email address, phone number and, if you add '
            'one, a profile photo.\n'
            '• Delivery: the addresses you save.\n'
            '• Shopping: your cart, saved items and orders.\n'
            '• Device: a notification token so we can send order updates, '
            'and basic diagnostics when something goes wrong.\n'
            'Card details are entered in Stripe\'s secure payment sheet and '
            'never reach our servers or this app.',
      ),
      (
        'How we use it',
        'To create your account, deliver and support your orders, take '
            'payments, send updates about your orders, and keep the shop '
            'secure. We do not sell your data or use it for advertising.',
      ),
      (
        'Who processes it',
        'Data is stored with Google Firebase (authentication, database, file '
            'storage, notifications). Card payments are processed by '
            'Stripe. Both act on our behalf under their own privacy '
            'commitments.',
      ),
      (
        'How long we keep it',
        'Your account data stays until you delete your account. Orders are '
            'kept for accounting and tax purposes, with your name, email, '
            'phone and address removed once the account is deleted.',
      ),
      (
        'Your choices',
        '• Edit your name, phone, photo and addresses in Profile.\n'
            '• Turn order notifications off in your phone settings.\n'
            '• Delete your account and its data at any time in Profile → '
            'Delete account.\n'
            'To ask for a copy of your data, or with any other question, '
            'contact us $_contact.',
      ),
      (
        'Children',
        'The app is not directed at children under 13 and we do not '
            'knowingly collect their data.',
      ),
      (
        'Changes',
        'We will update this page and the date above when this policy '
            'changes. Significant changes will also be announced in the app.',
      ),
    ],
  );

  static LegalDocument get terms => LegalDocument(
    title: 'Terms of use',
    updated: _updated,
    url: AppConfig.termsUrl,
    sections: [
      (
        'Using the app',
        'By creating an account you agree to these terms. Keep your sign-in '
            'details private; you are responsible for orders placed from '
            'your account.',
      ),
      (
        'Products and prices',
        'We try to describe products and prices accurately. Prices are in '
            '${AppConfig.currency} and are confirmed when you place the '
            'order. If a product turns out to be unavailable, we cancel '
            'that order and refund any payment.',
      ),
      (
        'Payment',
        'Card payments are taken by Stripe. Card orders that are not paid '
            'within 30 minutes are cancelled automatically. Cash on '
            'delivery is paid to the courier.',
      ),
      (
        'Cancellations and returns',
        'You can cancel an order in the app while it is pending. Paid card '
            'orders cancelled this way are refunded to the same card. For '
            'returns after delivery, contact us $_contact.',
      ),
      (
        'Acceptable use',
        'Don\'t misuse the app, interfere with its security, or use it for '
            'anything unlawful. We may suspend accounts that do.',
      ),
      (
        'Liability',
        'The app is provided as is. To the extent the law allows, we are not '
            'liable for indirect losses. Nothing here limits your rights '
            'under the Consumer Rights Protection Act 2009 of Bangladesh.',
      ),
      (
        'Changes',
        'We may update these terms. The date above shows the latest '
            'version; continuing to use the app means you accept it.',
      ),
    ],
  );
}
