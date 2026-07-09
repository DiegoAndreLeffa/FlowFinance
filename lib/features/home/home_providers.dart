import '../../data/models/transaction_model.dart';

int calculateBalance(List<TransactionModel> transactions, {int initialBalance = 0}) {
  var total = initialBalance;

  for (final transaction in transactions) {
    final amount = transaction.type == 'income'
        ? transaction.amountInCents.abs()
        : -transaction.amountInCents.abs();

    total += amount;
  }

  return total;
}

List<TransactionModel> filterTransactionsByPeriod(
  List<TransactionModel> transactions, {
  required String period,
}) {
  final now = DateTime.now();

  return transactions.where((transaction) {
    if (period == 'day') {
      return transaction.date.year == now.year &&
          transaction.date.month == now.month &&
          transaction.date.day == now.day;
    }

    if (period == 'week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return transaction.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }

    if (period == 'month') {
      return transaction.date.year == now.year && transaction.date.month == now.month;
    }

    return true;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

List<TransactionModel> filterTransactions(
  List<TransactionModel> transactions, {
  String? categoryName,
  String period = 'all',
}) {
  final periodFiltered = filterTransactionsByPeriod(transactions, period: period);

  if (categoryName == null || categoryName.isEmpty) {
    return periodFiltered;
  }

  return periodFiltered.where((transaction) => transaction.categoryName == categoryName).toList();
}