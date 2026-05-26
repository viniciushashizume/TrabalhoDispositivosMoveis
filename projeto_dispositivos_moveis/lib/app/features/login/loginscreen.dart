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

  // Utilização de controllers para manter o padrão da tela de registo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      // chamada do metodo da vm
      final sucesso = await widget.loginViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (sucesso) {
          context.go(Routes.checkin);
        } else {
          // exibe o erro caso o login falhe, com o mesmo estilo do register_screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.loginViewModel.errorMessage ?? 'Erro ao fazer login!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // listenable para escutar as mudanças da vm
    return ListenableBuilder(
      listenable: widget.loginViewModel,
      builder: (context, child) {
        final isLoading = widget.loginViewModel.isLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Login'), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bem-vindo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira um email.';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // validacao regex
                      if (!emailRegex.hasMatch(value)) return 'Insira um email válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira uma senha.';
                      if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: isLoading ? null : _fazerLogin,
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.login_outlined),
                    label: Text(
                      isLoading ? 'Entrando...' : 'Entrar',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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