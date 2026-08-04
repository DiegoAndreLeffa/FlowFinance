import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';

class CategoryDatabaseService {
  static const _storageKey = 'categories';

  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_storageKey);

    if (payload == null || payload.isEmpty) {
      return _defaultCategories();
    }

    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      return _defaultCategories();
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => CategoryModel.fromJson(item))
        .toList();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final categories = await getAllCategories();
    final updated = [...categories, category];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  Future<void> updateCategory(CategoryModel category) async {
    final categories = await getAllCategories();
    final updated = categories.map((item) => item.id == category.id ? category : item).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteCategory(int id) async {
    final categories = await getAllCategories();
    final updated = categories.where((item) => item.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  List<CategoryModel> _defaultCategories() {
    return [
      CategoryModel(id: 1, name: 'Alimentação', colorHex: 'FFEF5350', iconName: Icons.restaurant.codePoint.toString()),
      CategoryModel(id: 2, name: 'Transporte', colorHex: 'FF42A5F5', iconName: Icons.directions_car.codePoint.toString()),
      CategoryModel(id: 3, name: 'Lazer', colorHex: 'FFFFCA28', iconName: Icons.movie.codePoint.toString()), 
      CategoryModel(id: 4, name: 'Saúde', colorHex: 'FF66BB6A', iconName: Icons.healing.codePoint.toString()),
      CategoryModel(id: 5, name: 'Educação', colorHex: 'FFAB47BC', iconName: Icons.school.codePoint.toString()),
      CategoryModel(id: 6, name: 'Contas', colorHex: 'FF26A69A', iconName: Icons.home.codePoint.toString()),
    ];
  }
}
