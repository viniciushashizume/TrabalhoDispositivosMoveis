import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/user.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  bool isSaved = false;
  bool isSaving = false;
  String? errorMessage; 
  final UserRepository userRepository;

  RegisterViewModel({required this.userRepository});

  Future<void> saveUser(User user) async {
    isSaving = true;
    errorMessage = null; 
    notifyListeners();

    try {
      await userRepository.registerUser(user.email, user.password);
      isSaved = true;
    } catch (e) {
      errorMessage = "Erro ao se cadastrar: ${e.toString()}";
      print(
        errorMessage,
      );
      isSaved = false;
    }

    isSaving = false;
    notifyListeners();
    isSaved = false;
  }
}
