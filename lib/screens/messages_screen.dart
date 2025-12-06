import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/screens/project_detail_screen.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final databaseService = DatabaseService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : StreamBuilder<List<ProjectModel>>(
              stream: databaseService.getProjects(user.uid),
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
                    return StreamBuilder<MessageModel?>(
                      stream: databaseService.getMostRecentMessage(project.projectId),
                      builder: (context, snapshot) {
                        final message = snapshot.data;
                        return ListTile(
                          title: Text(project.projectName),
                          subtitle: Text(message?.message ?? 'No messages yet'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailScreen(project: project),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
