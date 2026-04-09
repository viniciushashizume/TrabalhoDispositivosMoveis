import 'package:go_router/go_router.dart';
import 'package:projeto_dispositivos_moveis/app/app.dart';
import 'package:projeto_dispositivos_moveis/app/login/loginscreen.dart';

final class Routes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const checkin = '/checkin';
  static const diaryentry = '/diaryentry';
}

final routes = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);