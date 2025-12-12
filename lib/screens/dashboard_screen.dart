import 'package:easy_task_flow/services/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}), // Global Search placeholder
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}), // Notifications placeholder
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.displayName ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Overview Cards
            const Row(
              children: [
                Expanded(child: _OverviewCard(title: 'Tasks Due', value: '5', icon: Icons.task_alt, color: Colors.orange)),
                SizedBox(width: 16),
                Expanded(child: _OverviewCard(title: 'Projects', value: '3', icon: Icons.folder_open, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Upcoming Deadlines', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Card(child: ListTile(title: Text('Website Redesign'), subtitle: Text('Due Today'), trailing: Icon(Icons.arrow_forward_ios, size: 16))),
            const SizedBox(height: 24),
            Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Card(child: ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Task Completed'), subtitle: Text('Mobile App > Login Screen'))),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
