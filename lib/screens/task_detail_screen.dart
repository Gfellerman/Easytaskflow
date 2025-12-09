import 'package:easy_task_flow/models/file_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class TaskDetailScreen extends StatefulWidget {
  final String projectId;
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.projectId,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final GoogleApiService _googleApiService = GoogleApiService();
  final TextEditingController _subtaskNameController = TextEditingController();
  final TextEditingController _subtaskDetailsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  void _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
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
      await _databaseService.deleteTask(widget.projectId, widget.task.taskId);
      if (mounted) {
        Navigator.pop(context); // Go back to project details
      }
    }
  }

  void _showAddSubtaskDialog(TaskModel currentTask) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Subtask'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subtaskNameController,
                decoration: const InputDecoration(hintText: 'Subtask Name'),
              ),
              TextField(
                controller: _subtaskDetailsController,
                decoration: const InputDecoration(hintText: 'Subtask Details'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_subtaskNameController.text.isNotEmpty) {
                  final newSubtask = SubtaskModel(
                    subtaskName: _subtaskNameController.text,
                    subtaskDetails: _subtaskDetailsController.text,
                  );
                  final updatedSubtasks = List<SubtaskModel>.from(currentTask.subtasks)
                    ..add(newSubtask);
                  final updatedTask = TaskModel(
                    taskId: currentTask.taskId,
                    taskName: currentTask.taskName,
                    dueDate: currentTask.dueDate,
                    assignees: currentTask.assignees,
                    taskDetails: currentTask.taskDetails,
                    subtasks: updatedSubtasks,
                  );
                  _databaseService.updateTask(widget.projectId, updatedTask);
                  _subtaskNameController.clear();
                  _subtaskDetailsController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      final fileUrl = await _databaseService.uploadFile(file.path!, file.name);
      final newFile = FileModel(
        fileId: const Uuid().v4(),
        fileName: file.name,
        fileUrl: fileUrl,
        fileType: file.extension ?? '',
      );
      await _databaseService.addFileToTask(widget.projectId, widget.task.taskId, newFile);
    }
  }

  void _showGoogleDrivePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attach from Google Drive'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Google Drive',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) => setState(() {}),
                  ),
                  FutureBuilder<drive.FileList>(
                    future: _googleApiService.searchFiles(_searchController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.files == null) {
                        return const Center(child: Text('Error loading files.'));
                      }
                      final files = snapshot.data!.files!;
                      return SizedBox(
                        height: 300,
                        width: 300,
                        child: ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return ListTile(
                              title: Text(file.name ?? 'No name'),
                              onTap: () async {
                                final newFile = FileModel(
                                  fileId: const Uuid().v4(),
                                  fileName: file.name!,
                                  fileUrl: file.webViewLink!,
                                  fileType: file.mimeType!,
                                );
                                await _databaseService.addFileToTask(
                                  widget.projectId,
                                  widget.task.taskId,
                                  newFile,
                                );
                                Navigator.pop(context);
                                if (context.mounted) Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
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
          title: Text(widget.task.taskName),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Subtasks'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Details View
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due Date: ${widget.task.dueDate.toDate()}'),
                  const SizedBox(height: 10),
                  const Text('Assignees:'),
                  ...widget.task.assignees.map((assigneeId) {
                    return FutureBuilder<UserModel?>(
                      future: _databaseService.getUserById(assigneeId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                          return const Text('Error loading user');
                        }
                        final user = snapshot.data!;
                        return Text(user.name);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  const Text('Details:'),
                  Text(widget.task.taskDetails),
                ],
              ),
            ),
            // Subtasks View
            StreamBuilder<TaskModel>(
              stream: _databaseService
                  .getTasks(widget.projectId)
                  .map((tasks) => tasks.firstWhere((task) => task.taskId == widget.task.taskId)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading subtasks.'));
                }
                final task = snapshot.data!;
                return Scaffold(
                  body: ListView.builder(
                    itemCount: task.subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = task.subtasks[index];
                      return ListTile(
                        title: Text(subtask.subtaskName),
                        subtitle: Text(subtask.subtaskDetails),
                      );
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _showAddSubtaskDialog(task),
                    child: const Icon(Icons.add),
                  ),
                );
              },
            ),
            // Documents View
            Scaffold(
              body: StreamBuilder<List<FileModel>>(
                stream: _databaseService.getFilesForTask(widget.projectId, widget.task.taskId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No documents yet.'));
                  }
                  final files = snapshot.data!;
                  return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return ListTile(
                        title: Text(file.fileName),
                        leading: const Icon(Icons.insert_drive_file),
                        onTap: () async {
                          final uri = Uri.parse(file.fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            throw 'Could not launch ${file.fileUrl}';
                          }
                        },
                      );
                    },
                  );
                },
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    onPressed: _uploadFile,
                    label: const Text('Upload File'),
                    icon: const Icon(Icons.attach_file),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    onPressed: _showGoogleDrivePickerDialog,
                    label: const Text('Attach from Google Drive'),
                    icon: const Icon(Icons.add_to_drive),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
