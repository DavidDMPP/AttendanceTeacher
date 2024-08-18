import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/attendance.dart';
import '../widgets/attendance_history_item.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AttendanceHistoryScreen');

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);

    final String? userId = authService.currentUser?.uid;
    _logger.info('Building AttendanceHistoryScreen for user: $userId');

    if (userId == null) {
      _logger.warning('No user ID available. User might not be logged in.');
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Absensi')),
        body: const Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: StreamBuilder<List<Attendance>>(
        stream: databaseService.getAttendanceHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _logger.info('Waiting for attendance data...');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            _logger.severe('Error fetching attendance data: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            _logger.info('No attendance history found for user: $userId');
            return const Center(child: Text('Tidak ada riwayat absensi'));
          }
          _logger.info('Received ${snapshot.data!.length} attendance records');
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return AttendanceHistoryItem(attendance: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}
