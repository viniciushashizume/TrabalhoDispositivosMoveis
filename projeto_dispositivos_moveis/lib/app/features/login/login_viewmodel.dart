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
      final users = await userRepository.loadUsers();

      bool isValid = users.any(
        (user) => user.email == email && user.password == password, // verifica se o user existe
      );

      isLoading = false; // atualiza o estado de carregamento
      if (!isValid) {
        errorMessage = 'Email ou senha incorretos!'; //
      }
      notifyListeners(); // notifica a UI sobre as mudanças

      return isValid;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Ocorreu um erro ao tentar fazer o login.';
      notifyListeners();
      return false;
    }
  }
}