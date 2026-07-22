class TransactionModel {
  TransactionModel({
    this.id = 0,
    required this.amountInCents,
    required this.description,
    required this.date,
    required this.type,
    this.categoryName,
  });

  final int id;
  final int amountInCents;
  final String description;
  final DateTime date;
  final String type;
  final String? categoryName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountInCents': amountInCents,
        'description': description,
        'date': date.toIso8601String(),
        'type': type,
        'categoryName': categoryName,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int? ?? 0,
      amountInCents: json['amountInCents'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      type: json['type'] as String? ?? 'expense',
      categoryName: json['categoryName'] as String?,
    );
  }
}