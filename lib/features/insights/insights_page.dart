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
  
  DateTime _selectedDate = DateTime.now();

  final List<String> _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txs = await _dbService.getAllTransactions();
    final cats = await _catService.getAllCategories();
    
    final filteredTxs = txs.where((tx) => 
      tx.date.month == _selectedDate.month && 
      tx.date.year == _selectedDate.year
    ).toList();

    if (!mounted) return;
    setState(() {
      _transactions = filteredTxs;
      _categories = cats;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _isLoading = true;
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _isLoading = true;
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
    _loadData();
  }

  List<PieChartSectionData> _getPieChartData() {
    Map<String, int> expensesByCategory = {};
    int totalExpense = 0;

    for (var tx in _transactions) {
      if (tx.type == 'expense') {
        final catName = tx.categoryName ?? 'Outros';
        expensesByCategory[catName] = (expensesByCategory[catName] ?? 0) + tx.amountInCents.abs();
        totalExpense += tx.amountInCents.abs();
      }
    }

    if (totalExpense == 0) return []; 

    List<PieChartSectionData> sections = [];
    expensesByCategory.forEach((catName, amount) {
      final category = _categories.firstWhere(
        (c) => c.name == catName, 
        orElse: () => CategoryModel(name: 'Outros', colorHex: 'FF9E9E9E', iconName: '')
      );
      final color = Color(int.parse(category.colorHex, radix: 16));
      final percentage = (amount / totalExpense) * 100;

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    });

    return sections;
  }

  List<BarChartGroupData> _getBarChartData() {
    List<double> weekDays = List.filled(7, 0.0);

    for (var tx in _transactions) {
      if (tx.type == 'expense') {
        int weekdayIndex = tx.date.weekday - 1;
        weekDays[weekdayIndex] += tx.amountInCents.abs() / 100;
      }
    }

    List<BarChartGroupData> barGroups = [];
    final barColor = Theme.of(context).colorScheme.primary;

    for (int i = 0; i < 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weekDays[i],
              color: barColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  double _getMaxExpenseForBarChart() {
    List<double> weekDays = List.filled(7, 0.0);
    for (var tx in _transactions) {
      if (tx.type == 'expense') {
        int weekdayIndex = tx.date.weekday - 1;
        weekDays[weekdayIndex] += (tx.amountInCents.abs() / 100);
      }
    }
    double maxDailyTotal = 0;
    for (var totalOfDay in weekDays) {
      if (totalOfDay > maxDailyTotal) {
        maxDailyTotal = totalOfDay;
      }
    }
    return maxDailyTotal == 0 ? 100 : maxDailyTotal * 1.2; 
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
      appBar: AppBar(title: const Text('Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: (_selectedDate.year == DateTime.now().year && _selectedDate.month == DateTime.now().month) 
                      ? null 
                      : _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildSummaryCard('Entradas', income, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Saídas', expense, Colors.red)),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Despesas por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (!hasExpenses)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Nenhuma despesa este mês.', style: TextStyle(color: Colors.grey)),
              ))
            else
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: pieData,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: pieData.map((section) {
                      final cat = _categories.firstWhere((c) => Color(int.parse(c.colorHex, radix: 16)) == section.color, orElse: () => CategoryModel(name: 'Outros', colorHex: 'FF9E9E9E', iconName: ''));
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: section.color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(cat.name, style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            
            const SizedBox(height: 40),

            const Text('Padrão Semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Em quais dias você mais gasta no mês', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            
            if (!hasExpenses)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Sem dados suficientes.', style: TextStyle(color: Colors.grey)),
              ))
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxExpenseForBarChart(),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                            String text;
                            switch (value.toInt()) {
                              case 0: text = 'Seg'; break;
                              case 1: text = 'Ter'; break;
                              case 2: text = 'Qua'; break;
                              case 3: text = 'Qui'; break;
                              case 4: text = 'Sex'; break;
                              case 5: text = 'Sáb'; break;
                              case 6: text = 'Dom'; break;
                              default: text = ''; break;
                            }
                            return SideTitleWidget(meta: meta, child: Text(text, style: style));
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _getBarChartData(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int amountInCents, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formatCurrency(amountInCents), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}