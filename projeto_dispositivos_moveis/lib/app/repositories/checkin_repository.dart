import 'dart:collection';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';

class CheckinRepository {
  final List<CheckIn> _checkinsList = [];

  UnmodifiableListView<CheckIn> get checkins =>
      UnmodifiableListView(_checkinsList);

  Future<void> addCheckin(CheckIn checkin) async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); //"simulacao" de tempo de requisição da api
    
    _checkinsList.add(checkin);
  }

  Future<List<CheckIn>> loadCheckins() async {
    await Future.delayed(const Duration(seconds: 2));
    return checkins;
  }
}
