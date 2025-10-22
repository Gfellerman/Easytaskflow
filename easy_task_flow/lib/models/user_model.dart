class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
