import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/google_api_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final GoogleApiService _googleApiService = GoogleApiService();

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
            leading: const Icon(Icons.person),
            onTap: () {
              // TODO: Implement profile management
            },
          ),
          ListTile(
            title: const Text('Notification Preferences'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // TODO: Implement notification preferences
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
