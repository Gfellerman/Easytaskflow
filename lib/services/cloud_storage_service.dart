abstract class CloudStorageService {
  String get providerId;
  String get providerName;
  Future<bool> isConnected();
  Future<void> connect();
  Future<void> disconnect();
  Future<List<CloudFile>> searchFiles(String query);
}

class CloudFile {
  final String id;
  final String name;
  final String url;
  final String mimeType;

  CloudFile({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
  });
}
