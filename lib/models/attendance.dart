import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String teacherId;
  final DateTime timestamp;
  final bool isCheckIn;

  Attendance({required this.id, required this.teacherId, required this.timestamp, required this.isCheckIn});

  factory Attendance.fromMap(Map<String, dynamic> data, String id) {
    return Attendance(
      id: id,
      teacherId: data['teacherId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isCheckIn: data['isCheckIn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isCheckIn': isCheckIn,
    };
  }
}