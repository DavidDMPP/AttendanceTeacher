import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/attendance.dart';
import 'package:logging/logging.dart';

final _logger = Logger('DatabaseService');

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAttendance(
      String teacherId, GeoPoint location, String type) async {
    try {
      _logger.info('Adding attendance for teacher: $teacherId, type: $type');
      await _firestore.collection('attendances').add({
        'teacherId': teacherId,
        'date': FieldValue.serverTimestamp(),
        'location': location,
        'type': type,
      });
      _logger.info('Attendance added successfully');
    } catch (e) {
      _logger.severe('Error adding attendance', e);
      rethrow;
    }
  }

  Stream<List<Attendance>> getAttendanceHistory(String teacherId) {
    _logger.info('Getting attendance history for teacher: $teacherId');
    return _firestore
        .collection('attendances')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      _logger.info('Received ${snapshot.docs.length} attendance records');
      return snapshot.docs
          .map((doc) => Attendance.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateProfile(
      String teacherId, Map<String, dynamic> data) async {
    try {
      _logger.info('Updating profile for teacher: $teacherId');
      await _firestore.collection('teachers').doc(teacherId).update(data);
      _logger.info('Profile updated successfully');
    } catch (e) {
      _logger.severe('Error updating profile', e);
      rethrow;
    }
  }

  Future<Teacher?> getTeacher(String teacherId) async {
    try {
      _logger.info('Getting teacher data for ID: $teacherId');
      DocumentSnapshot doc =
          await _firestore.collection('teachers').doc(teacherId).get();
      if (doc.exists) {
        _logger.info('Teacher data found');
        return Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        _logger.warning('No teacher found with ID: $teacherId');
        return null;
      }
    } catch (e) {
      _logger.severe('Error getting teacher data', e);
      rethrow;
    }
  }
}
