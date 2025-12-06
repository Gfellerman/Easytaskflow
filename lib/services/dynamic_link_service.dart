import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {
  Future<Uri> createDynamicLink(String projectId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://easytaskflow.page.link',
      link: Uri.parse('https://easytaskflow.com/project?id=$projectId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.easytaskflow.app',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.example.easyTaskFlow',
        minimumVersion: '1',
        appStoreId: '123456789',
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl;
  }
}
