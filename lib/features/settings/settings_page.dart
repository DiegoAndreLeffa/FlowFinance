import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseService _databaseService = DatabaseService();
  String _statusMessage = 'Pronto para exportar ou importar os dados.';

  Future<void> _exportData() async {
    final payload = await _databaseService.exportToJson();
    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Dados exportados para a área de transferência.';
    });
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar dados'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Cole o JSON aqui'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final payload = controller.text.trim();
                if (payload.isEmpty) return;
                await _databaseService.importFromJson(payload);
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {
                  _statusMessage = 'Dados importados com sucesso.';
                });
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backup e dados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_statusMessage, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.upload_file),
              label: const Text('Exportar JSON'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _importData,
              icon: const Icon(Icons.download),
              label: const Text('Importar JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
