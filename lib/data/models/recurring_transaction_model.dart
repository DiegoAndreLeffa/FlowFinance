class RecurringTransactionModel {
  RecurringTransactionModel({
    required this.id,
    required this.amountInCents,
    required this.description,
    required this.type,
    this.categoryName,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.isActive = true,
  });

  final int id;
  final int amountInCents;
  final String description;
  final String type;
  final String? categoryName;
  final String frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final bool isActive;

  RecurringTransactionModel copyWith({
    int? id,
    int? amountInCents,
    String? description,
    String? type,
    String? categoryName,
    String? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      amountInCents: amountInCents ?? this.amountInCents,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountInCents': amountInCents,
        'description': description,
        'type': type,
        'categoryName': categoryName,
        'frequency': frequency,
        'startDate': startDate.toIso8601String(),
        'nextDueDate': nextDueDate.toIso8601String(),
        'isActive': isActive,
      };

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as int? ?? 0,
      amountInCents: json['amountInCents'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      categoryName: json['categoryName'] as String?,
      frequency: json['frequency'] as String? ?? 'monthly',
      startDate: DateTime.parse(json['startDate'] as String? ?? DateTime.now().toIso8601String()),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String? ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
