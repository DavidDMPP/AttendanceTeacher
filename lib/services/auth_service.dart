import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthService');

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithNipAndPassword(String nip, String password) async {
    try {
      _logger.info('Attempting to sign in with NIP: $nip');
      QuerySnapshot query = await _firestore
          .collection('teachers')
          .where('nip', isEqualTo: nip)
          .limit(1)
          .get();

      _logger.info(
          'Firestore query completed. Documents found: ${query.docs.length}');

      if (query.docs.isEmpty) {
        _logger.warning('No user found with NIP: $nip');
        throw Exception('No user found with this NIP');
      }

      String email = query.docs.first['email'];
      _logger.info('Email found for NIP $nip: $email');

      _logger.info('Attempting to sign in with email and password');
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _logger.info('Sign in successful. User ID: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      _logger.severe('Sign in failed', e);
      _logger
          .info('Detailed error: $e'); // This will print the full error message
      return null;
    }
  }

  Future<void> signOut() async {
    _logger.info('Signing out user');
    await _auth.signOut();
    _logger.info('User signed out successfully');
  }

  Stream<User?> get user => _auth.authStateChanges();
}
