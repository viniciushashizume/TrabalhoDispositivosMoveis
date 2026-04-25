import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/app/models/diary.dart';
import 'package:projeto_dispositivos_moveis/app/features/diary/diary_viewmodel.dart';

class DiaryScreen extends StatefulWidget {
  final DiaryViewModel diaryViewModel;

  const DiaryScreen({super.key, required this.diaryViewModel});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.diaryViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.diaryViewModel.removeListener(_onUpdate);
    _textController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (widget.diaryViewModel.isSaved) {
      FocusScope.of(context).unfocus(); // Oculta o teclado
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Diário salvo com sucesso!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      _textController.clear(); // Limpa o campo após salvar
    }
  }

  void _submitDiary() {
    if (_textController.text.trim().isEmpty) return;

    final diary = Diary(
      text: _textController.text.trim(),
      date: DateTime.now(),
    );

    widget.diaryViewModel.saveDiary(diary);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.diaryViewModel;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Diário'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Como foi o seu dia?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sinta-se livre para desabafar. Este espaço é seu.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Ocultar o campo visualmente para ocupar todo o espaço vertical
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null, 
                    expands: true,  
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Comece a escrever aqui...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: vm.isSaving ? null : _submitDiary,
                  icon: vm.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.book),
                  label: Text(
                    vm.isSaving ? 'Salvando...' : 'Salvar Diário',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
}