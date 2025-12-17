import 'dart:async';

import 'package:easy_task_flow/models/project_model.dart';
import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

// User State
final currentUserProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// User Projects
final userProjectsProvider =
    StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(databaseServiceProvider).getProjects(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// StateNotifier to aggregate tasks from all projects
class AllTasksNotifier extends StateNotifier<List<TaskModel>> {
  final DatabaseService _db;
  final List<ProjectModel> _projects;
  final List<StreamSubscription> _subs = [];

  AllTasksNotifier(this._db, this._projects) : super([]) {
    _init();
  }

  void _init() {
    if (_projects.isEmpty) {
      state = [];
      return;
    }

    final Map<String, List<TaskModel>> tasksMap = {};

    for (final project in _projects) {
      final sub = _db.getTasks(project.projectId).listen((tasks) {
        tasksMap[project.projectId] = tasks;
        _updateState(tasksMap);
      });
      _subs.add(sub);
    }
  }

  void _updateState(Map<String, List<TaskModel>> tasksMap) {
    final allTasks = tasksMap.values.expand((l) => l).toList();
    state = allTasks;
  }

  @override
  void dispose() {
    for (var sub in _subs) sub.cancel();
    super.dispose();
  }
}

final allTasksProvider =
    StateNotifierProvider.autoDispose<AllTasksNotifier, List<TaskModel>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final projectsAsync = ref.watch(userProjectsProvider);

  // We only start watching tasks when we have projects
  final projects = projectsAsync.valueOrNull ?? [];

  return AllTasksNotifier(db, projects);
});

// Dashboard Statistics Model
class DashboardStats {
  final int projectCount;
  final int tasksDueCount;
  final List<TaskModel> upcomingDeadlines;
  final List<TaskModel> recentActivity;

  DashboardStats({
    required this.projectCount,
    required this.tasksDueCount,
    required this.upcomingDeadlines,
    required this.recentActivity,
  });

  const DashboardStats.empty()
      : projectCount = 0,
        tasksDueCount = 0,
        upcomingDeadlines = const [],
        recentActivity = const [];
}

// Computed Provider for Stats
final dashboardStatsProvider = Provider.autoDispose<DashboardStats>((ref) {
  final projects = ref.watch(userProjectsProvider).valueOrNull ?? [];
  final allTasks = ref.watch(allTasksProvider);
  final user = ref.watch(authServiceProvider).currentUser;

  // Filter tasks assigned to current user for "Tasks Due"
  final myTasks = user == null
      ? <TaskModel>[]
      : allTasks.where((t) => t.assignees.contains(user.uid)).toList();

  final tasksDue = myTasks.where((t) => !t.isDone).length;

  // Upcoming: My tasks, not completed, sorted by Due Date (ascending)
  final upcoming = myTasks.where((t) => !t.isDone).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  // Recent Activity: All tasks (team activity), sorted by CreatedAt (descending)
  final recent = List<TaskModel>.from(allTasks)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return DashboardStats(
    projectCount: projects.length,
    tasksDueCount: tasksDue,
    upcomingDeadlines: upcoming.take(5).toList(),
    recentActivity: recent.take(5).toList(),
  );
});

final myTasksProvider = Provider.autoDispose<List<TaskModel>>((ref) {
  final allTasks = ref.watch(allTasksProvider);
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return [];
  return allTasks.where((t) => t.assignees.contains(user.uid)).toList();
});
