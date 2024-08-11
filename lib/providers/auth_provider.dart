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
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String nip, String password) async {
    try {
      _user = await _authService.signInWithNipAndPassword(nip, password);
      notifyListeners();
      return _user != null;
    } catch (e) {
      _logger.warning('Sign in failed', e);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}