import 'dart:collection';

import 'package:projeto_dispositivos_moveis/app/models/diary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Diary> _diaries = [];

  UnmodifiableListView<Diary> get diaries => UnmodifiableListView(_diaries);

  Future<List<Diary>> loadDiaries() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('diaries')
        .select()
        .eq('user_id', user.id)
        .order('date');

    _diaries = response.map((json) => Diary.fromJson(json)).toList();
    return _diaries;
  }

  Future<String> addDiary(Diary diary) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario nao autenticado.');
    }

    final data = diary.toJson();
    data.remove('id');
    data['user_id'] = user.id;

    final response = await _supabase.from('diaries').insert(data).select().single();
    return response['id'].toString();
  }
}
