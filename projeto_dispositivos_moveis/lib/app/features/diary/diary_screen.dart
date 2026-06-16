import 'package:flutter/material.dart';
import 'diary_viewmodel.dart';

class DiaryScreen extends StatefulWidget {
  final DiaryViewModel diaryViewModel;

  const DiaryScreen({Key? key, required this.diaryViewModel}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  void initState() {
    super.initState();
    widget.diaryViewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.diaryViewModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Diário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: vm.clearText,
            tooltip: 'Limpar texto',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              vm.isListening
                  ? "Ouvindo..."
                  : vm.speechEnabled
                  ? "Digite ou toque no microfone para falar"
                  : "Reconhecimento de voz indisponível",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: vm.textController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Como foi o seu dia? Escreva ou grave aqui...",
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (vm.textController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('O diário está vazio!')),
                    );
                    return;
                  }

                  bool success = await vm.saveDiary();

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diário registrado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006666),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Registrar Diário', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: vm.speechEnabled ? vm.toggleRecording : null,
        backgroundColor: vm.isListening ? Colors.red : Colors.blue,
        child: Icon(
          vm.isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}