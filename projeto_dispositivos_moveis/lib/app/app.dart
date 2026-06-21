import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/checkin_repository.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/diary_repository.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/settings/settings_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart';
import 'package:projeto_dispositivos_moveis/app/features/register/register_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/login/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final GoRouter router;

  MyApp({super.key, required this.userRepository})
    : router = createRouter(userRepository);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>.value(value: userRepository),
        Provider<CheckinRepository>(create: (context) => CheckinRepository()),
        Provider<DiaryRepository>(create: (context) => DiaryRepository()),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) =>
              RegisterViewModel(userRepository: context.read()),
        ),
        ChangeNotifierProvider<CheckinViewmodel>(
          create: (context) =>
              CheckinViewmodel(checkinRepository: context.read()),
        ),
        ChangeNotifierProvider<DiaryViewModel>(
          create: (context) => DiaryViewModel(diaryRepository: context.read()),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(userRepository: context.read()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ListenableBuilder(
            listenable: context.watch<SettingsViewModel>(),
            builder: (context, child) {
              final settingsVM = context.read<SettingsViewModel>();

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Saúde Mental Monitor',
                themeMode: settingsVM.darkModeEnabled
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.cyan,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.cyan,
                  brightness: Brightness.dark,
                ),
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saúde Mental Monitor')),
      body: const Center(child: Text('Bem-vindo ao Saúde Mental Monitor!')),
    );
  }
}
