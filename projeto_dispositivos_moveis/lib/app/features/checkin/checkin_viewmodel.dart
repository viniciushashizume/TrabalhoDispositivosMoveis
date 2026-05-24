import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/checkin_repository.dart';

class CheckinViewmodel extends ChangeNotifier {
  bool isLoaded = false;
  bool isSaved = false;
  bool isSaving = false;
  String? errorMessage; 
  List<CheckIn> checkins = [];
  final CheckinRepository checkinRepository;

  CheckinViewmodel({required this.checkinRepository});

  Future<void> load() async {
    try {
      checkins = await checkinRepository.loadCheckins();
      isLoaded = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Erro ao carregar dados: $e';
    }
    notifyListeners();
  }

  Future<void> saveCheckin(CheckIn checkin) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await checkinRepository.addCheckin(checkin);
      isSaved = true;
    } catch (e) {
      errorMessage = 'Erro ao guardar check-in: $e';
      isSaved = false;
    }

    isSaving = false;
    notifyListeners();
    isSaved = false;

    await load();
  }
}
