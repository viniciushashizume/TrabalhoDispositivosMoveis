import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  final CheckinViewmodel checkinViewmodel;

  const HistoryScreen({super.key, required this.checkinViewmodel});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    
    // Diz ao Flutter para esperar a tela terminar de renderizar a primeira vez
    // antes de pedir para a ViewModel carregar os dados e notificar a tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.checkinViewmodel.load();
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
    final vm = widget.checkinViewmodel;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Histórico',
            ), //titulo que sera usado na bottom bar
            centerTitle: true,
          ),
          body: (!vm.isLoaded)
              ? const Center(child: CircularProgressIndicator())
              : vm.checkins.isEmpty
              ? const Center(child: Text('Nenhum registro encontrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.checkins.length,
                  // Trocado o Divider por um SizedBox para dar espaçamento entre os Cards
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final checkin =
                        vm.checkins[vm.checkins.length -
                            1 -
                            index]; //lista invertida --> mostra o mais "recente" (ultima entrada) primeiro

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
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatarData(checkin.data),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildAtributoRow(
                              icon: Icons.mood,
                              label: 'Humor',
                              value: '${checkin.humor} / 10',
                              theme: theme,
                            ),
                            const SizedBox(height: 8),
                            _buildAtributoRow(
                              icon: Icons.whatshot_outlined,
                              label: 'Estresse/Ansiedade',
                              value: '${checkin.nivelEstresse} / 5',
                              theme: theme,
                            ),
                            const SizedBox(height: 8),
                            _buildAtributoRow(
                              icon: Icons.bedtime_outlined,
                              label: 'Horas de Sono',
                              value: '${checkin.horasSono}h',
                              theme: theme,
                            ),
                            const SizedBox(height: 8),
                            _buildAtributoRow(
                              icon: Icons.fitness_center,
                              label: 'Atividade Física',
                              value: checkin.atividadeFisica ? 'Sim' : 'Não',
                              theme: theme,
                            ),
                            const SizedBox(height: 8),
                            _buildAtributoRow(
                              icon: Icons.people_outline,
                              label: 'Interação Social',
                              value: checkin.interacaoSocial,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  // widget para exibnir os atributos dos checkins
  Widget _buildAtributoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
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
    );
  }
}
