import 'dart:collection';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';

class CheckinRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<CheckIn> _checkinsList = [];

  UnmodifiableListView<CheckIn> get checkins =>
      UnmodifiableListView(_checkinsList); // deixa a lista para ficar apenas no modo read, sem poder ser modificada sem ser usando os metodos

  Future<void> addCheckin(CheckIn checkin) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }

    // converte o objeto para o formato JSON do banco
    final data = checkin.toJson();
    data.remove(
      'id',
    ); // remover o id nulo para o Supabase gerar um UID automaticamente
    data['user_id'] = user.id; //associa a submissão ao user

    await _supabase.from('checkins').insert(data);
  } 

  Future<List<CheckIn>> loadCheckins() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // vai buscar à nuvem e ordena do mais recente para o mais antigo
    final response = await _supabase
        .from('checkins')
        .select()
        .eq('user_id', user.id)
        .order('data', ascending: false);

    _checkinsList = response.map((json) => CheckIn.fromJson(json)).toList();
    return _checkinsList;
  }
}
