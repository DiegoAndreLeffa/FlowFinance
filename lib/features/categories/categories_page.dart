import 'package:flutter/material.dart';

import '../../core/utils/category_icon_mapper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/models/category_model.dart';

const List<IconData> _availableIcons = [
  Icons.category_outlined,
  Icons.restaurant_outlined,
  Icons.directions_car_outlined,
  Icons.shopping_bag_outlined,
  Icons.home_outlined,
  Icons.healing_outlined,
  Icons.school_outlined,
  Icons.sports_esports_outlined,
  Icons.flight_outlined,
  Icons.movie_outlined,
];

const List<Color> _availableColors = [
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
  Color(0xFFFFCA28),
  Color(0xFF66BB6A),
  Color(0xFFAB47BC),
  Color(0xFF26A69A),
  Color(0xFFFF7043),
  Color(0xFF5C6BC0),
];

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryDatabaseService _service = CategoryDatabaseService();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _service.getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _showCategoryDialog({CategoryModel? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final limitController = TextEditingController(
      text: category != null && category.limitAmountInCents > 0
          ? (category.limitAmountInCents / 100).toStringAsFixed(2)
          : '',
    );

    var selectedColor = category != null ? Color(int.parse(category.colorHex, radix: 16)) : _availableColors.first;
    var selectedIcon = category != null ? _iconFromName(category.iconName) : _availableIcons.first;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Nome da categoria'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Meta de gasto mensal (R\$)',
                        hintText: 'Ex: 500,00 (Opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cor'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableColors.map((color) {
                        final isSelected = selectedColor.value == color.value;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: color,
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ícone'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                            child: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final limitValue = double.tryParse(limitController.text.replaceAll(',', '.')) ?? 0;
                    final limitCents = (limitValue * 100).round();

                    final model = CategoryModel(
                      id: category?.id ?? DateTime.now().millisecondsSinceEpoch,
                      name: name,
                      colorHex: selectedColor.value.toRadixString(16).toUpperCase(),
                      iconName: iconNameFromIcon(selectedIcon),
                      limitAmountInCents: limitCents,
                    );

                    if (category == null) {
                      await _service.saveCategory(model);
                    } else {
                      await _service.updateCategory(model);
                    }

                    if (!mounted) return;
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    await _loadCategories();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _iconFromName(String? iconName) {
    return iconFromCategoryName(iconName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(category.colorHex, radix: 16)).withValues(alpha: 0.15),
                    child: Icon(_iconFromName(category.iconName), color: Color(int.parse(category.colorHex, radix: 16))),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    category.limitAmountInCents > 0
                        ? 'Meta: ${formatCurrency(category.limitAmountInCents)}/mês'
                        : 'Sem meta definida',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showCategoryDialog(category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await _service.deleteCategory(category.id);
                          await _loadCategories();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}