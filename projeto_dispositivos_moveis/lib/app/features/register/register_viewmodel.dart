import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/user.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  bool isSaved = false;
  bool isSaving = false;
  final UserRepository userRepository;

  RegisterViewModel({required this.userRepository});

  void saveUser(User user) async {
    isSaving = true;
    notifyListeners();

    await userRepository.addUser(user);

    isSaved = true;
    isSaving = false;
    notifyListeners();
    isSaved = false; // Reseta o estado para os próximos cadastros
  }
}