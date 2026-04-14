import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/checkin_repository.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider prepara a base para a injeção de dependências
    return MultiProvider(
      providers: [
        Provider<CheckinRepository>(
          create: (context) => CheckinRepository(),
        ),
        ChangeNotifierProvider<CheckinViewmodel>(
          create: (context) => CheckinViewmodel(
            checkinRepository: context.read(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Saúde Mental Monitor',
            theme: ThemeData(primaryColor: Colors.cyan),
            routerConfig: routes, // go_router
          );
        },
      ),
    );
  }
}

// HomePage mantida aqui temporariamente (ideal é mover para lib/app/home/home_page.dart)
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

/*import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Saúde Mental Monitor',
      theme: ThemeData(primaryColor: Colors.cyan),
      routerConfig: routes, 
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
}*/