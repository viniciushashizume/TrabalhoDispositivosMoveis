import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/user.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  bool isSaved = false;
  bool isSaving = false;
  bool emailAlreadyRegistered = false;
  String? errorMessage;
  final UserRepository userRepository;

  RegisterViewModel({required this.userRepository});

  Future<void> saveUser(User user) async {
    isSaving = true;
    emailAlreadyRegistered = false;
    errorMessage = null;
    notifyListeners();

    try {
      await userRepository.registerUser(user.email, user.password);
      isSaved = true;
    } on EmailAlreadyRegisteredException {
      emailAlreadyRegistered = true;
      errorMessage = 'Email já cadastrado';
      isSaved = false;
    } catch (e) {
      errorMessage = "Erro ao se cadastrar: ${e.toString()}";
      isSaved = false;
    }

    isSaving = false;
    notifyListeners();
    isSaved = false;
  }

  void clearEmailError() {
    if (!emailAlreadyRegistered) return;
    emailAlreadyRegistered = false;
    errorMessage = null;
    notifyListeners();
  }
}
