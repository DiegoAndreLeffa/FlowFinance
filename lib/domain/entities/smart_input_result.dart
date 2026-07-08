class SmartInputResult {
  final int amountInCents;
  final String description;
  final String type;
  final String? categoryName;

  SmartInputResult({
    required this.amountInCents,
    required this.description,
    required this.type,
    this.categoryName,
  });
}
