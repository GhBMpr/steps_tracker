import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:pedometer/pedometer.dart';

import '../constants.dart';
import 'notification_service.dart';
import 'storage_service.dart';

/// Wires up flutter_background_service so the pedometer keeps being read
/// (and the notification kept updated) even while the app is closed.
///
/// On Android this runs as a genuine foreground service, which is why the
/// live notification must always stay visible: Android requires a visible
/// notification for any app to keep running in the background this way.
class BackgroundStepService {
  static Future<void> configure() async {
    final service = FlutterBackgroundService();

    // If the service survived from before (e.g. process relaunched after
    // being swiped from Recents), don't re-configure/re-start it — doing
    // so is what causes the app to hang on relaunch.
    if (await service.isRunning()) {
      return;
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onServiceStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: AppConstants.notificationChannelId,
        initialNotificationTitle: 'Step Tracker',
        initialNotificationContent: 'Starting up…',
        foregroundServiceNotificationId: AppConstants.liveNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        // iOS won't keep this alive indefinitely while the app is closed;
        // this mainly lets the app refresh stats quickly on resume.
        autoStart: true,
        onForeground: onServiceStart,
        onBackground: (service) async => true,
      ),
    );

    await service.startService();
  }
}

/// Top-level entry point, as required by flutter_background_service — it
/// must NOT be a class method, or native code can fail to reach it after
/// tree-shaking (the "must be annotated"/entry-point error).
@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final storage = StorageService();
  await NotificationService.init();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // Let the UI ask the service to stop, if ever needed.
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Pedometer.stepCountStream.listen((StepCount event) async {
    final cumulative = event.steps;
    final baseline = await storage.getBaselineForToday(cumulative);
    final todaySteps = (cumulative - baseline).clamp(0, 1000000);

    await storage.setStepsForToday(todaySteps);

    final km = stepsToKm(todaySteps);
    final calories = stepsToCalories(todaySteps);

    await NotificationService.showLiveStats(
      steps: todaySteps,
      km: km,
      calories: calories,
    );

    // Push the latest numbers to the UI if it's currently open/listening.
    service.invoke('update', {
      'steps': todaySteps,
      'km': km,
      'calories': calories,
    });

    // Milestone check: fire once per newly crossed 1000-step threshold.
    final newMilestone =
        (todaySteps ~/ AppConstants.milestoneStep) * AppConstants.milestoneStep;
    if (newMilestone > 0) {
      final lastNotified = await storage.getLastMilestoneNotified();
      if (newMilestone > lastNotified) {
        await storage.setLastMilestoneNotified(newMilestone);
        await NotificationService.showMilestone(newMilestone);
      }
    }
  }, onError: (error) {
    // Sensor unavailable / permission denied — nothing more to do here.
  });
}
