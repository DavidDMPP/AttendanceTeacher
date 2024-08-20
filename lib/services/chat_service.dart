import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ChatService');

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final DatabaseService _databaseService;

  ChatService(this._authService, this._databaseService);

  Stream<List<Message>> getMessages() {
    _logger.info('Fetching messages');
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      _logger.info('Received ${snapshot.docs.length} messages');
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String content) async {
    final user = _authService.currentUser;
    if (user != null) {
      _logger.info('Sending message for user: ${user.uid}');
      final teacherData = await _databaseService.getTeacher(user.uid);
      await _firestore.collection('messages').add({
        'senderId': user.uid,
        'senderName': teacherData?.name ?? 'Unknown',
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _logger.info('Message sent successfully');
    } else {
      _logger.warning('Attempted to send message without being logged in');
      throw Exception('User must be logged in to send messages');
    }
  }
}
