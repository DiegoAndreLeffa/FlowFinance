import '../../data/models/transaction_model.dart';

int calculateBalance(List<TransactionModel> transactions) {
  var total = 0;

  for (final transaction in transactions) {
    if (transaction.type == 'income') {
      total += transaction.amountInCents.toInt();
    } else {
      total -= transaction.amountInCents.toInt();
    }
  }

  return total;
}