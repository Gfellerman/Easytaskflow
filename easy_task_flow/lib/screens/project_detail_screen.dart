import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _dueDate;
  List<String> _selectedAssignees = [];

  void _showCreateTaskDialog() {
    _selectedAssignees = [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: const InputDecoration(hintText: 'Task Name'),
                    ),
                    const SizedBox(height: 20),
                    Text('Due Date: ${_dueDate == null ? 'Not set' : _dueDate!.toLocal()}'),
                    ElevatedButton(
                      child: const Text('Select Date'),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Assignees'),
                    ...widget.project.memberIds.map((userId) {
                      return FutureBuilder<UserModel?>(
                        future: _databaseService.getUserById(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final user = snapshot.data!;
                          return CheckboxListTile(
                            title: Text(user.name),
                            value: _selectedAssignees.contains(userId),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedAssignees.add(userId);
                                } else {
                                  _selectedAssignees.remove(userId);
                                }
                              });
                            },
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_taskNameController.text.isNotEmpty && _dueDate != null) {
                  final newTask = TaskModel(
                    taskId: const Uuid().v4(),
                    taskName: _taskNameController.text,
                    dueDate: Timestamp.fromDate(_dueDate!),
                    assignees: _selectedAssignees,
                    taskDetails: '',
                    subtasks: [],
                  );
                  await _databaseService.createTask(widget.project.projectId, newTask);
                  _taskNameController.clear();
                  _dueDate = null;
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite User'),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text;
                if (email.isNotEmpty) {
                  final user = await _databaseService.getUserByEmail(email);
                  if (user != null) {
                    if (widget.project.memberIds.contains(user.userId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User is already in this project')),
                      );
                    } else {
                      await _databaseService.addUserToProject(widget.project.projectId, user.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User invited successfully')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found')),
                    );
                  }
                  _emailController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.projectName),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showInviteDialog,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Members'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tasks View
            StreamBuilder<List<TaskModel>>(
              stream: _databaseService.getTasks(widget.project.projectId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tasks yet.'));
                }
                final tasks = snapshot.data!;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.taskName),
                      subtitle: Text('Due: ${task.dueDate.toDate()}'),
                    );
                  },
                );
              },
            ),
            // Members View
            ListView.builder(
              itemCount: widget.project.memberIds.length,
              itemBuilder: (context, index) {
                final userId = widget.project.memberIds[index];
                return FutureBuilder<UserModel?>(
                  future: _databaseService.getUserById(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(title: Text('Loading...'));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const ListTile(title: Text('Error loading user'));
                    }
                    final user = snapshot.data!;
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    );
                  },
                );
              },
            ),
            // Messages View
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: _databaseService.getMessages(widget.project.projectId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No messages yet.'));
                      }
                      final messages = snapshot.data!;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ListTile(
                            title: Text(message.message),
                            subtitle: Text(message.senderId),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(hintText: 'Enter a message'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            final user = _authService.currentUser;
                            if (user != null) {
                              final newMessage = MessageModel(
                                messageId: const Uuid().v4(),
                                senderId: user.uid,
                                message: _messageController.text,
                                timestamp: Timestamp.now(),
                              );
                              await _databaseService.sendMessage(widget.project.projectId, newMessage);
                              _messageController.clear();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
