import '../constants.dart';

/// Steps recorded for a single calendar day.
class DailySteps {
  final String dateKey; // 'yyyy-MM-dd'
  final int steps;

  const DailySteps({required this.dateKey, required this.steps});

  double get km => stepsToKm(steps);
  double get calories => stepsToCalories(steps);

  DailySteps copyWith({int? steps}) =>
      DailySteps(dateKey: dateKey, steps: steps ?? this.steps);
}
