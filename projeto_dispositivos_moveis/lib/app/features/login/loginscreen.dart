import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Necessário para acessar o UserRepository
import 'package:projeto_dispositivos_moveis/app/routes.dart';
import 'package:projeto_dispositivos_moveis/app/repositories/user_repository.dart'; // Importe o seu repositório

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String email = '';
  String password = '';
  bool isLoading = false; // Controla o estado de carregamento do botão

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Busca a lista de usuários salvos no repositório
      final userRepository = context.read<UserRepository>();
      final users = await userRepository.loadUsers();

      // Verifica se existe algum usuário com o email e senha correspondentes
      bool usuarioValido = users.any(
        (user) => user.email == email && user.password == password,
      );

      // O mounted verifica se a tela ainda está aberta antes de atualizar a UI
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (usuarioValido) {
          context.go(Routes.checkin);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou senha incorretos!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                onChanged: (value) => email = value.trim(),
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira um email.';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Insira um email válido.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true, 
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira uma senha.';
                  if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _fazerLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(Routes.register),
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}