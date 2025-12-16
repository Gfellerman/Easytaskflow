import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_task_flow/models/file_model.dart';
import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User methods
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.userId).set(user.toJson());
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromJson(doc.data()!) : null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final query =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromJson(query.docs.first.data());
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.userId).update(user.toJson());
  }

  Future<bool> doesUserExist(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  // Project methods
  Future<void> createProject(ProjectModel project) async {
    await _db
        .collection('projects')
        .doc(project.projectId)
        .set(project.toJson());
  }

  Stream<List<ProjectModel>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addMemberToProject(String projectId, String userId) async {
    await _db.collection('projects').doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> deleteProject(String projectId) async {
    await _db.collection('projects').doc(projectId).delete();
  }

  // Task methods
  Future<void> createTask(String projectId, TaskModel task) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.taskId)
        .set(task.toJson());
  }

  Stream<List<TaskModel>> getTasks(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> updateTask(String projectId, TaskModel task) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.taskId)
        .update(task.toJson());
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Message methods
  Future<void> sendMessage(String projectId, MessageModel message) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .add(message.toJson());
  }

  Stream<List<MessageModel>> getMessages(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList());
  }

  Stream<MessageModel?> getMostRecentMessage(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return MessageModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    });
  }

  // File methods
  Future<String> uploadFile(String filePath, String fileName) async {
    final file = File(filePath);

    // Generate a unique ID to prevent overwrites and path traversal
    final uniqueId = const Uuid().v4();

    // Try to preserve extension if it exists
    String extension = '';
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      extension = fileName.substring(dotIndex);
    }

    final uniqueFileName = '$uniqueId$extension';
    final ref = _storage.ref().child('task_documents/$uniqueFileName');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addFileToTask(
      String projectId, String taskId, FileModel file) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('files')
        .doc(file.fileId)
        .set(file.toJson());
  }

  Stream<List<FileModel>> getFilesForTask(String projectId, String taskId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('files')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FileModel.fromJson(doc.data()))
            .toList());
  }

  Future<bool> checkAndIncrementAiUsage(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final data = userDoc.data()!;
    final user = UserModel.fromJson(data);

    final now = DateTime.now();
    final lastDate = user.lastAiUsageDate?.toDate();

    int currentCount = user.dailyAiUsageCount;

    if (lastDate == null ||
        lastDate.year != now.year ||
        lastDate.month != now.month ||
        lastDate.day != now.day) {
      currentCount = 0;
    }

    final limit = user.subscriptionTier == 'Pro' ? 50 : 5;

    if (currentCount >= limit) {
      return false;
    }

    await _db.collection('users').doc(userId).update({
      'dailyAiUsageCount': currentCount + 1,
      'lastAiUsageDate': Timestamp.fromDate(now),
    });

    return true;
  }
}
