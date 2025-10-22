import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) {
    return _db.collection('users').doc(user.userId).set(user.toMap());
  }

  Future<void> createProject(ProjectModel project) {
    return _db.collection('projects').doc(project.projectId).set(project.toMap());
  }

  Stream<List<ProjectModel>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel(
                  projectId: doc.id,
                  projectName: doc['projectName'],
                  ownerId: doc['ownerId'],
                  memberIds: List<String>.from(doc['memberIds']),
                ))
            .toList());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _db.collection('users').where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return UserModel(
        userId: data['userId'],
        name: data['name'],
        email: data['email'],
        phoneNumber: data['phoneNumber'],
        profilePictureUrl: data['profilePictureUrl'],
      );
    }
    return null;
  }

  Future<void> addUserToProject(String projectId, String userId) {
    return _db.collection('projects').doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return UserModel(
        userId: data['userId'],
        name: data['name'],
        email: data['email'],
        phoneNumber: data['phoneNumber'],
        profilePictureUrl: data['profilePictureUrl'],
      );
    }
    return null;
  }

  // Task methods
  Future<void> createTask(String projectId, TaskModel task) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.taskId)
        .set(task.toMap());
  }

  Stream<List<TaskModel>> getTasks(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel(
                  taskId: doc.id,
                  taskName: doc['taskName'],
                  dueDate: doc['dueDate'],
                  assignees: List<String>.from(doc['assignees']),
                  taskDetails: doc['taskDetails'],
                  subtasks: (doc['subtasks'] as List)
                      .map((subtask) => SubtaskModel(
                            subtaskName: subtask['subtaskName'],
                            subtaskDetails: subtask['subtaskDetails'],
                          ))
                      .toList(),
                ))
            .toList());
  }

  Future<void> updateTask(String projectId, TaskModel task) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.taskId)
        .update(task.toMap());
  }

  Future<void> deleteTask(String projectId, String taskId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Message methods
  Future<void> sendMessage(String projectId, MessageModel message) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());
  }

  Stream<List<MessageModel>> getMessages(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel(
                  messageId: doc.id,
                  senderId: doc['senderId'],
                  message: doc['message'],
                  timestamp: doc['timestamp'],
                ))
            .toList());
  }

  Future<void> updateUser(UserModel user) {
    return _db.collection('users').doc(user.userId).update(user.toMap());
  }
}
