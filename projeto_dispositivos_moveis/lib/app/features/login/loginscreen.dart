import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';
import 'package:projeto_dispositivos_moveis/app/features/login/login_viewmodel.dart'; // Importe a ViewModel

class LoginScreen extends StatefulWidget {
  final LoginViewModel loginViewModel;

  const LoginScreen({super.key, required this.loginViewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String email = '';
  String password = '';

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      //chamada do metodo da vm
      final sucesso = await widget.loginViewModel.login(email, password);

      if (mounted) {
        if (sucesso) {
          context.go(Routes.checkin);
        } else {
          //exibe o erro caso o login falhe, usando o errorMessage da ViewModel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.loginViewModel.errorMessage ?? 'Erro ao fazer login!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //listenable para escutar ass mudanças da vm
        return ListenableBuilder(
      listenable: widget.loginViewModel,
      builder: (context, child) {
        final isLoading = widget.loginViewModel.isLoading;

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
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); //validcao regex
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
      },
    );
  }
}