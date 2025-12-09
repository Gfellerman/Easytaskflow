import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/screens/project_calendar_screen.dart';
import 'package:easy_task_flow/screens/task_detail_screen.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/services/dynamic_link_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';
import 'package:easy_task_flow/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
  final GoogleApiService _googleApiService = GoogleApiService();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _dueDate;

  void _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteProject(widget.project.projectId);
      if (mounted) {
        Navigator.pop(context); // Go back to projects list
      }
    }
  }
  List<String> _selectedAssignees = [];
  late Future<List<UserModel?>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = Future.wait(
      widget.project.memberIds.map((memberId) => _databaseService.getUserById(memberId)),
    );
  }

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
                    }),
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

                  // Add event to Google Calendar
                  if (_googleApiService.currentUser != null) {
                    for (final assigneeId in _selectedAssignees) {
                      final assignee = await _databaseService.getUserById(assigneeId);
                      if (assignee != null) {
                        await _googleApiService.insertEvent(
                          newTask.taskName,
                          _dueDate!,
                          _dueDate!.add(const Duration(hours: 1)),
                          assignee.email,
                        );
                      }
                    }
                  }

                  _taskNameController.clear();
                  _dueDate = null;
                  if (context.mounted) Navigator.pop(context);
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
                      await _databaseService.addMemberToProject(widget.project.projectId, user.userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User invited successfully')),
                        );
                      }
                    }
                  } else {
                    final dynamicLink =
                        await _dynamicLinkService.createDynamicLink(widget.project.projectId);
                    Share.share('Join my project on EasyTaskFlow! $dynamicLink');
                  }
                  _emailController.clear();
                  if (context.mounted) Navigator.pop(context);
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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.projectName),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showInviteDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProject,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Calendar'),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              projectId: widget.project.projectId,
                              task: task,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            // Calendar View
            ProjectCalendarScreen(projectId: widget.project.projectId),
            // Members View
            FutureBuilder<List<UserModel?>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No members yet.'));
                }
                final members = snapshot.data!;
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      title: Text(member?.name ?? 'Unknown'),
                      subtitle: Text(member?.email ?? 'Unknown'),
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
                              await _databaseService.sendMessage(
                                  widget.project.projectId, newMessage);
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
        bottomNavigationBar: const BannerAdWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
