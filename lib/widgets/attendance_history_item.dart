import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../utils/time_utils.dart';

class AttendanceHistoryItem extends StatelessWidget {
  final Attendance attendance;

  const AttendanceHistoryItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(formatDateTime(attendance.timestamp)),
      subtitle: Text(attendance.isCheckIn ? 'Check In' : 'Check Out'),
      trailing: Icon(
        attendance.isCheckIn ? Icons.login : Icons.logout,
        color: attendance.isCheckIn ? Colors.green : Colors.red,
      ),
    );
  }
}