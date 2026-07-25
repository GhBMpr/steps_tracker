import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'services/background_step_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await _requestPermissions();
  await BackgroundStepService.configure();

  runApp(const StepTrackerApp());
}

Future<void> _requestPermissions() async {
  // Reading the step sensor.
  await Permission.activityRecognition.request();
  // Android 13+ requires explicit permission to show notifications.
  await Permission.notification.request();
  // Lets the foreground service survive aggressive battery optimization.
  await Permission.ignoreBatteryOptimizations.request();
}

class StepTrackerApp extends StatelessWidget {
  const StepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.background,
          indicatorColor: AppColors.primaryLight.withOpacity(0.35),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
