class FileModel {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String fileType;

  FileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
    };
  }
}
