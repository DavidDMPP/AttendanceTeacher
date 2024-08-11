import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/attendance_button.dart';
import '../widgets/location_status_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const LocationStatusIndicator(),
            const SizedBox(height: 20),
            const AttendanceButton(),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Riwayat Absensi'),
              onPressed: () => Navigator.pushNamed(context, '/attendance_history'),
            ),
            ElevatedButton(
              child: const Text('Chat'),
              onPressed: () => Navigator.pushNamed(context, '/chat'),
            ),
            ElevatedButton(
              child: const Text('Profil'),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}