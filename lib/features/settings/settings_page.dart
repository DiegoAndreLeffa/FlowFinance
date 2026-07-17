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
  String _statusMessage = 'Pronto para gerenciar seus dados.';

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

  Future<void> _showClearHistoryDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Apagar Tudo?'),
            ],
          ),
          content: const Text(
            'Tem certeza de que deseja apagar todo o histórico de transações e o saldo inicial?\n\nSuas categorias NÃO serão apagadas.\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim, apagar tudo'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _databaseService.clearAllTransactions(); 
      
      if (!mounted) return;
      setState(() {
        _statusMessage = 'O histórico de transações foi apagado.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backup e Sincronização', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_statusMessage, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Exportar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importData,
                    icon: const Icon(Icons.download),
                    label: const Text('Importar'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            const Text('Zona de Perigo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            const Text('Apague todas as suas transações para começar um mês do zero.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            OutlinedButton.icon(
              onPressed: _showClearHistoryDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Limpar todo o Histórico'),
            ),
          ],
        ),
      ),
    );
  }
}