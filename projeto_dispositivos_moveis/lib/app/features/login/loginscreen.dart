import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Certifique-se de que o import abaixo aponta corretamente para o seu arquivo de rotas
import 'package:projeto_dispositivos_moveis/app/routes.dart';

// Vetor simulando o banco de dados inicial (Mock do Backend)
// Isso permite que você teste o frontend agora. Depois, seu parceiro
// substituirá essa consulta por uma chamada ao backend/banco de dados real.
final List<Map<String, String>> usuariosMock = [
  {'email': 'teste@teste.com', 'senha': 'password123'},
  {'email': 'a@a.com', 'senha': '123456'},
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave global para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();
  
  String email = '';
  String password = '';

  void _fazerLogin() {
    // Valida os campos usando os validators dos TextFormFields
    if (_formKey.currentState!.validate()) {
      
      // Busca no vetor se existe a combinação de email e senha
      bool usuarioValido = usuariosMock.any(
        (user) => user['email'] == email && user['senha'] == password,
      );

      if (usuarioValido) {
        context.go(Routes.checkin); // Vai para a tela de check-in caso encontre
      } else {
        // Exibe um erro na interface se as credenciais não baterem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou senha incorretos!'),
            backgroundColor: Colors.red,
          ),
        );
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
          key: _formKey, // Atribui a chave ao Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                onChanged: (value) => email = value.trim(),
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um email.';
                  }
                  // Regex para validação do formato de email
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Insira um email válido.';
                  }
                  return null; // Retorna null se estiver tudo ok
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha.';
                  }
                  // Controle do tamanho mínimo da senha
                  if (value.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _fazerLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}