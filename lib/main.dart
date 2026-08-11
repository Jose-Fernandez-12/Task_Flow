import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/task_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ],
      child: const TaskFlowApp(),
    ),
  );

  // Initialize Local Notifications safely in background without blocking UI
  _initNotifications();
}

Future<void> _initNotifications() async {
  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
