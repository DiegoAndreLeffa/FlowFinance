import 'package:flutter_test/flutter_test.dart';
import 'package:flow_finance/domain/services/smart_input_service.dart';

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
  });
}
