import 'package:flutter_test/flutter_test.dart';
import 'package:flow_finance/data/models/transaction_model.dart';
import 'package:flow_finance/features/home/home_providers.dart';

void main() {
  group('filterTransactions', () {
    final now = DateTime.now();
    final transactions = [
      TransactionModel(
        amountInCents: 5000,
        description: 'Mercado',
        date: now,
        type: 'expense',
        categoryName: 'Alimentação',
      ),
      TransactionModel(
        amountInCents: 3000,
        description: 'Transporte',
        date: now.subtract(const Duration(days: 10)),
        type: 'expense',
        categoryName: 'Transporte',
      ),
      TransactionModel(
        amountInCents: 8000,
        description: 'Salário',
        date: now.subtract(const Duration(days: 40)),
        type: 'income',
        categoryName: 'Salário',
      ),
    ];

    test('filters transactions by category and period', () {
      final filtered = filterTransactions(
        transactions,
        categoryName: 'Alimentação',
        period: 'month',
      );

      expect(filtered.length, 1);
      expect(filtered.first.description, 'Mercado');
    });

    test('keeps balance based on period filter even when category has no matches', () {
      final currentMonthTransactions = [
        TransactionModel(
          amountInCents: 5000,
          description: 'Mercado',
          date: now,
          type: 'expense',
          categoryName: 'Alimentação',
        ),
        TransactionModel(
          amountInCents: 2000,
          description: 'Uber',
          date: now.subtract(const Duration(days: 1)),
          type: 'expense',
          categoryName: 'Transporte',
        ),
        TransactionModel(
          amountInCents: 9000,
          description: 'Antigo',
          date: now.subtract(const Duration(days: 40)),
          type: 'income',
          categoryName: 'Salário',
        ),
      ];

      final periodFiltered = filterTransactionsByPeriod(currentMonthTransactions, period: 'month');

      expect(periodFiltered.length, 2);
    });
  });
}
