import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String subscriptionTier;
  final int dailyAiUsageCount;
  final Timestamp? lastAiUsageDate;
  final bool notificationsEnabled;
  final String? geminiApiKey;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.subscriptionTier = 'Free',
    this.dailyAiUsageCount = 0,
    this.lastAiUsageDate,
    this.notificationsEnabled = true,
    this.geminiApiKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'subscriptionTier': subscriptionTier,
      'dailyAiUsageCount': dailyAiUsageCount,
      'lastAiUsageDate': lastAiUsageDate,
      'notificationsEnabled': notificationsEnabled,
      'geminiApiKey': geminiApiKey,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      subscriptionTier: json['subscriptionTier'] ?? 'Free',
      dailyAiUsageCount: json['dailyAiUsageCount'] ?? 0,
      lastAiUsageDate: json['lastAiUsageDate'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      geminiApiKey: json['geminiApiKey'],
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    String? subscriptionTier,
    int? dailyAiUsageCount,
    Timestamp? lastAiUsageDate,
    bool? notificationsEnabled,
    String? geminiApiKey,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      dailyAiUsageCount: dailyAiUsageCount ?? this.dailyAiUsageCount,
      lastAiUsageDate: lastAiUsageDate ?? this.lastAiUsageDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}
