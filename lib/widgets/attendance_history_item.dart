import 'package:flutter/material.dart';
import '../models/attendance.dart';

class AttendanceHistoryItem extends StatelessWidget {
  final Attendance attendance;

  const AttendanceHistoryItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          '${attendance.getFormattedDate()} ${attendance.getFormattedTime()}'),
      subtitle: Text(
          'Type: ${attendance.type}\nLocation: ${attendance.location.latitude}, ${attendance.location.longitude}'),
      leading: Icon(
        attendance.isCheckIn ? Icons.login : Icons.logout,
        color: attendance.isCheckIn ? Colors.green : Colors.red,
      ),
    );
  }
}
