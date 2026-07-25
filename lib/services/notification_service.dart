import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings);

    // Create the Android notification channel used for the live stats
    // notification (ongoing / low importance so it doesn't buzz constantly).
    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.low,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Shows (or updates in place) the persistent notification with today's
  /// steps, distance and calories. Uses `ongoing: true` so it can't be
  /// swiped away while tracking is active, and reuses the same id so it
  /// updates instead of stacking new notifications.
  static Future<void> showLiveStats({
    required int steps,
    required double km,
    required double calories,
  }) async {
    final details = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      AppConstants.liveNotificationId,
      '$steps steps today',
      '${km.toStringAsFixed(2)} km   •   ${calories.toStringAsFixed(0)} kcal',
      NotificationDetails(android: details, iOS: const DarwinNotificationDetails()),
    );
  }

  /// A one-off celebratory notification fired every time the user crosses
  /// a new 1000-step milestone.
  static Future<void> showMilestone(int milestone) async {
    const details = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final messages = [
      'Amazing! You just hit $milestone steps today. Keep going!',
      'You\'re on fire! $milestone steps and counting.',
      'Nice work! $milestone steps down. Your body thanks you.',
      '$milestone steps! You\'re building a great habit.',
    ];
    final message = messages[(milestone ~/ AppConstants.milestoneStep) % messages.length];

    await _plugin.show(
      // Unique id per milestone so past congratulations aren't overwritten.
      1000 + milestone,
      'Milestone reached! 🎉',
      message,
      const NotificationDetails(
        android: details,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
