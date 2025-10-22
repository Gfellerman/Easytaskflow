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
  final TextEditingController _phoneController = TextEditingController();

  void _showProfileDialog(UserModel user) {
    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedUser = UserModel(
                  userId: user.userId,
                  name: _nameController.text,
                  email: user.email,
                  phoneNumber: _phoneController.text,
                  profilePictureUrl: user.profilePictureUrl,
                );
                await _databaseService.updateUser(updatedUser);
                Navigator.pop(context);
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
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : FutureBuilder<UserModel?>(
              future: _databaseService.getUserById(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Error loading user data.'));
                }
                final userModel = snapshot.data!;
                return ListView(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userModel.profilePictureUrl != null
                            ? NetworkImage(userModel.profilePictureUrl!)
                            : null,
                        child: userModel.profilePictureUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(userModel.name),
                      subtitle: Text(userModel.email),
                      onTap: () => _showProfileDialog(userModel),
                    ),
                    ListTile(
                      title: const Text('Link Google Account'),
                      onTap: () async {
                        await _googleApiService.signIn();
                      },
                    ),
                    ListTile(
                      title: const Text('Logout'),
                      onTap: () async {
                        await _authService.signOut();
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
