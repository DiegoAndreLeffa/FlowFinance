import '../entities/smart_input_result.dart';

class SmartInputService {
  SmartInputResult? parse(String input, {String? selectedCategory, bool isIncomeMode = false}) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final normalized = text.replaceAll(RegExp(r'\s+'), ' ');
    
    final hasIncomePrefix = normalized.startsWith('+');
    final cleanText = hasIncomePrefix ? normalized.substring(1).trim() : normalized;

    final pattern1 = RegExp(r'^(\d+[.,]?\d*)\s+(.+)$');
    final pattern2 = RegExp(r'^(.+)\s+(\d+[.,]?\d*)$');

    String rawAmount = '';
    String description = '';

    final match1 = pattern1.firstMatch(cleanText);
    if (match1 != null) {
      rawAmount = match1.group(1)!;
      description = match1.group(2)!;
    } else {
      final match2 = pattern2.firstMatch(cleanText);
      if (match2 != null) {
        description = match2.group(1)!;
        rawAmount = match2.group(2)!;
      } else {
        return null;
      }
    }

    final cleanAmount = rawAmount.replaceAll(',', '.');
    final doubleAmount = double.tryParse(cleanAmount) ?? 0.0;
    final cents = (doubleAmount * 100).round();

    final type = (hasIncomePrefix || isIncomeMode) ? 'income' : 'expense';
    
    final categoryName = selectedCategory?.trim().isNotEmpty == true 
        ? selectedCategory!.trim() 
        : _inferCategory(description);

    return SmartInputResult(
      amountInCents: type == 'income' ? cents : -cents,
      description: description.trim(),
      type: type,
      categoryName: categoryName,
    );
  }

  String? _inferCategory(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('mercado') || lower.contains('supermercado') || lower.contains('padaria')) {
      return 'Alimentação';
    }
    if (lower.contains('uber') || lower.contains('transporte') || lower.contains('gasolina')) {
      return 'Transporte';
    }
    if (lower.contains('cinema') || lower.contains('lazer') || lower.contains('restaurante')) {
      return 'Lazer';
    }
    return null;
  }
}
