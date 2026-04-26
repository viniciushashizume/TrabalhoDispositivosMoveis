import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/features/settings/settings_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/routes.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const SettingsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configurações'), centerTitle: true),
          body: ListView(
            children: [
              const _SectionHeader(title: 'Preferências'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notificações Diárias'),
                subtitle: const Text('Lembrete para fazer seu check-in'),
                value: viewModel.notificationsEnabled,
                onChanged: viewModel.toggleNotifications,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Modo Escuro'),
                value: viewModel.darkModeEnabled,
                onChanged: viewModel.toggleDarkMode,
              ),
              const Divider(),
              const _SectionHeader(title: 'Conta'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                subtitle: const Text('vini@email.com'),
                onTap: () {}, // Futura implementação
              ),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text('Sair', style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => context.go(Routes.login),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}