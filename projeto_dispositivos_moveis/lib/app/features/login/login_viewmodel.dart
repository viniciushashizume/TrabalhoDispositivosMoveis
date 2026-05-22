import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  bool isLoading = false;
  String? errorMessage;

  LoginViewModel({required this.userRepository});

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await userRepository.loginUser(email, password);
      isLoading = false; 
      notifyListeners(); 
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Email ou senha incorretos!';
      notifyListeners();
      return false;
    }
  }
}