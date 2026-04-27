import 'package:projeto_dispositivos_moveis/app/models/user.dart';

class UserRepository {
  final List<User> _users = [];

  Future<void> addUser(User user) async {
    // Simula o tempo de requisição da API
    await Future.delayed(const Duration(milliseconds: 500)); 
    _users.add(user);
  }

  Future<List<User>> loadUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_users);
  }
}