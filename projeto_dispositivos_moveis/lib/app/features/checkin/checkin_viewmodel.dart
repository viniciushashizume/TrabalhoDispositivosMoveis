import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/checkin_repository.dart';

class CheckinViewmodel extends ChangeNotifier { //viewmodel para gerenciar o estado da tela de checkin
  bool isSaved = false;
  bool isSaving = false;
  List<CheckIn> checkins = [];
  final CheckinRepository checkinRepository;

  CheckinViewmodel({required this.checkinRepository});

  void load() async { //carrega os checkins da "api"
    checkins = await checkinRepository.loadCheckins();
    notifyListeners();
  }

  void saveCheckin(CheckIn checkin) async {
    isSaving = true;
    notifyListeners();

    await checkinRepository.addCheckin(checkin); //salva o checkin e espera a resposta da "api"

    isSaved = true;
    isSaving = false;
    notifyListeners();
    isSaved = false;
    load();
  }
}