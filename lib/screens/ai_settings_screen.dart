import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter/material.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final user = await _db.getUserById(_auth.currentUser?.uid ?? '');
    if (user != null && mounted) {
      _apiKeyController.text = user.geminiApiKey ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveKey() async {
    final user = await _db.getUserById(_auth.currentUser?.uid ?? '');
    if (user != null) {
      await _db.updateUser(user.copyWith(geminiApiKey: _apiKeyController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key Saved')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Configuration')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Enter your Google Gemini API Key to enable AI features.'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Gemini API Key',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveKey,
                    child: const Text('Save Key'),
                  ),
                ],
              ),
            ),
    );
  }
}
