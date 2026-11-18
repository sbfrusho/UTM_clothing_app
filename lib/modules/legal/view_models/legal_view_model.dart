import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_snackbar.dart';
import '../legal_content.dart';

class LegalViewModel extends GetxController {
  LegalViewModel({LegalPage? page})
    : document = LegalContent.of(
        page ??
            (Get.arguments is LegalPage
                ? Get.arguments as LegalPage
                : LegalPage.privacy),
      );

  final LegalDocument document;

  bool get hasOnlineCopy => document.url.isNotEmpty;

  Future<void> openOnline() async {
    final uri = Uri.tryParse(document.url);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppSnackbar.error('Could not open the page.');
  }
}
