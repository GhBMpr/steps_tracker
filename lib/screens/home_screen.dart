import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../constants.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  int _steps = 0;
  StreamSubscription? _sub;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();

    // Live updates pushed by the background service while the app is open.
    final service = FlutterBackgroundService();
    _sub = service.on('update').listen((event) {
      if (event == null) return;
      setState(() => _steps = event['steps'] as int);
    });

    // Safety net in case the service hasn't pushed an update yet.
    _fallbackTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadFromStorage();
    });
  }

  Future<void> _loadFromStorage() async {
    final steps = await _storage.getStepsForDay(StorageService.todayKey());
    if (mounted) setState(() => _steps = steps);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final km = stepsToKm(_steps);
    final calories = stepsToCalories(_steps);
    final progress = (_steps / AppConstants.dailyGoal).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Today',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: AppColors.progressTrack,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_steps',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Text(
                        'steps',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: calories.toStringAsFixed(0),
                    label: 'kcal burned',
                    color: AppColors.accentCalories,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.straighten,
                    value: '${km.toStringAsFixed(2)}',
                    label: 'km walked',
                    color: AppColors.accentDistance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Goal: ${AppConstants.dailyGoal} steps',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
