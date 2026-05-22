import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/app.dart';
import 'package:projeto_dispositivos_moveis/app/services/auth_service.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lqohakxrpwxzbeyndols.supabase.co',
    anonKey: 'sb_publishable_XoxeDqXaCa04_TlxZl02Fg_J2Dq7PmP',
  );

  final authService = AuthService();
  final userRepository = UserRepository(authService);
  
  await userRepository.checkIfUserIsLoggedIn();

  runApp(MyApp(userRepository: userRepository));
}