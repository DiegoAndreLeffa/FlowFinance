import 'package:diacritic/diacritic.dart';

import '../entities/smart_input_result.dart';

class SmartInputService {
  SmartInputResult? parse(String input, {String? selectedCategory, bool isIncomeMode = false}) {
    String text = input.trim();
    if (text.isEmpty) return null;

    bool isYesterday = false;
    if (text.toLowerCase().endsWith(' ontem')) {
      isYesterday = true;
      text = text.substring(0, text.length - 6).trim();
    }

    text = text.replaceAll(RegExp(r'(r\$|\$|-)', caseSensitive: false), '').trim();

    final normalized = text.replaceAll(RegExp(r'\s+'), ' ');
    final hasIncomePrefix = normalized.startsWith('+');
    String cleanText = hasIncomePrefix ? normalized.substring(1).trim() : normalized;

    cleanText = cleanText.replaceAll(RegExp(r'\b(no|na|em|com|de|por|gastei|paguei)\b', caseSensitive: false), ' ').trim();
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ');

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

    if (description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
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
      date: isYesterday ? DateTime.now().subtract(const Duration(days: 1)) : DateTime.now(), 
    );
  }

  String? _inferCategory(String description) {
    final text = removeDiacritics(description.toLowerCase());

    final Map<String, Map<String, int>> knowledgeBase = {
      'Alimentação': {
        'mercado': 5, 'supermercado': 8, 'mercadinho': 8, 'padaria': 8, 'ifood': 10,
        'delivery': 7, 'restaurante': 10, 'lanche': 7, 'pizza': 8, 'hamburguer': 8,
        'burger': 8, 'mcdonalds': 10, 'mcdonald': 10, 'mc donalds': 10, 'mc donald': 10,
        'bk': 8, 'burger king': 10, 'subway': 8, 'kfc': 8, 'habibs': 8, 'girafas': 8,
        'acai': 8, 'sorvete': 6, 'cafe': 5, 'cafeteria': 8, 'acougue': 8, 'carne': 4,
        'feira': 5, 'hortifruti': 8, 'frutas': 4, 'verduras': 4, 'mercantil': 5,
      },
      'Transporte': {
        'uber': 10, '99': 10, 'taxi': 8, 'cabify': 8, 'onibus': 8, 'metro': 8, 'trem': 8,
        'gasolina': 10, 'etanol': 10, 'diesel': 10, 'combustivel': 10, 'posto': 7,
        'shell': 8, 'ipiranga': 8, 'petrobras': 8, 'pedagio': 8, 'estacionamento': 8,
        'lava rapido': 7, 'oficina': 7, 'mecanico': 7, 'passagem': 8, 'rodoviaria': 8,
        'aeroporto': 7, 'aviao': 8,
      },
      'Lazer': {
        'steam': 10, 'epic': 8, 'xbox': 8, 'playstation': 8, 'psn': 10, 'nintendo': 8,
        'cinema': 10, 'filme': 8, 'show': 8, 'teatro': 8, 'ingresso': 8, 'spotify': 8,
        'netflix': 8, 'disney': 8, 'prime video': 8, 'youtube': 8, 'game': 7, 'jogo': 7,
        'games': 7, 'cerveja': 5, 'bar': 5, 'balada': 6, 'viagem': 6, 'hotel': 6, 'pousada': 6,
      },
      'Contas': {
        'luz': 10, 'energia': 10, 'agua': 10, 'internet': 10, 'fibra': 8, 'celular': 8,
        'telefone': 8, 'tim': 8, 'vivo': 8, 'claro': 8, 'oi': 8, 'aluguel': 10,
        'condominio': 10, 'iptu': 10, 'ipva': 10, 'boleto': 4, 'seguro': 7, 'mensalidade': 5,
      },
      'Saúde': {
        'farmacia': 10, 'droga raia': 10, 'pague menos': 10, 'panvel': 10, 'remedio': 10,
        'medicamento': 10, 'medico': 10, 'consulta': 8, 'dentista': 10, 'hospital': 10,
        'clinica': 8, 'exame': 8, 'laboratorio': 8, 'vacina': 8, 'psicologo': 8, 'academia': 5,
      },
      'Educação': {
        'escola': 10, 'faculdade': 10, 'universidade': 10, 'curso': 8, 'udemy': 10,
        'alura': 10, 'dio': 10, 'origamid': 10, 'rocketseat': 10, 'livro': 8,
        'ebook': 8, 'caderno': 8, 'ingles': 10, 'professor': 8, 'mensalidade': 7,
      },
    };

    final scores = <String, int>{};

    for (final category in knowledgeBase.entries) {
      int score = 0;

      for (final keyword in category.value.entries) {
        final normalizedKeyword = removeDiacritics(keyword.key);
        
        final regex = RegExp(r'\b' + RegExp.escape(normalizedKeyword) + r'\b');

        if (regex.hasMatch(text)) {
          score += keyword.value;
        }
      }

      if (score > 0) {
        scores[category.key] = score;
      }
    }

    if (scores.isEmpty) return null;

    final winner = scores.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    return winner.key;
  }
}
