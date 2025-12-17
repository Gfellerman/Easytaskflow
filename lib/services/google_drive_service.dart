import 'package:easy_task_flow/services/cloud_storage_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';

class GoogleDriveService implements CloudStorageService {
  final GoogleApiService _api = GoogleApiService();

  @override
  String get providerId => 'google_drive';

  @override
  String get providerName => 'Google Drive';

  @override
  Future<bool> isConnected() => _api.isSignedIn();

  @override
  Future<void> connect() => _api.signIn();

  @override
  Future<void> disconnect() => _api.signOut();

  @override
  Future<List<CloudFile>> searchFiles(String query) async {
    final list = await _api.searchFiles(query);
    return list.files
            ?.map((f) => CloudFile(
                  id: f.id ?? '',
                  name: f.name ?? 'Untitled',
                  url: f.webViewLink ?? '',
                  mimeType: f.mimeType ?? '',
                ))
            .toList() ??
        [];
  }
}
