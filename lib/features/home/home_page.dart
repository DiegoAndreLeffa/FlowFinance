import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/category_icon_mapper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/database/database_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/services/smart_input_service.dart';
import '../categories/categories_page.dart';
import '../settings/settings_page.dart';
import 'home_providers.dart';
import '../../main.dart';

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
  String? _selectedCategoryName;
  String? _filterCategoryName;
  String _selectedPeriod = 'all';
  bool _isIncomeMode = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _scheduleRecurringTransactions() async {
    await _databaseService.syncRecurringTransactions();
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await _databaseService.syncRecurringTransactions();
    final transactions = await _databaseService.getAllTransactions();
    final categories = await _categoryService.getAllCategories();
    final activeCategories = categories.where((category) => category.name.trim().isNotEmpty).toList();
    final initialBalance = await _databaseService.getInitialBalance();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _categories = activeCategories;
      _initialBalance = initialBalance;
      _isLoading = false;
    });
  }

  Future<void> _processInput() async {
    final text = _textController.text;
    final result = _smartInputService.parse(
      text, 
      selectedCategory: _selectedCategoryName,
      isIncomeMode: _isIncomeMode,
    );

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
      id: DateTime.now().millisecondsSinceEpoch,
      amountInCents: result.amountInCents,
      description: result.description,
      date: result.date,
      type: result.type,
      categoryName: result.categoryName,
    );

    await _databaseService.saveTransaction(newTx);
    await _loadTransactions();

    _textController.clear();
    _selectedCategoryName = null;
    if (!mounted) return;
    
    setState(() {
      _isIncomeMode = false; 
    });

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

  Future<void> _showRecurringDialog() async {
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    final frequencyController = TextEditingController(text: 'monthly');
    String? selectedCategoryName = _selectedCategoryName;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova recorrência'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descrição')),
                  TextField(controller: valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor')),
                  TextField(controller: frequencyController, decoration: const InputDecoration(labelText: 'Frequência (daily/weekly/monthly)')),
                  const SizedBox(height: 12),
                  if (_categories.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Sem categoria'),
                          selected: selectedCategoryName == null,
                          onSelected: (_) => setDialogState(() => selectedCategoryName = null),
                        ),
                        ..._categories.map((category) {
                          final isSelected = selectedCategoryName == category.name;
                          return ChoiceChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (_) => setDialogState(() => selectedCategoryName = isSelected ? null : category.name),
                          );
                        }),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () async {
                    final description = descriptionController.text.trim();
                    final amount = double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0;
                    final frequency = frequencyController.text.trim().isEmpty ? 'monthly' : frequencyController.text.trim();
                    if (description.isEmpty || amount <= 0) return;

                    final recurring = RecurringTransactionModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      amountInCents: (amount * 100).round(),
                      description: description,
                      type: 'expense',
                      categoryName: selectedCategoryName,
                      frequency: frequency,
                      startDate: DateTime.now(),
                      nextDueDate: DateTime.now(),
                    );

                    await _databaseService.saveRecurringTransaction(recurring);
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
    final periodTransactions = filterTransactionsByPeriod(_transactions, period: _selectedPeriod);
    final filteredTransactions = filterTransactions(
      periodTransactions,
      categoryName: _filterCategoryName,
      period: _selectedPeriod,
    );
    final currentBalance = calculateBalance(periodTransactions, initialBalance: _initialBalance);
    final monthlyIncome = periodTransactions.where((tx) => tx.type == 'income').fold<int>(0, (sum, tx) => sum + tx.amountInCents.abs());
    final monthlyExpense = periodTransactions.where((tx) => tx.type == 'expense').fold<int>(0, (sum, tx) => sum + tx.amountInCents.abs());

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
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text('FlowFinance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart_outline),
              title: const Text('Resumo & Insights'),
              onTap: () async {
                Navigator.pop(context);
                await context.push('/insights');
                _loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categorias'),
              onTap: () async {
                Navigator.pop(context);
                await context.push('/categories');
                _loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configurações'),
              onTap: () async {
                Navigator.pop(context);
                await context.push('/settings');
                _loadTransactions();
              },
            ),
            
            const Spacer(),
            const Divider(),
            
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier, 
              builder: (context, currentMode, child) {
                final isDark = currentMode == ThemeMode.dark || 
                    (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                
                return SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.amber : Colors.orange),
                  title: const Text('Modo Escuro'),
                  value: isDark,
                  onChanged: (value) {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                    color: currentBalance < 0 ? Colors.red : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _selectedPeriod == 'all',
                      onSelected: (_) => setState(() => _selectedPeriod = 'all'),
                    ),
                    ChoiceChip(
                      label: const Text('Hoje'),
                      selected: _selectedPeriod == 'day',
                      onSelected: (_) => setState(() => _selectedPeriod = 'day'),
                    ),
                    ChoiceChip(
                      label: const Text('Semana'),
                      selected: _selectedPeriod == 'week',
                      onSelected: (_) => setState(() => _selectedPeriod = 'week'),
                    ),
                    ChoiceChip(
                      label: const Text('Mês'),
                      selected: _selectedPeriod == 'month',
                      onSelected: (_) => setState(() => _selectedPeriod = 'month'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                if (_categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: const Text('Todas', overflow: TextOverflow.visible),
                              selected: _filterCategoryName == null,
                              showCheckmark: false,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: _filterCategoryName == null ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                fontWeight: _filterCategoryName == null ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) => setState(() => _filterCategoryName = null),
                            ),
                          ),
                          ..._categories.map((category) {
                            final isSelected = _filterCategoryName == category.name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(category.name, overflow: TextOverflow.visible), 
                                labelPadding: const EdgeInsets.only(left: 4, right: 8),
                                selected: isSelected,
                                showCheckmark: false,
                                avatar: CircleAvatar(
                                  backgroundColor: isSelected 
                                      ? Colors.white.withOpacity(0.2) 
                                      : Color(int.parse(category.colorHex, radix: 16)),
                                  child: Icon(
                                    iconFromCategoryName(category.iconName), 
                                    size: 16, 
                                    color: Colors.white
                                  ),
                                ),
                                selectedColor: Color(int.parse(category.colorHex, radix: 16)),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _filterCategoryName = isSelected ? null : category.name;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
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
                          color: Colors.red.withOpacity(0.15),
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
                : filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma transação encontrada',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seus registros aparecerão aqui.',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final category = _categories.firstWhere(
                            (item) => item.name == tx.categoryName,
                            orElse: () => CategoryModel(name: 'Sem categoria', colorHex: 'FF9E9E9E', iconName: 'category'),
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Dismissible(
                                key: ValueKey(tx.id == 0 ? '${tx.description}-${tx.date.toIso8601String()}' : tx.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red.shade400,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                                ),
                                onDismissed: (_) async {
                                  await _databaseService.deleteTransaction(tx.id);
                                  await _loadTransactions();
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  onTap: () => _showEditDialog(tx),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Color(int.parse(category.colorHex, radix: 16)).withOpacity(0.15),
                                    child: Icon(iconFromCategoryName(category.iconName), color: Color(int.parse(category.colorHex, radix: 16))),
                                  ),
                                  title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')} • ${tx.categoryName ?? 'Outros'}'),
                                  trailing: Text(
                                    _isBalanceVisible ? formatCurrency(tx.amountInCents) : 'R\$ •••••',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16,
                                      color: tx.type == 'income' ? Colors.green : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategoryName == category.name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(category.name, overflow: TextOverflow.visible), 
                                labelPadding: const EdgeInsets.only(left: 4, right: 8),
                                selected: isSelected,
                                showCheckmark: false,
                                avatar: CircleAvatar(
                                  backgroundColor: isSelected 
                                      ? Colors.white.withOpacity(0.2) 
                                      : Color(int.parse(category.colorHex, radix: 16)),
                                  child: Icon(
                                    iconFromCategoryName(category.iconName), 
                                    size: 16, 
                                    color: Colors.white
                                  ),
                                ),
                                selectedColor: Color(int.parse(category.colorHex, radix: 16)),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategoryName = isSelected ? null : category.name;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _isIncomeMode ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isIncomeMode ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: _isIncomeMode ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _isIncomeMode = !_isIncomeMode;
                            });
                          },
                          tooltip: _isIncomeMode ? 'Receita' : 'Despesa',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          onSubmitted: (_) => _processInput(),
                          decoration: InputDecoration(
                            hintText: _isIncomeMode ? 'Ex: 5000 salario' : 'Ex: 15,50 padaria...',
                            hintStyle: TextStyle(color: _isIncomeMode ? Colors.green.shade300 : Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: _isIncomeMode ? Colors.green : Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              color: _isIncomeMode ? Colors.green : Theme.of(context).colorScheme.primary,
                              onPressed: _processInput,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _showRecurringDialog,
                        icon: const Icon(Icons.repeat),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}