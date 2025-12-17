import 'package:easy_task_flow/services/google_drive_service.dart';
import 'package:flutter/material.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  final GoogleDriveService _googleDrive = GoogleDriveService();
  bool _isGoogleConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final google = await _googleDrive.isConnected();
    if (mounted) {
      setState(() {
        _isGoogleConnected = google;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Integrations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Google Drive'),
                  subtitle: Text(_isGoogleConnected ? 'Connected' : 'Disconnected'),
                  value: _isGoogleConnected,
                  onChanged: (val) async {
                    setState(() => _isLoading = true);
                    try {
                      if (val) {
                        await _googleDrive.connect();
                      } else {
                        await _googleDrive.disconnect();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                    await _checkStatus();
                  },
                  secondary: const Icon(Icons.cloud_circle),
                ),
                const ListTile(
                  title: Text('OneDrive (Coming Soon)'),
                  leading: Icon(Icons.cloud_off),
                  enabled: false,
                ),
                const ListTile(
                  title: Text('Dropbox (Coming Soon)'),
                  leading: Icon(Icons.cloud_off),
                  enabled: false,
                ),
              ],
            ),
    );
  }
}
