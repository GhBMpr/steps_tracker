import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants.dart';
import '../models/daily_steps.dart';
import '../services/storage_service.dart';
import 'details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _storage = StorageService();
  Map<String, int> _history = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _load();
  }

  Future<void> _load() async {
    final history = await _storage.getHistory();
    if (mounted) setState(() => _history = history);
  }

  int _stepsFor(DateTime day) => _history[StorageService.keyFor(day)] ?? 0;

  Color _dotColor(int steps) {
    if (steps >= AppConstants.dailyGoal) return AppColors.primary;
    if (steps > 0) return AppColors.primaryLight;
    return Colors.transparent;
  }

  void _openDetails(DateTime day) {
    final key = StorageService.keyFor(day);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailsScreen(
          day: DailySteps(dateKey: key, steps: _stepsFor(day)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Calendar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _openDetails(selected);
            },
            onPageChanged: (focused) => _focusedDay = focused,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: AppColors.primaryDark),
              defaultTextStyle: const TextStyle(color: Colors.black87),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final steps = _stepsFor(day);
                if (steps == 0) return null;
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _dotColor(steps),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_stepsFor(_selectedDay!)} steps',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: () => _openDetails(_selectedDay!),
                    child: const Text('View details'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
