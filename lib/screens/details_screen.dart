import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/daily_steps.dart';
import '../widgets/stat_card.dart';

class DetailsScreen extends StatelessWidget {
  final DailySteps day;

  const DetailsScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').parse(day.dateKey);
    final prettyDate = DateFormat('EEEE d MMMM y').format(date);

    return Scaffold(
      appBar: AppBar(title: const Text('Day details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prettyDate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.directions_walk,
                    value: '${day.steps}',
                    label: 'steps',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: day.calories.toStringAsFixed(0),
                    label: 'kcal',
                    color: AppColors.accentCalories,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.straighten,
                    value: day.km.toStringAsFixed(2),
                    label: 'km',
                    color: AppColors.accentDistance,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
