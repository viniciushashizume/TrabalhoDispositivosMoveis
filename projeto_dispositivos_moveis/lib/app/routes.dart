import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:projeto_dispositivos_moveis/app/features/login/loginscreen.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/history/history_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_screen.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_viewmodel.dart';

final _rootNavigatorKey =
    GlobalKey<
      NavigatorState
    >(); //chave para o navegador raiz, permitindo controle global da navegação

final class Routes {
  static const login = '/login';
  static const checkin = '/checkin';
  static const diary = '/diary';
  static const history = '/history';
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
            // Novo item de menu
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Diário',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}

final routes = GoRouter(
  //definição das rotas da aplicação
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.checkin,
              builder: (context, state) =>
                  CheckinScreen(checkinViewmodel: context.read()),
            ),
          ],
        ),
        // ADICIONE ESTE BRANCH DO DIÁRIO:
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.diary,
              builder: (context, state) => DiaryScreen(
                // Como o DiaryViewModel não está no MultiProvider global,
                // instanciamos ele aqui ou adicionamos no MultiProvider do app.dart
                diaryViewModel: DiaryViewModel(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, state) =>
                  HistoryScreen(checkinViewmodel: context.read()),
            ),
          ],
        ),
      ],
    ),
  ],
);
