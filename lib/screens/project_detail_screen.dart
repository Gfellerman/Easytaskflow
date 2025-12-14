import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/screens/project_calendar_screen.dart';
import 'package:easy_task_flow/screens/task_detail_screen.dart';
import 'package:easy_task_flow/services/ai_service.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/services/dynamic_link_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';
import 'package:easy_task_flow/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _quickAddController = TextEditingController();
  DateTime? _dueDate;
  bool _isAiLoading = false;
  List<String> _selectedAssignees = [];
  late Future<List<UserModel?>> _membersFuture;
  final AiService _aiService = AiService();

  Future<void> _handleQuickAdd() async {
    final input = _quickAddController.text.trim();
    if (input.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isAiLoading = true);

    final canUseAi = await _databaseService.checkAndIncrementAiUsage(user.uid);
    if (!canUseAi) {
      if (mounted) {
        setState(() => _isAiLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily AI limit reached! Upgrade to Pro.')),
        );
      }
      return;
    }

    final result = await _aiService.parseTaskFromNaturalLanguage(input);

    if (result.containsKey('error') && result['error'] == 'AI_NOT_CONFIGURED') {
      if (mounted) {
        setState(() => _isAiLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI is not configured. Upgrade to Pro or Add Key.')),
        );
      }
      return;
    }

    if (result.isEmpty || !result.containsKey('taskName')) {
      if (mounted) {
        setState(() => _isAiLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not understand task.')),
        );
      }
      return;
    }

    final taskName = result['taskName'];
    final subtasks = List<String>.from(result['subtasks'] ?? []);
    DateTime dueDate = DateTime.now().add(const Duration(days: 1)); // Default
    if (result['dueDate'] != null) {
      try {
        dueDate = DateTime.parse(result['dueDate']);
      } catch (_) {}
    }

    final newTask = TaskModel(
      taskId: const Uuid().v4(),
      taskName: taskName,
      dueDate: Timestamp.fromDate(dueDate),
      assignees: [user.uid],
      taskDetails: 'Created via AI',
      subtasks: subtasks.map((s) => SubtaskModel(subtaskName: s, subtaskDetails: '')).toList(),
    );

    await _databaseService.createTask(widget.project.projectId, newTask);

    if (mounted) {
      setState(() => _isAiLoading = false);
      _quickAddController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created with AI!')),
      );
    }
  }

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
                  Navigator.pop(context);
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
                  Uri? link;

                  // Create dynamic link first (needed for both cases if we want to include it)
                  try {
                    link = await _dynamicLinkService.createDynamicLink(widget.project.projectId);
                  } catch (e) {
                    // Fallback if dynamic links fail (e.g. on web/linux)
                    link = Uri.parse('https://easytaskflow.com/project?id=${widget.project.projectId}');
                  }

                  // Close the input dialog first to avoid stack issues
                  if (context.mounted) Navigator.pop(context);

                  if (user != null) {
                    // User exists
                    if (widget.project.memberIds.contains(user.userId)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User is already in this project')),
                        );
                      }
                    } else {
                      await _databaseService.addMemberToProject(widget.project.projectId, user.userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User invited successfully')),
                        );

                        // Ask to send notification email
                         showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Notify User?'),
                            content: Text('Send an email to $email to let them know they were added?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final uri = Uri(
                                    scheme: 'mailto',
                                    path: email,
                                    query: 'subject=You have been added to ${widget.project.projectName}&body=You have been added to the project "${widget.project.projectName}" on EasyTaskFlow. Check it out here: $link',
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                child: const Text('Send Email'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } else {
                    // User does not exist
                    // Prompt to send invitation email
                    if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('User Not Found'),
                            content: Text('User with email $email was not found. Send an invitation email?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final uri = Uri(
                                    scheme: 'mailto',
                                    path: email,
                                    query: 'subject=Invitation to EasyTaskFlow&body=I invite you to join my project "${widget.project.projectName}" on EasyTaskFlow. Join here: $link',
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                     // Fallback: Copy link
                                     await Share.share('Join my project on EasyTaskFlow! $link');
                                  }
                                },
                                child: const Text('Send Invite'),
                              ),
                            ],
                          ),
                        );
                    }
                  }
                  _emailController.clear();
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
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
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
            ),
            if (_isAiLoading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickAddController,
                      decoration: const InputDecoration(
                        hintText: 'Quick Add Task (AI)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: _handleQuickAdd,
                  ),
                ],
              ),
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
