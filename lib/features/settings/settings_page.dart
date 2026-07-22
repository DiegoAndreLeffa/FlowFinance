import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/database/database_service.dart';
import '../../core/security/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseService _databaseService = DatabaseService();
  String _statusMessage = 'Pronto para gerenciar seus dados.';

  Future<void> _exportData() async {
    try {
      final payload = await _databaseService.exportToJson();
      
      final List<int> bytes = utf8.encode(payload);
      final date = DateTime.now().toIso8601String().split('T').first;
      final fileName = 'flowfinance_backup_$date.json';

      final xFile = XFile.fromData(
        Uint8List.fromList(bytes),
        name: fileName,
        mimeType: 'application/json',
      );

      final result = await Share.shareXFiles(
        [xFile],
        text: 'Backup FlowFinance - $date',
      );

      if (result.status == ShareResultStatus.success) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Backup salvo com sucesso!';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao exportar: $e';
      });
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final payload = utf8.decode(result.files.single.bytes!);

        if (payload.isEmpty) return;

        await _databaseService.importFromJson(payload);

        if (!mounted) return;
        setState(() {
          _statusMessage = 'Dados restaurados com sucesso!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restaurado! Volte à tela inicial para ver os dados.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _statusMessage = 'Importação cancelada.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao importar: O arquivo é inválido ou está corrompido.';
      });
    }
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
                    label: const Text('Exportar Arquivo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importData,
                    icon: const Icon(Icons.download),
                    label: const Text('Restaurar Arquivo'),
                  ),
                ),
              ],
            ),
            const Text('Segurança e Privacidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Proteja seus dados com biometria.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            
            FutureBuilder<bool>(
              future: AuthService().isProtectionEnabled(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.data ?? false;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.fingerprint, color: Colors.blue),
                  title: const Text('Bloqueio por Biometria/PIN'),
                  value: isEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final success = await AuthService().authenticate();
                      if (success) {
                        await AuthService().setProtectionEnabled(true);
                        setState(() {});
                      }
                    } else {
                      await AuthService().setProtectionEnabled(false);
                      setState(() {});
                    }
                  },
                );
              }
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