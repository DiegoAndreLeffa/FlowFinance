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