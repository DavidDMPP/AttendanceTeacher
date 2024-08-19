import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/chat_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'services/chat_service.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final authService = AuthService();
  final databaseService = DatabaseService();
  final locationService = LocationService();
  final chatService = ChatService(authService, databaseService);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<LocationService>.value(value: locationService),
        Provider<ChatService>.value(value: chatService),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(locationService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/attendance_history': (context) => const AttendanceHistoryScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
