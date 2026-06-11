import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/services/smart_input_service.dart';

final showBalanceProvider = StateProvider<bool>((ref) => true);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final SmartInputService _smartInputService = SmartInputService();

  void _processInput() {
    final text = _textController.text;
    final result = _smartInputService.parse(text);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sucesso! Descrição: ${result.description} | Centavos: ${result.amountInCents}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _textController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor e uma descrição. Ex: 15,50 padaria'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBalanceVisible = ref.watch(showBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowFinance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isBalanceVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              ref.read(showBalanceProvider.notifier).state = !isBalanceVisible;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Saldo Atual',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  isBalanceVisible ? 'R\$ 1.250,00' : 'R\$ •••••',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Nenhuma transação hoje.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: TextField(
                controller: _textController,
                autofocus: true,
                onSubmitted: (_) => _processInput(),
                decoration: InputDecoration(
                  hintText: 'Ex: 15,50 padaria...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _processInput,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
