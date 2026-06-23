import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/checkin_repository.dart';
import 'package:projeto_dispositivos_moveis/app/services/api_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinViewmodel extends ChangeNotifier {
  bool isLoaded = false;
  bool isSaved = false;
  bool isSaving = false;
  String? errorMessage; 
  List<CheckIn> checkins = [];
  final CheckinRepository checkinRepository;
  final ApiService apiService = ApiService();

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

  int _parseInteracaoSocial(String interacao) {
    if (interacao.contains("Isolado")) return 0;
    if (interacao.contains("Muito")) return 2;
    return 1;
  }

  Future<Map<String, dynamic>?> saveCheckin(CheckIn checkin) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    
    Map<String, dynamic>? predictionResult;

    try {
      final idGerado = await checkinRepository.addCheckin(checkin);
      final email = Supabase.instance.client.auth.currentUser?.email;

      predictionResult = await apiService.analyzeDiary(
        "Registro quantitativo diário de saúde mental",
        humor: checkin.humor,
        horasSono: checkin.horasSono.toInt(),
        nivelEstresse: checkin.nivelEstresse,
        atividadeFisica: checkin.atividadeFisica ? 1 : 0,
        interacaoSocial: _parseInteracaoSocial(checkin.interacaoSocial),
        userEmail: email,
        idRegistro: idGerado,
        tipo: 'checkin',
      );

      isSaved = true;
    } catch (e) {
      errorMessage = 'Erro ao guardar check-in: $e';
      isSaved = false;
    }

    isSaving = false;
    notifyListeners();
    isSaved = false;

    await load();
    return predictionResult;
  }
}
