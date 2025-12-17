import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/screens/ai_settings_screen.dart';
import 'package:easy_task_flow/screens/integrations_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();

  void _showProfileDialog() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final userData = await _databaseService.getUserById(user.uid);
    if (userData == null) return;

    _nameController.text = userData.name;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedUser = userData.copyWith(name: _nameController.text);
                await _databaseService.updateUser(updatedUser);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Manage Profile'),
            subtitle: const Text('Update your name'),
            leading: const Icon(Icons.person),
            onTap: _showProfileDialog,
          ),
          FutureBuilder<UserModel?>(
            future: _databaseService.getUserById(_authService.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              final userModel = snapshot.data;
              // If loading or error, default to disabled or loading state
              final isEnabled = userModel?.notificationsEnabled ?? false;

              return SwitchListTile(
                title: const Text('Notification Preferences'),
                subtitle: const Text('Enable notifications'),
                secondary: const Icon(Icons.notifications),
                value: isEnabled,
                onChanged: (val) async {
                  if (userModel != null) {
                    final updatedUser = userModel.copyWith(notificationsEnabled: val);
                    await _databaseService.updateUser(updatedUser);
                    setState(() {});
                  }
                },
              );
            },
          ),
          ListTile(
            title: const Text('AI Configuration'),
            leading: const Icon(Icons.auto_awesome),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Cloud Integrations'),
            subtitle: const Text('Google Drive, OneDrive, etc.'),
            leading: const Icon(Icons.cloud_sync),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IntegrationsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
