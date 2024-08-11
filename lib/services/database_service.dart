import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/attendance.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAttendance(String teacherId, bool isCheckIn) async {
    await _firestore.collection('attendances').add({
      'teacherId': teacherId,
      'timestamp': FieldValue.serverTimestamp(),
      'isCheckIn': isCheckIn,
    });
  }

  Stream<List<Attendance>> getAttendanceHistory(String teacherId) {
    return _firestore
        .collection('attendances')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Attendance.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateProfile(String teacherId, Map<String, dynamic> data) async {
    await _firestore.collection('teachers').doc(teacherId).update(data);
  }

  Future<Teacher?> getTeacher(String teacherId) async {
    DocumentSnapshot doc = await _firestore.collection('teachers').doc(teacherId).get();
    if (doc.exists) {
      return Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}