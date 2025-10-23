import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  // File methods
  Future<String> uploadFile(String filePath, String fileName) async {
    final file = File(filePath);
    final ref = _storage.ref().child('task_documents/$fileName');
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
}
