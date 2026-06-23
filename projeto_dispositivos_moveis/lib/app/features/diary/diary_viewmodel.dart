import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../repositories/diary_repository.dart';
import '../../models/diary.dart';
import '../../services/api_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryViewModel extends ChangeNotifier {
  final DiaryRepository diaryRepository;
  final ApiService apiService = ApiService();

  List<Diary> diaries = [];
  bool isLoaded = false;

  final TextEditingController textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  String _textBeforeRecording = "";

  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;

  DiaryViewModel({required this.diaryRepository}) {
    _initSpeech();
  }

  Future<void> load() async {
    isLoaded = false;
    notifyListeners();

    try {
      diaries = await diaryRepository.loadDiaries();
    } catch (e) {
      print("Erro ao carregar diários: $e");
    }

    isLoaded = true;
    notifyListeners();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (error) => print('Erro no microfone: $error'),
    );
    notifyListeners();
  }

  void startListening() async {
    _textBeforeRecording = textController.text;
    if (_textBeforeRecording.isNotEmpty && !_textBeforeRecording.endsWith(' ')) {
      _textBeforeRecording += ' ';
    }

    await _speechToText.listen(
      onResult: (result) {
        textController.text = _textBeforeRecording + result.recognizedWords;

        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
        notifyListeners();
      },
      localeId: 'pt_BR',
    );
    _isListening = true;
    notifyListeners();
  }

  void stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void toggleRecording() {
    if (_speechToText.isNotListening) {
      startListening();
    } else {
      stopListening();
    }
  }

  void clearText() {
    textController.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> saveDiary() async {
    final text = textController.text.trim();
    if (text.isEmpty) return null;

    try {
      // 1. Salva no banco de dados (Supabase)
      final newDiary = Diary(
        content: text,
        date: DateTime.now(),
      );

      final idGerado = await diaryRepository.addDiary(newDiary);
      final email = Supabase.instance.client.auth.currentUser?.email;

      // 2. Chama a API de IA Python com os dados do registro
      final predictionResult = await apiService.analyzeDiary(
        text,
        userEmail: email,
        idRegistro: idGerado,
        tipo: 'diario',
      );

      // 3. Atualiza os dados da tela
      await load();

      clearText();
      
      // Retorna a predição
      return predictionResult ?? {}; 
    } catch (e) {
      print("Erro ao salvar diário: $e");
      return null;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}