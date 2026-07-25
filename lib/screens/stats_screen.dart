import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _storage = StorageService();
  List<MapEntry<DateTime, int>> _last7Days = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await _storage.getHistory();
    final days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final key = StorageService.keyFor(date);
      return MapEntry(date, history[key] ?? 0);
    });
    if (mounted) setState(() => _last7Days = days);
  }

  @override
  Widget build(BuildContext context) {
    final total = _last7Days.fold<int>(0, (sum, e) => sum + e.value);
    final average = _last7Days.isEmpty ? 0 : total ~/ _last7Days.length;
    final best = _last7Days.isEmpty
        ? 0
        : _last7Days.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxValue = best == 0 ? 1 : best;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.directions_walk,
                    value: '$total',
                    label: 'total steps',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.equalizer,
                    value: '$average',
                    label: 'daily average',
                    color: AppColors.accentDistance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.emoji_events,
                    value: '$best',
                    label: 'best day',
                    color: AppColors.accentCalories,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _last7Days.map((entry) {
                  final ratio = entry.value / maxValue;
                  final reachedGoal = entry.value >= AppConstants.dailyGoal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            entry.value > 0 ? '${entry.value}' : '',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 100 * ratio.clamp(0.02, 1.0),
                            decoration: BoxDecoration(
                              color: reachedGoal
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('E').format(entry.key),
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
