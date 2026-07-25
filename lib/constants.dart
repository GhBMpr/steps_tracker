import 'package:flutter/material.dart';

/// App-wide constants and simple conversion formulas.
///
/// These are approximations for an average adult. If you want more
/// accurate numbers, turn [strideMeters] and [caloriesPerStep] into
/// user-editable settings based on height/weight.
class AppConstants {
  // Average stride length in meters.
  static const double strideMeters = 0.762;

  // Rough calories burned per step for an average adult.
  static const double caloriesPerStep = 0.04;

  // Notify the user every time they cross a multiple of this many steps.
  static const int milestoneStep = 1000;

  // A soft daily goal, only used to color the calendar / progress ring.
  static const int dailyGoal = 10000;

  static const String notificationChannelId = 'step_tracker_channel';
  static const String notificationChannelName = 'Step Tracker';
  static const String notificationChannelDescription =
      'Shows your live step count, distance and calories burned.';

  static const int liveNotificationId = 888;
}

double stepsToKm(int steps) => (steps * AppConstants.strideMeters) / 1000.0;

double stepsToCalories(int steps) => steps * AppConstants.caloriesPerStep;

/// Centralized white/purple palette so every screen stays visually consistent.
class AppColors {
  static const primary = Color(0xFF6C4AB6); // deep purple, main accent
  static const primaryDark = Color(0xFF4A2F91); // for text on light bg
  static const primaryLight = Color(0xFFB39DDB); // soft lavender
  static const surfaceTint = Color(0xFFF4F1FB); // near-white lavender tint
  static const background = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF8A80A6);
  static const accentCalories = Color(0xFF9C6ADE); // violet
  static const accentDistance = Color(0xFF7C5CBF); // purple-blue
  static const goalReached = Color(0xFF6C4AB6);
  static const progressTrack = Color(0xFFE7E0F7);
}
