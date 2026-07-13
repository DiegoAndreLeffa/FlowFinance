import 'package:flutter/material.dart';

const Map<String, IconData> _iconNameToIcon = {
  'category': Icons.category_outlined,
  'category_outlined': Icons.category_outlined,
  'restaurant': Icons.restaurant_outlined,
  'restaurant_outlined': Icons.restaurant_outlined,
  'directions_car': Icons.directions_car_outlined,
  'directions_car_outlined': Icons.directions_car_outlined,
  'shopping_bag': Icons.shopping_bag_outlined,
  'shopping_bag_outlined': Icons.shopping_bag_outlined,
  'home': Icons.home_outlined,
  'home_outlined': Icons.home_outlined,
  'healing': Icons.healing_outlined,
  'healing_outlined': Icons.healing_outlined,
  'school': Icons.school_outlined,
  'school_outlined': Icons.school_outlined,
  'sports_esports': Icons.sports_esports_outlined,
  'sports_esports_outlined': Icons.sports_esports_outlined,
  'flight': Icons.flight_outlined,
  'flight_outlined': Icons.flight_outlined,
  'movie': Icons.movie_outlined,
  'movie_outlined': Icons.movie_outlined,
};

IconData iconFromCategoryName(String? iconName) {
  final normalizedName = iconName?.trim();
  return _iconNameToIcon[normalizedName] ?? _iconNameToIcon['category']!;
}

String iconNameFromIcon(IconData icon) {
  for (final entry in _iconNameToIcon.entries) {
    if (entry.value == icon) {
      return entry.key == 'category_outlined' ? 'category' : entry.key;
    }
  }

  return 'category';
}
