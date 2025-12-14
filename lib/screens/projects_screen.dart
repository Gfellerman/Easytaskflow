import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/screens/project_detail_screen.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _projectNameController = TextEditingController();

  void _showCreateProjectDialog(int projectCount) {
    if (projectCount >= 50) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limit Reached'),
          content: const Text('You have reached the maximum limit of 50 projects.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: _projectNameController,
            decoration: const InputDecoration(hintText: 'Project Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_projectNameController.text.isNotEmpty) {
                  final user = _authService.currentUser;
                  if (user != null) {
                    final newProject = ProjectModel(
                      projectId: const Uuid().v4(),
                      projectName: _projectNameController.text,
                      ownerId: user.uid,
                      memberIds: [user.uid],
                    );
                    await _databaseService.createProject(newProject);
                    _projectNameController.clear();
                    Navigator.pop(context);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ProjectModel>>(
                    stream: _databaseService.getProjects(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No projects yet.'));
                      }
                      final projects = snapshot.data!;
                      return ListView.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ListTile(
                            title: Text(project.projectName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(
                                    project: project,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const BannerAdWidget(),
              ],
            ),
      floatingActionButton: StreamBuilder<List<ProjectModel>>(
          stream: _databaseService.getProjects(user!.uid),
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: () {
                final projectCount = snapshot.data?.length ?? 0;
                _showCreateProjectDialog(projectCount);
              },
              tooltip: 'Create New Project',
              child: const Icon(Icons.add),
            );
          }),
    );
  }
}
