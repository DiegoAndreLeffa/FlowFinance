import '../../data/models/transaction_model.dart';

int calculateBalance(List<TransactionModel> transactions, {int initialBalance = 0}) {
  var total = initialBalance;

  for (final transaction in transactions) {
    if (transaction.type == 'income') {
      total += transaction.amountInCents.toInt();
    } else {
      total -= transaction.amountInCents.toInt();
    }
  }

  return total;
}