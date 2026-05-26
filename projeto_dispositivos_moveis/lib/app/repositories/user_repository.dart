import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_dispositivos_moveis/app/services/auth_service.dart';

class EmailAlreadyRegisteredException implements Exception {}

class UserRepository extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;

  UserRepository(this._authService);

  bool get isUserLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;

  Future<void> checkIfUserIsLoggedIn() async {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> registerUser(String email, String password) async {
    late final AuthResponse response;

    try {
      response = await _authService.signUp(email: email, password: password);
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('already') || message.contains('registered')) {
        throw EmailAlreadyRegisteredException();
      }
      rethrow;
    }

    if (response.user?.identities?.isEmpty ?? false) {
      throw EmailAlreadyRegisteredException();
    }

    _currentUser = response.user;
    notifyListeners();
  }

  Future<void> loginUser(String email, String password) async {
    final response = await _authService.signIn(
      email: email,
      password: password,
    );
    _currentUser = response.user;
    notifyListeners();
  }

  Future<void> logoutUser() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
