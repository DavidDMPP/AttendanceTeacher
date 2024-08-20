import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/attendance.dart';
import '../widgets/attendance_history_item.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AttendanceHistoryScreen');

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _selectedFilter = 'Hari Ini';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);

    final String? userId = authService.currentUser?.uid;
    _logger.info('Building AttendanceHistoryScreen for user: $userId');

    if (userId == null) {
      _logger.warning('No user ID available. User might not be logged in.');
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFilter,
              items: <String>['Hari Ini', '7 Hari Terakhir', '30 Hari Terakhir']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ),
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

          List<Attendance> filteredAttendances =
              _filterAttendances(snapshot.data!);
          _logger.info(
              'Received ${filteredAttendances.length} attendance records after filtering');

          return ListView.builder(
            itemCount: filteredAttendances.length,
            itemBuilder: (context, index) {
              return AttendanceHistoryItem(
                  attendance: filteredAttendances[index]);
            },
          );
        },
      ),
    );
  }

  List<Attendance> _filterAttendances(List<Attendance> attendances) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Hari Ini':
        return attendances
            .where((a) =>
                a.date.year == now.year &&
                a.date.month == now.month &&
                a.date.day == now.day)
            .toList();
      case '7 Hari Terakhir':
        final weekAgo = now.subtract(const Duration(days: 7));
        return attendances.where((a) => a.date.isAfter(weekAgo)).toList();
      case '30 Hari Terakhir':
        final monthAgo = now.subtract(const Duration(days: 30));
        return attendances.where((a) => a.date.isAfter(monthAgo)).toList();
      default:
        return attendances;
    }
  }
}
