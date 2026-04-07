import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/login/loginscreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saúde Mental Monitor',
      theme: ThemeData(primaryColor: Colors.cyan),
      home: const LoginScreen(),
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
