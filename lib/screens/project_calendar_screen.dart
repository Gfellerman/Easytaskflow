import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProjectCalendarScreen extends StatefulWidget {
  final String projectId;

  const ProjectCalendarScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectCalendarScreen> createState() => _ProjectCalendarScreenState();
}

class _ProjectCalendarScreenState extends State<ProjectCalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<TaskModel> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = [];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TaskModel>>(
        stream: _databaseService.getTasks(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }
          final tasks = snapshot.data!;

          // Optimization: Group tasks by date for O(1) lookup
          // This prevents O(N*M) complexity in TableCalendar's eventLoader
          final eventsMap = <DateTime, List<TaskModel>>{};
          for (var task in tasks) {
            final date = task.dueDate.toDate();
            final key = _normalizeDate(date);
            if (eventsMap[key] == null) {
              eventsMap[key] = [];
            }
            eventsMap[key]!.add(task);
          }

          List<TaskModel> getEventsForDay(DateTime day) {
            return eventsMap[_normalizeDate(day)] ?? [];
          }

          _selectedEvents = getEventsForDay(_selectedDay!);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: (day) => getEventsForDay(day),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      // _selectedEvents will be updated in the next build cycle via StreamBuilder
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    return ListTile(
                      title: Text(event.taskName),
                      subtitle: Text('Due: ${event.dueDate.toDate()}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
