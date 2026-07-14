import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/database/database_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final DatabaseService _dbService = DatabaseService();
  final CategoryDatabaseService _catService = CategoryDatabaseService();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txs = await _dbService.getAllTransactions();
    final cats = await _catService.getAllCategories();
    
    final now = DateTime.now();
    final thisMonthTxs = txs.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();

    if (!mounted) return;
    setState(() {
      _transactions = thisMonthTxs;
      _categories = cats;
      _isLoading = false;
    });
  }

  List<PieChartSectionData> _getPieChartData() {
    Map<String, int> expensesByCategory = {};
    int totalExpense = 0;

    for (var tx in _transactions) {
      if (tx.type == 'expense') {
        final catName = tx.categoryName ?? 'Sem categoria';
        expensesByCategory[catName] = (expensesByCategory[catName] ?? 0) + tx.amountInCents.abs();
        totalExpense += tx.amountInCents.abs();
      }
    }

    if (totalExpense == 0) return [];

    List<PieChartSectionData> sections = [];
    expensesByCategory.forEach((catName, amount) {
      final category = _categories.firstWhere(
        (c) => c.name == catName, 
        orElse: () => CategoryModel(name: 'Sem categoria', colorHex: 'FF9E9E9E', iconName: 'category')
      );
      final color = Color(int.parse(category.colorHex, radix: 16));
      
      final percentage = (amount / totalExpense) * 100;

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pieData = _getPieChartData();
    final hasExpenses = pieData.isNotEmpty;

    final income = _transactions.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + t.amountInCents.abs());
    final expense = _transactions.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amountInCents.abs());

    return Scaffold(
      appBar: AppBar(title: const Text('Insights do Mês')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Entradas', income, Colors.green),
                _buildSummaryCard('Saídas', expense, Colors.red),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Despesas por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (!hasExpenses)
              const Center(child: Text('Nenhuma despesa este mês.', style: TextStyle(color: Colors.grey)))
            else
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: pieData,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),

            if (hasExpenses)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _getPieChartData().map((section) {
                  final cat = _categories.firstWhere((c) => Color(int.parse(c.colorHex, radix: 16)) == section.color, orElse: () => CategoryModel(name: 'Outros', colorHex: 'FF9E9E9E', iconName: ''));
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 12, color: section.color),
                      const SizedBox(width: 4),
                      Text(cat.name, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int amountInCents, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formatCurrency(amountInCents), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}