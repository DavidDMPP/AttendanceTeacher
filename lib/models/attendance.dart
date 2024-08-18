import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String teacherId;
  final DateTime date;
  final GeoPoint location;
  final String type;

  Attendance({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.location,
    required this.type,
  });

  factory Attendance.fromMap(Map<String, dynamic> data, String id) {
    return Attendance(
      id: id,
      teacherId: data['teacherId'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] as GeoPoint,
      type: data['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'date': Timestamp.fromDate(date),
      'location': location,
      'type': type,
    };
  }

  String getFormattedDate() {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getFormattedTime() {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool get isCheckIn => type == 'check-in';

  @override
  String toString() {
    return 'Attendance(id: $id, teacherId: $teacherId, date: ${getFormattedDate()} ${getFormattedTime()}, location: ${location.latitude}, ${location.longitude}, type: $type)';
  }
}
