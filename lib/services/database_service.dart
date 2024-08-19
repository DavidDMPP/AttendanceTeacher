import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/attendance.dart';
import 'package:logging/logging.dart';

final _logger = Logger('DatabaseService');

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAttendance(
      String teacherId, GeoPoint location, String type) async {
    if (teacherId.isEmpty) {
      _logger.severe('Attempted to add attendance with empty teacherId');
      throw ArgumentError('teacherId cannot be empty');
    }
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

  Future<String> getNextAttendanceType(String teacherId) async {
    if (teacherId.isEmpty) {
      _logger
          .severe('Attempted to get next attendance type with empty teacherId');
      throw ArgumentError('teacherId cannot be empty');
    }
    try {
      final today = DateTime.now().toLocal();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('attendances')
          .where('teacherId', isEqualTo: teacherId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'Check-In';
      } else {
        final lastAttendance = querySnapshot.docs.first;
        return lastAttendance['type'] == 'Check-In' ? 'Check-Out' : 'Check-In';
      }
    } catch (e) {
      _logger.severe('Error getting next attendance type', e);
      rethrow;
    }
  }

  Stream<List<Attendance>> getAttendanceHistory(String teacherId) {
    if (teacherId.isEmpty) {
      _logger
          .severe('Attempted to get attendance history with empty teacherId');
      return Stream.value([]);
    }
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
    if (teacherId.isEmpty) {
      _logger.severe('Attempted to update profile with empty teacherId');
      throw ArgumentError('teacherId cannot be empty');
    }
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
    if (teacherId.isEmpty) {
      _logger.severe('Attempted to get teacher data with empty teacherId');
      return null;
    }
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
