import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/diary.dart';

class DiaryViewModel extends ChangeNotifier {
  bool isSaving = false;
  bool isSaved = false;

  void saveDiary(Diary diary) async {
    isSaving = true;
    isSaved = false;
    notifyListeners();

    // TODO: Integração futura do backend (NLP e banco de dados).
    await Future.delayed(const Duration(seconds: 1)); // Mock de rede

    isSaving = false;
    isSaved = true;
    notifyListeners();

    // Reseta o estado para evitar disparos múltiplos de SnackBar
    isSaved = false;
  }
}