class FileModel {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String storageProvider; // 'internal', 'google_drive', etc.

  FileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.storageProvider = 'internal',
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'storageProvider': storageProvider,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      fileId: json['fileId'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      storageProvider: json['storageProvider'] ?? 'internal',
    );
  }
}
