import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:projeto_dispositivos_moveis/app/features/login/loginscreen.dart';
import 'package:projeto_dispositivos_moveis/app/features/login/login_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/history/history_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/settings/settings_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/settings/settings_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/register/register_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/register/register_viewmodel.dart';

final _rootNavigatorKey =
    GlobalKey<
      NavigatorState
    >(); //chave para o navegador raiz, permitindo controle global da navegação

final class Routes {
  static const login = '/login';
  static const checkin = '/checkin';
  static const diary = '/diary';
  static const history = '/history';
  static const settings = '/settings';
  static const register = '/register';
}

// bottom nav bar com as opções de check-in e histórico
//stateful navigation permite que os estados sejam mantidos entre a transição
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell
  navigationShell; //recebe o estado da navegação para manter o controle das abas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Diário',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.login,
  routes: [
    GoRoute(
  path: Routes.login,
  builder: (context, state) => LoginScreen(
    loginViewModel: context.read<LoginViewModel>(),
  ),
),
    // NOVA ROTA DE CADASTRO AQUI (Fora do menu de navegação)
    GoRoute(
      path: Routes.register,
      builder: (context, state) => RegisterScreen(
        registerViewModel: context.read<RegisterViewModel>(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // BRANCH 1: CHECK-IN
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.checkin,
              builder: (context, state) =>
                  CheckinScreen(checkinViewmodel: context.read()),
            ),
          ],
        ),

        // BRANCH 2: DIÁRIO
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.diary,
              builder: (context, state) => DiaryScreen(
                diaryViewModel: context.read<DiaryViewModel>(),
              ),
            ),
          ],
        ),

        // BRANCH 3: HISTÓRICO
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, state) => HistoryScreen(
                checkinViewmodel: context.read(),
                diaryViewModel: context.read<DiaryViewModel>(),
              ),
            ),
          ],
        ),
        
        // BRANCH 4: CONFIGURAÇÕES
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) =>
                  SettingsScreen(viewModel: context.read<SettingsViewModel>()),
            ),
          ],
        ),
      ],
    ),
  ],
);