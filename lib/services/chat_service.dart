import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/teacher.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ChatService');

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final DatabaseService _databaseService;

  ChatService(this._authService, this._databaseService);

  Future<String> getTeacherName(String teacherId) async {
    try {
      Teacher? teacher = await _databaseService.getTeacher(teacherId);
      if (teacher != null) {
        return teacher.name;
      }
    } catch (e) {
      _logger.warning('Error getting teacher name: $e');
    }
    return 'Unknown';
  }

  Future<void> sendMessage(String content) async {
    final user = _authService.currentUser;
    if (user == null) {
      _logger.warning('Attempt to send message without being logged in');
      return;
    }

    String senderName = await getTeacherName(user.uid);
    _logger.info('Sending message with sender name: $senderName');

    final message = Message(
      id: '', // Firestore will generate this
      senderId: user.uid,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    );

    try {
      await _firestore.collection('messages').add(message.toMap());
      _logger.info('Message sent successfully');
    } catch (e) {
      _logger.severe('Error sending message: $e');
    }
  }

  Stream<List<Message>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }
}
