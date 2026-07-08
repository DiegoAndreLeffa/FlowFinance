class CategoryModel {
  CategoryModel({
    this.id = 0,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  final int id;
  final String name;
  final String colorHex;
  final String iconName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'iconName': iconName,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Sem categoria',
      colorHex: json['colorHex'] as String? ?? 'FF4CAF50',
      iconName: json['iconName'] as String? ?? 'category',
    );
  }
}
