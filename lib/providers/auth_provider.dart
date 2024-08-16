import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthProvider');

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _logger.info('Initializing AuthProvider');
    _authService.user.listen((user) {
      _logger.info('Auth state changed. User: ${user?.uid}');
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String nip, String password) async {
    try {
      _logger.info('Attempting to sign in with NIP: $nip');
      _user = await _authService.signInWithNipAndPassword(nip, password);
      _logger.info('Sign in result. User: ${_user?.uid}');
      notifyListeners();
      return _user != null;
    } catch (e) {
      _logger.severe('Sign in failed', e);
      _logger.info(
          'Detailed error in AuthProvider: $e'); // This will print the full error message
      return false;
    }
  }

  Future<void> signOut() async {
    _logger.info('Signing out user');
    await _authService.signOut();
    _user = null;
    notifyListeners();
    _logger.info('User signed out successfully');
  }
}
