import 'package:go_router/go_router.dart';
import 'package:projeto_dispositivos_moveis/app/app.dart';
import 'package:projeto_dispositivos_moveis/app/features/login/loginscreen.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_screen.dart';
import 'package:provider/provider.dart';
import 'package:projeto_dispositivos_moveis/app/features/history/history_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/signup/signupscreen.dart';
import 'package:projeto_dispositivos_moveis/app/features/settings/settings_screen.dart';

final class Routes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const checkin = '/checkin';
  static const diaryentry = '/diaryentry';
  static const history = '/history';
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
    GoRoute(
      path: Routes.checkin,
      builder: (context, state) => CheckinScreen(
        checkinViewmodel: context.read(),
      ),
    ),
    GoRoute(
      path: Routes.history,
      builder: (context, state) => HistoryScreen(
        checkinViewmodel: context.read(),
      ),
    )
  ],
);