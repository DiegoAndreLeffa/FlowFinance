import '../entities/smart_input_result.dart';

class SmartInputService {
  SmartInputResult? parse(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final pattern1 = RegExp(r'^(\d+[.,]?\d*)\s+(.+)$');

    final pattern2 = RegExp(r'^(.+)\s+(\d+[.,]?\d*)$');

    String rawAmount = '';
    String description = '';

    final match1 = pattern1.firstMatch(text);
    if (match1 != null) {
      rawAmount = match1.group(1)!;
      description = match1.group(2)!;
    } else {
      final match2 = pattern2.firstMatch(text);
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

    return SmartInputResult(
      amountInCents: cents,
      description: description.trim(),
    );
  }
}
