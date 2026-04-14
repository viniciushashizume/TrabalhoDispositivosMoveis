import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/checkin.dart';
import 'package:projeto_dispositivos_moveis/app/features/checkin/checkin_viewmodel.dart';

class CheckinScreen extends StatefulWidget {
  final CheckinViewmodel checkinViewmodel;

  const CheckinScreen({
    super.key,
    required this.checkinViewmodel,
  });

  @override
  State<CheckinScreen> createState() => _CheckinScreenState(); //cria o estado da tela de checkin
}

class _CheckinScreenState extends State<CheckinScreen> { //variáveis para armazenar os valores dos inputs da interface
  double humor = 5;
  double horasSono = 8;
  double nivelEstresse = 3;
  bool atividadeFisica = false;
  String interacaoSocial = 'Interações breves';

  final List<String> opcoesInteracao = [
    'Isolado',
    'Interações breves',
    'Muito social',
  ];

  @override
  void initState() {
    super.initState();
    widget.checkinViewmodel.addListener(onUpdate); //listener para observar mudanças quando o check-in for salvo com sucesso 
  }

  @override
  void dispose() { //remove o listener quando a tela for descartada, para nao ficar salvo em memoria
    super.dispose();
  }

  void onUpdate() {
    // quando for salvo, exibe a snackbar 
    if (widget.checkinViewmodel.isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Check-in salvo com sucesso!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void enviar() { //bjeto CheckIn com os valores da interface
    final checkin = CheckIn(
      data: DateTime.now(),
      humor: humor.round(),
      horasSono: horasSono,
      nivelEstresse: nivelEstresse.round(),
      atividadeFisica: atividadeFisica,
      interacaoSocial: interacaoSocial,
    );

    widget.checkinViewmodel.saveCheckin(checkin);

    // valores iniciais de estado
    setState(() {
      humor = 5;
      horasSono = 8;
      nivelEstresse = 3;
      atividadeFisica = false;
      interacaoSocial = 'Interações breves';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vm = widget.checkinViewmodel;

    return ListenableBuilder( //reconstrói a interface quando a vm notificar 
      listenable: vm,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Check-in Diário'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  icon: Icons.mood,
                  title: 'Como está seu humor?',
                  subtitle: 'De 1 (péssimo) a 10 (excelente)',
                  child: Column(
                    children: [
                      Slider(
                        value: humor,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: humor.round().toString(),
                        onChanged: (v) => setState(() => humor = v), //atualiza ea interface é reconstruída para mostrar a mudança
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(' 1', style: theme.textTheme.bodySmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${humor.round()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('10 ', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  icon: Icons.bedtime_outlined,
                  title: 'Horas de Sono',
                  subtitle: 'Quantas horas dormiu na última noite?',
                  child: Column(
                    children: [
                      Slider(
                        value: horasSono,
                        min: 0,
                        max: 24,
                        divisions: 48,
                        label: horasSono.toStringAsFixed(1),
                        onChanged: (v) => setState(() => horasSono = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0h', style: theme.textTheme.bodySmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${horasSono.toStringAsFixed(1)}h',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('24h', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  icon: Icons.whatshot_outlined,
                  title: 'Nível de Estresse / Ansiedade',
                  subtitle: 'De 1 (calmo) a 5 (muito ansioso)',
                  child: Column(
                    children: [
                      Slider(
                        value: nivelEstresse,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: nivelEstresse.round().toString(),
                        onChanged: (v) => setState(() => nivelEstresse = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(' 1', style: theme.textTheme.bodySmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${nivelEstresse.round()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('5', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  icon: Icons.fitness_center,
                  title: 'Atividade Física',
                  subtitle: 'Praticou exercício hoje?',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        atividadeFisica ? 'Sim' : 'Não',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: atividadeFisica
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Switch.adaptive(
                        value: atividadeFisica,
                        onChanged: (v) => setState(() => atividadeFisica = v),
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  icon: Icons.people_outline,
                  title: 'Interação Social',
                  subtitle: 'Como foi seu contato social hoje?',
                  child: Wrap(
                    spacing: 8,
                    children: opcoesInteracao.map((opcao) {
                      final selecionado = interacaoSocial == opcao;
                      return ChoiceChip(
                        label: Text(opcao),
                        selected: selecionado,
                        onSelected: (_) => setState(() => interacaoSocial = opcao),
                        selectedColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: selecionado
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    // Desabilita o botão se a ViewModel estiver salvando
                    onPressed: vm.isSaving ? null : enviar,
                    icon: vm.isSaving
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
                    )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      vm.isSaving ? 'Enviando...' : 'Enviar Check-in',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({ //widget para criar os cards de cada seção do check-in
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}