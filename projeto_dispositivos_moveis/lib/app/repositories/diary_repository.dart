import 'package:projeto_dispositivos_moveis/app/models/diary.dart';

class DiaryRepository {
  final List<Diary> _diaries = [];

  Future<List<Diary>> loadDiaries() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay da API
    return List.from(_diaries);
  }

  Future<void> addDiary(Diary diary) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay de rede
    _diaries.add(diary);
  }
}