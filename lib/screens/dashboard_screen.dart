import 'package:easy_task_flow/providers/dashboard_provider.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double padding = constraints.maxWidth > 600 ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user?.displayName ?? 'User'}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _OverviewCard(
                        title: 'Tasks Due',
                        value: '${stats.tasksDueCount}',
                        icon: Icons.task_alt,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _OverviewCard(
                        title: 'Projects',
                        value: '${stats.projectCount}',
                        icon: Icons.folder_open,
                        color: Colors.blue,
                      ),
                    ),
                    if (constraints.maxWidth > 800) ...[
                         const SizedBox(width: 16),
                         const Spacer(),
                         const Spacer(),
                    ]
                  ],
                ),

                const SizedBox(height: 32),

                // Upcoming Deadlines
                _SectionHeader(title: 'Upcoming Deadlines'),
                const SizedBox(height: 12),
                if (stats.upcomingDeadlines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No upcoming deadlines.'),
                  )
                else
                  ...stats.upcomingDeadlines.map((task) => Card(
                    child: ListTile(
                      title: Text(task.taskName),
                      subtitle: Text('Due ${DateFormat.yMMMd().format(task.dueDate.toDate())}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  )),

                const SizedBox(height: 24),

                // Recent Activity (Recently Created Tasks)
                _SectionHeader(title: 'Recently Added'),
                const SizedBox(height: 12),
                if (stats.recentActivity.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No recent activity.'),
                  )
                else
                  ...stats.recentActivity.map((task) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.add_circle_outline),
                      title: Text('New Task: ${task.taskName}'),
                      subtitle: Text('Added ${DateFormat.MMMd().add_jm().format(task.createdAt.toDate())}'),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
