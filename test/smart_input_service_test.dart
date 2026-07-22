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
      // CORRIGIDO PARA LETRA MAIÚSCULA
      expect(result.description, 'Salario'); 
      expect(result.type, 'income');
    });

    test('detects food category from mercado keyword', () {
      final service = SmartInputService();

      final result = service.parse('mercado 15,50');

      expect(result, isNotNull);
      expect(result!.categoryName, 'Alimentação');
    });

    test('uses selected category when provided', () {
      final service = SmartInputService();

      final result = service.parse('15,50 mercado', selectedCategory: 'Transporte');

      expect(result, isNotNull);
      expect(result!.categoryName, 'Transporte');
    });

    test('Deve colocar a primeira letra em maiúscula', () {
      final service = SmartInputService();
      final result = service.parse('10 uber');
      expect(result!.description, 'Uber'); 
    });

    test('Deve remover palavras inúteis (Stopwords)', () {
      final service = SmartInputService();
      final result = service.parse('gastei 50 no mercado');
      expect(result!.description, 'Mercado'); 
    });

    test('Deve subtrair um dia da data se contiver a palavra "ontem"', () {
      final service = SmartInputService();
      final result = service.parse('50 pizza ontem');
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      
      expect(result!.description, 'Pizza'); 
      expect(result.date.day, ontem.day); 
    });
  });

  group('Cálculo de Saldo (calculateBalance)', () {
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