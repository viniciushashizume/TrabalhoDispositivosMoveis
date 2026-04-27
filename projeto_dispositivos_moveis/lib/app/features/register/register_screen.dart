import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_dispositivos_moveis/app/models/user.dart';
import 'package:projeto_dispositivos_moveis/app/features/register/register_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';

class RegisterScreen extends StatefulWidget {
  final RegisterViewModel registerViewModel;

  const RegisterScreen({super.key, required this.registerViewModel});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.registerViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.registerViewModel.removeListener(_onUpdate);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (widget.registerViewModel.isSaved) {
      FocusScope.of(context).unfocus(); // Oculta o teclado
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuário cadastrado com sucesso!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      _emailController.clear();
      _passwordController.clear();
      
      // Volta para a tela de login após o sucesso
      context.go(Routes.login);
    }
  }

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      widget.registerViewModel.saveUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.registerViewModel;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Criar Conta'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cadastre-se',
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
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                    onPressed: vm.isSaving ? null : _submitRegister,
                    icon: vm.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_outlined),
                    label: Text(
                      vm.isSaving ? 'Salvando...' : 'Cadastrar',
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
                    onPressed: () => context.go(Routes.login),
                    child: const Text('Já tenho uma conta. Fazer login.'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}