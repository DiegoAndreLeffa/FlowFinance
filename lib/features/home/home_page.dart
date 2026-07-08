import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/database/database_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/services/smart_input_service.dart';
import '../categories/categories_page.dart';
import '../settings/settings_page.dart';
import 'home_providers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final SmartInputService _smartInputService = SmartInputService();
  final DatabaseService _databaseService = DatabaseService();
  final CategoryDatabaseService _categoryService = CategoryDatabaseService();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isBalanceVisible = true;
  int _initialBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _databaseService.getAllTransactions();
    final categories = await _categoryService.getAllCategories();
    final initialBalance = await _databaseService.getInitialBalance();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _categories = categories;
      _initialBalance = initialBalance;
      _isLoading = false;
    });
  }

  Future<void> _processInput() async {
    final text = _textController.text;
    final result = _smartInputService.parse(text);

    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato inválido. Ex: 15,50 padaria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newTx = TransactionModel(
      amountInCents: result.amountInCents,
      description: result.description,
      date: DateTime.now(),
      type: result.type,
      categoryName: result.categoryName,
    );

    await _databaseService.saveTransaction(newTx);
    await _loadTransactions();

    _textController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Salvo: ${result.description}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _showInitialBalanceDialog() async {
    final controller = TextEditingController(text: (_initialBalance / 100).toStringAsFixed(2));

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Saldo inicial'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Valor inicial'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
                final cents = (value * 100).round();
                await _databaseService.saveInitialBalance(cents);
                if (!context.mounted) return;
                Navigator.pop(context);
                await _loadTransactions();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(TransactionModel transaction) async {
    final descriptionController = TextEditingController(text: transaction.description);
    final valueController = TextEditingController(text: (transaction.amountInCents / 100).toStringAsFixed(2));

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar transação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descrição')),
              TextField(controller: valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final description = descriptionController.text.trim();
                final amount = double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0;
                if (description.isEmpty) return;

                final updatedTransaction = TransactionModel(
                  id: transaction.id,
                  amountInCents: (amount * 100).round(),
                  description: description,
                  date: transaction.date,
                  type: transaction.type,
                  categoryName: transaction.categoryName,
                );

                await _databaseService.updateTransaction(updatedTransaction);
                if (!context.mounted) return;
                Navigator.pop(context);
                await _loadTransactions();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = calculateBalance(_transactions, initialBalance: _initialBalance);
    final monthlyIncome = _transactions.where((tx) => tx.type == 'income').fold<int>(0, (sum, tx) => sum + tx.amountInCents.abs());
    final monthlyExpense = _transactions.where((tx) => tx.type == 'expense').fold<int>(0, (sum, tx) => sum + tx.amountInCents.abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowFinance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isBalanceVisible = !_isBalanceVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: _showInitialBalanceDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesPage()),
              );
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
                const Text('Saldo Atual', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  _isBalanceVisible ? formatCurrency(currentBalance) : 'R\$ •••••',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: currentBalance < 0 ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gasto no mês', style: TextStyle(color: Colors.red)),
                            Text(formatCurrency(monthlyExpense), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recebido no mês', style: TextStyle(color: Colors.green)),
                            Text(formatCurrency(monthlyIncome), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(
                        child: Text('Nenhuma transação hoje.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          final category = _categories.firstWhere(
                            (item) => item.name == tx.categoryName,
                            orElse: () => CategoryModel(name: 'Sem categoria', colorHex: 'FF9E9E9E', iconName: 'category'),
                          );

                          return Dismissible(
                            key: ValueKey(tx.id == 0 ? '${tx.description}-${tx.date.toIso8601String()}' : tx.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await _databaseService.deleteTransaction(tx.id);
                              await _loadTransactions();
                            },
                            child: ListTile(
                              onTap: () => _showEditDialog(tx),
                              leading: CircleAvatar(
                                backgroundColor: Color(int.parse(category.colorHex, radix: 16)).withValues(alpha: 0.1),
                                child: Icon(Icons.category_outlined, color: Color(int.parse(category.colorHex, radix: 16))),
                              ),
                              title: Text(tx.description),
                              subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}${tx.categoryName != null ? ' • ${tx.categoryName}' : ''}'),
                              trailing: Text(
                                _isBalanceVisible ? formatCurrency(tx.amountInCents) : 'R\$ •••••',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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