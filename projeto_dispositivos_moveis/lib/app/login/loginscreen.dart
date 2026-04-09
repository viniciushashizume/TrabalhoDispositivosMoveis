import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0), //adiciona um padding ao redor do conteúdo
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField( //campo de email
              onChanged: (value) => setState(() => email = value),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField( //campo de senha
              onChanged: (value) => setState(() => password = value),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true, //oculta a senha
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (email == 'user@example.com' && password == 'password') { //teste
                  context.go(Routes.home); 
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}