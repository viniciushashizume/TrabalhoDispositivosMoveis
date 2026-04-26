import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_viewmodel.dart'; // Importe o DiaryViewModel

class HistoryScreen extends StatefulWidget {
  final CheckinViewmodel checkinViewmodel;
  final DiaryViewModel diaryViewModel; // ADICIONE ESTA LINHA

  // ATUALIZE O CONSTRUTOR PARA FICAR EXATAMENTE ASSIM:
  const HistoryScreen({
    super.key,
    required this.checkinViewmodel,
    required this.diaryViewModel, // Adicionado aqui
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.checkinViewmodel.load();
      widget.diaryViewModel.load(); // Aproveite e carregue o diário também
    });
  }

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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Duas abas: Check-ins e Diários
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Check-ins', icon: Icon(Icons.check_circle_outline)),
              Tab(text: 'Diários', icon: Icon(Icons.book_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: Lista de Check-ins
            ListenableBuilder(
              listenable: widget.checkinViewmodel,
              builder: (context, _) {
                final vm = widget.checkinViewmodel;
                if (!vm.isLoaded)
                  return const Center(child: CircularProgressIndicator());
                if (vm.checkins.isEmpty)
                  return const Center(
                    child: Text('Nenhum check-in encontrado.'),
                  );

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.checkins.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final checkin = vm.checkins[vm.checkins.length - 1 - index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(
                            100,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderCard(checkin.data, theme),
                            const Divider(height: 24),
                            _buildAtributoRow(
                              Icons.mood,
                              'Humor',
                              '${checkin.humor} / 10',
                              theme,
                            ),
                            _buildAtributoRow(
                              Icons.whatshot,
                              'Estresse',
                              '${checkin.nivelEstresse} / 5',
                              theme,
                            ),
                            _buildAtributoRow(
                              Icons.bedtime,
                              'Sono',
                              '${checkin.horasSono}h',
                              theme,
                            ),
                            _buildAtributoRow(
                              Icons.fitness_center,
                              'Atividade',
                              checkin.atividadeFisica ? 'Sim' : 'Não',
                              theme,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ABA 2: Lista de Diários
            ListenableBuilder(
              listenable: widget.diaryViewModel,
              builder: (context, _) {
                final vm = widget.diaryViewModel;

                if (!vm.isLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // Agora vai aparecer o loading!
                }

                if (vm.diaries.isEmpty) {
                  return const Center(
                    child: Text('Nenhum diário salvo ainda.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.diaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Mostra o mais recente primeiro
                    final diary = vm.diaries[vm.diaries.length - 1 - index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(_formatarData(diary.date)),
                        subtitle: Text(
                          diary.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(DateTime data, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          _formatarData(data),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAtributoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
