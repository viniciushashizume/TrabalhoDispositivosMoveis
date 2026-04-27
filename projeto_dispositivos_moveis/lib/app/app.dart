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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CheckinRepository>(create: (context) => CheckinRepository()),
        Provider<DiaryRepository>(create: (context) => DiaryRepository()),
        Provider<UserRepository>(create: (context) => UserRepository()),
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
      ],
      child: Builder(
        builder: (context) {
          // O ListenableBuilder "escuta" as mudanças na SettingsViewModel
          return ListenableBuilder(
            listenable: context.watch<SettingsViewModel>(),
            builder: (context, child) {
              final settingsVM = context.read<SettingsViewModel>();

              return MaterialApp.router(
                debugShowCheckedModeBanner: false, // Tira a faixa de debug
                title: 'Saúde Mental Monitor',

                // LÓGICA DO TEMA:
                // Se darkModeEnabled for true, usa ThemeMode.dark, senão ThemeMode.light
                themeMode: settingsVM.darkModeEnabled
                    ? ThemeMode.dark
                    : ThemeMode.light,

                // Configuração do Tema Claro
                theme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.cyan,
                  brightness: Brightness.light,
                ),

                // Configuração do Tema Escuro
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.cyan,
                  brightness: Brightness.dark,
                ),

                routerConfig: routes,
              );
            },
          );
        },
      ),
    );
  }
}

// HomePage mantida aqui temporariamente
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
