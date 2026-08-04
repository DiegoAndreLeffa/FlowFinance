import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/category_icon_mapper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/database/database_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/main_drawer.dart';

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

    final now = DateTime.now();
    final daysPassed = (_selectedDate.month == now.month && _selectedDate.year == now.year) ? now.day : 30;
    final dailyAverageCents = expense > 0 ? (expense / daysPassed).round() : 0;

    int highestExpenseCents = 0;
    String highestExpenseDesc = 'Nenhum';
    for (var tx in _transactions) {
      if (tx.type == 'expense' && tx.amountInCents.abs() > highestExpenseCents) {
        highestExpenseCents = tx.amountInCents.abs();
        highestExpenseDesc = tx.description;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo & Insights')),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousMonth),
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
              children: [
                Expanded(child: _buildSummaryCard('Entradas', income, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Saídas', expense, Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Insights do Mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Média diária',
                    value: formatCurrency(dailyAverageCents),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Maior gasto',
                    value: formatCurrency(highestExpenseCents),
                    subtitle: highestExpenseDesc,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Metas e Limites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Acompanhe o seu limite mensal de gastos', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            
            _buildGoalsList(),

            const SizedBox(height: 32),

            const Text('Despesas por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (!hasExpenses)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhuma despesa este mês.', style: TextStyle(color: Colors.grey))))
            else
              Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(sections: pieData, centerSpaceRadius: 35, sectionsSpace: 2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: pieData.map((section) {
                      final cat = _categories.firstWhere((c) => Color(int.parse(c.colorHex, radix: 16)) == section.color, orElse: () => CategoryModel(name: 'Outros', colorHex: 'FF9E9E9E', iconName: ''));
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: section.color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(cat.name, style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            const Text('Padrão Semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (hasExpenses)
              SizedBox(
                height: 180,
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

  Widget _buildGoalsList() {
    final categoriesWithGoals = _categories.where((c) => c.limitAmountInCents > 0).toList();

    if (categoriesWithGoals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nenhuma meta definida. Edite uma categoria para definir um limite de gastos.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: categoriesWithGoals.map((cat) {
        final spentInCat = _transactions
            .where((tx) => tx.type == 'expense' && tx.categoryName == cat.name)
            .fold<int>(0, (sum, tx) => sum + tx.amountInCents.abs());

        final limit = cat.limitAmountInCents;
        final progress = (spentInCat / limit).clamp(0.0, 1.0);
        final isOverLimit = spentInCat > limit;

        // --- CORES SEMÂNTICAS DA NOVA REGRA DE NEGÓCIO ---
        Color progressColor;
        Color backgroundColor;
        
        if (progress < 0.50) {
          // Tranquilo (Até 49%)
          progressColor = const Color(0xFF4CAF50); // Verde
          backgroundColor = const Color(0xFFE8F5E9); 
        } else if (progress <= 0.70) {
          // Atenção (50% a 70%)
          progressColor = const Color(0xFFFFC107); // Amarelo (Amber)
          backgroundColor = const Color(0xFFFFF8E1); 
        } else {
          // Perigo (Acima de 70%)
          progressColor = const Color(0xFFE53935); // Vermelho
          backgroundColor = const Color(0xFFFFEBEE); 
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(iconFromCategoryName(cat.iconName), size: 18, color: Color(int.parse(cat.colorHex, radix: 16))),
                      const SizedBox(width: 8),
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '${formatCurrency(spentInCat)} / ${formatCurrency(limit)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOverLimit ? Colors.red : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: backgroundColor,
                  color: progressColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(String title, int amountInCents, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formatCurrency(amountInCents), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}