import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class AttendanceButton extends StatelessWidget {
  const AttendanceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    final locationService = Provider.of<LocationService>(context);

    return ElevatedButton(
      child: const Text('Absen'),
      onPressed: () async {
        try {
          bool isWithinRange = await locationService.isWithinAttendanceRange();
          if (!context.mounted) return;

          if (isWithinRange) {
            await databaseService.addAttendance(
                authService.currentUser?.uid ?? '', true);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Absensi berhasil')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Anda berada di luar jangkauan absensi')),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan. Coba lagi.')),
          );
        }
      },
    );
  }
}
