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
      QuerySnapshot query = await _firestore
          .collection('teachers')
          .where('nip', isEqualTo: nip)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No user found with this NIP');
      }

      String email = query.docs.first['email'];

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      _logger.warning('Sign in failed', e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
}