import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/user.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  bool isSaving = false;
  bool emailAlreadyRegistered = false;
  String? errorMessage;
  final UserRepository userRepository;

  RegisterViewModel({required this.userRepository});

  Future<bool> saveUser(User user) async {
    isSaving = true;
    emailAlreadyRegistered = false;
    errorMessage = null;
    notifyListeners();

    bool success = false;

    try {
      await userRepository.registerUser(user.email, user.password);
      success = true;
    } on EmailAlreadyRegisteredException {
      emailAlreadyRegistered = true;
      errorMessage = 'O email inserido já está cadastrado.';
    } catch (e) {
      errorMessage = "Erro ao se cadastrar: ${e.toString()}";
    }

    isSaving = false;
    notifyListeners();
    return success; // Retorna true se deu certo, false se deu erro
  }

  void clearEmailError() {
    if (!emailAlreadyRegistered) return;
    emailAlreadyRegistered = false;
    errorMessage = null;
    notifyListeners();
  }
}