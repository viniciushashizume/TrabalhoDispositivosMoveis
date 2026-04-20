import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  final CheckinViewmodel checkinViewmodel;

  const HistoryScreen({
    super.key,
    required this.checkinViewmodel,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    //carrega os checkins --> historico atualizado
    widget.checkinViewmodel.load();
  }

  //formatação de data
  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final min = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$min';
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.checkinViewmodel;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Histórico e Diário'),
            centerTitle: true,
          ),
          body: (!vm.isLoaded)
              ? const Center(
            child: CircularProgressIndicator(), //carregamento dos checkins
          )
              : vm.checkins.isEmpty
              ? const Center(
            child: Text('Nenhum registro encontrado.'),
          )
          // exibe os checkins
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.checkins.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              //exibe o mais recente primeiro
              final checkin = vm.checkins[vm.checkins.length - 1 - index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                      Icons.mood,
                      color: theme.colorScheme.onPrimaryContainer
                  ),
                ),
                title: Text('Humor: ${checkin.humor} | Estresse: ${checkin.nivelEstresse}'),
                subtitle: Text(
                  'Data: ${_formatarData(checkin.data)}\n'
                      'Sono: ${checkin.horasSono}h | Social: ${checkin.interacaoSocial}',
                ),
                isThreeLine: true,
              );
            },
          ),
        );
      },
    );
  }
}