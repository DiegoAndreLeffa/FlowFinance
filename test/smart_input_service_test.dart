import 'package:flutter_test/flutter_test.dart';
import 'package:flow_finance/domain/services/smart_input_service.dart';
import 'package:flow_finance/features/home/home_providers.dart';
import 'package:flow_finance/data/models/transaction_model.dart';

void main() {
  group('SmartInputService', () {
    test('parses income values with + prefix', () {
      final service = SmartInputService();

      final result = service.parse('+ 5000 salario');

      expect(result, isNotNull);
      expect(result!.amountInCents, 500000);
      expect(result.description, 'salario');
      expect(result.type, 'income');
    });

    test('detects food category from mercado keyword', () {
      final service = SmartInputService();

      final result = service.parse('mercado 15,50');

      expect(result, isNotNull);
      expect(result!.categoryName, 'Alimentação');
    });

    test('includes initial balance in total balance calculation', () {
      final transactions = [
        TransactionModel(amountInCents: 50000, description: 'salario', date: DateTime.now(), type: 'income'),
        TransactionModel(amountInCents: 15000, description: 'mercado', date: DateTime.now(), type: 'expense'),
      ];

      final balance = calculateBalance(transactions, initialBalance: 100000);

      expect(balance, 135000);
    });

    test('subtracts expenses even when they are stored as negative cents', () {
      final transactions = [
        TransactionModel(amountInCents: -15000, description: 'mercado', date: DateTime.now(), type: 'expense'),
      ];

      final balance = calculateBalance(transactions, initialBalance: 50000);

      expect(balance, 35000);
    });
  });
}
