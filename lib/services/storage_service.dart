import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the day-by-day step history as a simple JSON map:
/// { "2026-07-14": 4523, "2026-07-13": 8790, ... }
///
/// Also keeps track of:
/// - the raw sensor "steps since boot" baseline for the current day
///   (the pedometer plugin reports a cumulative counter, not a daily one)
/// - the last 1000-step milestone we already congratulated the user for,
///   per day, so we don't spam duplicate notifications.
class StorageService {
  static const _historyKey = 'daily_steps_history';
  static const _baselineKey = 'today_baseline_steps';
  static const _baselineDateKey = 'today_baseline_date';
  static const _lastMilestoneKey = 'last_milestone_notified';

  static String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static String keyFor(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<Map<String, int>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> _saveHistory(Map<String, int> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<int> getStepsForDay(String dateKey) async {
    final history = await getHistory();
    return history[dateKey] ?? 0;
  }

  Future<void> setStepsForToday(int steps) async {
    final history = await getHistory();
    history[todayKey()] = steps;
    await _saveHistory(history);
  }

  /// The pedometer stream gives a cumulative count since the phone booted.
  /// We store a "baseline" value captured at the start of each day so that
  /// todaysSteps = cumulativeSensorValue - baseline.
  /// If the stored baseline is from a previous day (or missing), we reset it.
  Future<int> getBaselineForToday(int currentCumulativeSteps) async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_baselineDateKey);
    final today = todayKey();

    if (storedDate != today) {
      // New day: reset baseline to the current sensor reading.
      await prefs.setInt(_baselineKey, currentCumulativeSteps);
      await prefs.setString(_baselineDateKey, today);
      await prefs.setInt(_lastMilestoneKey, 0);
      return currentCumulativeSteps;
    }

    return prefs.getInt(_baselineKey) ?? currentCumulativeSteps;
  }

  Future<int> getLastMilestoneNotified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastMilestoneKey) ?? 0;
  }

  Future<void> setLastMilestoneNotified(int milestone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastMilestoneKey, milestone);
  }
}
