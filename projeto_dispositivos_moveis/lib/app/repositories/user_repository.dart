import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_dispositivos_moveis/app/services/auth_service.dart';
class EmailAlreadyRegisteredException implements Exception {}
class UserRepository extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;

  UserRepository(this._authService);

  bool get isUserLoggedIn => _currentUser != null; // verfica se o user esta logado e autenticado
  User? get currentUser => _currentUser; // retorna o user atual ou null se não houver nenhum logado

  Future<void> checkIfUserIsLoggedIn() async {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> registerUser(String email, String password) async {
    final response = await _authService.signUp(
      email: email,
      password: password,
    );
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
