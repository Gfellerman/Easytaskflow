import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final GoogleApiService _googleApiService = GoogleApiService();
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
                final updatedUser = UserModel(
                  userId: userData.userId,
                  name: _nameController.text,
                  email: userData.email,
                  phoneNumber: userData.phoneNumber,
                  profilePictureUrl: userData.profilePictureUrl,
                );
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
          ListTile(
            title: const Text('Notification Preferences'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          FutureBuilder<bool>(
            future: _googleApiService.isSignedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Loading Google Account status...'),
                  leading: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData && snapshot.data!) {
                return ListTile(
                  title: const Text('Unlink Google Account'),
                  leading: const Icon(Icons.link_off),
                  onTap: () async {
                    await _googleApiService.signOut();
                    setState(() {});
                  },
                );
              } else {
                return ListTile(
                  title: const Text('Link Google Account'),
                  leading: const Icon(Icons.link),
                  onTap: () async {
                    await _googleApiService.signIn();
                    setState(() {});
                  },
                );
              }
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
