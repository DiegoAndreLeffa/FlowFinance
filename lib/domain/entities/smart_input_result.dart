class SmartInputResult {
  final int amountInCents;
  final String description;
  final String type;
  final String? categoryName;
  final DateTime date;

  SmartInputResult({
    required this.amountInCents,
    required this.description,
    required this.type,
    required this.date,
    this.categoryName,
  });
}