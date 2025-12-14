import 'package:easy_task_flow/models/message_model.dart';
import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/screens/project_detail_screen.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter/material.dart';

/// A widget that displays a project tile with its most recent message.
///
/// This is a StatefulWidget to persist the message stream across rebuilds,
/// preventing unnecessary stream re-subscriptions which would occur if
/// the stream was created directly in the parent's build method.
class ProjectMessageTile extends StatefulWidget {
  final ProjectModel project;
  final DatabaseService databaseService;

  const ProjectMessageTile({
    super.key,
    required this.project,
    required this.databaseService,
  });

  @override
  State<ProjectMessageTile> createState() => _ProjectMessageTileState();
}

class _ProjectMessageTileState extends State<ProjectMessageTile> {
  late Stream<MessageModel?> _messageStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream only once to avoid re-subscribing on every build.
    _messageStream =
        widget.databaseService.getMostRecentMessage(widget.project.projectId);
  }

  @override
  void didUpdateWidget(covariant ProjectMessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate the stream if the project ID changes.
    if (oldWidget.project.projectId != widget.project.projectId) {
      _messageStream =
          widget.databaseService.getMostRecentMessage(widget.project.projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MessageModel?>(
      stream: _messageStream,
      builder: (context, snapshot) {
        final message = snapshot.data;
        return ListTile(
          title: Text(widget.project.projectName),
          subtitle: Text(message?.message ?? 'No messages yet'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(
                  project: widget.project,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
