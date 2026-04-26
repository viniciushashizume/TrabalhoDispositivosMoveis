import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/diary.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/diary_repository.dart';

class DiaryViewModel extends ChangeNotifier {
  bool isLoaded = false;
  bool isSaved = false;
  bool isSaving = false;
  List<Diary> diaries = [];
  final DiaryRepository diaryRepository;

  DiaryViewModel({required this.diaryRepository});

  void load() async {
    isLoaded = false; // Força o loading para aparecer na tela igual no checkin
    notifyListeners();
    diaries = await diaryRepository.loadDiaries();
    isLoaded = true;
    notifyListeners();
  }

  void saveDiary(Diary diary) async {
    isSaving = true;
    notifyListeners();

    await diaryRepository.addDiary(diary);

    isSaved = true;
    isSaving = false;
    notifyListeners();
    isSaved = false;
    load(); // Recarrega a lista após salvar
  }
}