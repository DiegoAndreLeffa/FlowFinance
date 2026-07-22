import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_finance/core/utils/category_icon_mapper.dart';

void main() {
  group('category icon mapper', () {
    test('maps alternate stored icon names to the correct icon', () {
      expect(iconFromCategoryName('restaurant_outlined'), Icons.restaurant_outlined);
    });

    test('maps selected icons back to a stable storage value', () {
      expect(iconNameFromIcon(Icons.restaurant_outlined), 'restaurant');
    });
  });
}
