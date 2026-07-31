import 'package:flutter/material.dart';

import '../../core/utils/category_icon_mapper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/category_database_service.dart';
import '../../data/models/category_model.dart';
import '../../shared/widgets/main_drawer.dart';

const List<IconData> _availableIcons = [
  // Comida / Bebida
  Icons.restaurant, Icons.fastfood, Icons.local_pizza, Icons.local_cafe, Icons.local_bar, Icons.liquor, Icons.bakery_dining,
  // Transporte
  Icons.directions_car, Icons.local_taxi, Icons.directions_bus, Icons.directions_transit, Icons.two_wheeler, Icons.local_gas_station, Icons.flight,
  // Moradia / Contas
  Icons.home, Icons.apartment, Icons.bolt, Icons.water_drop, Icons.wifi, Icons.phone_android, Icons.receipt_long,
  // Compras
  Icons.shopping_cart, Icons.shopping_bag, Icons.storefront, Icons.checkroom, Icons.credit_card,
  // Lazer / Entretenimento
  Icons.movie, Icons.theaters, Icons.sports_esports, Icons.sports_soccer, Icons.fitness_center, Icons.palette, Icons.celebration, Icons.music_note,
  // Saúde / Pets
  Icons.medical_services, Icons.healing, Icons.local_pharmacy, Icons.favorite, Icons.pets,
  // Finanças / Trabalho
  Icons.attach_money, Icons.savings, Icons.trending_up, Icons.work, Icons.business_center, Icons.account_balance,
  // Outros / Educação
  Icons.school, Icons.menu_book, Icons.child_care, Icons.card_giftcard, Icons.category,
];

const List<Color> _availableColors = [
  // Tons Quentes (Vermelhos, Laranjas, Amarelos)
  Color(0xFFE53935), Color(0xFFEF5350), Color(0xFFF44336), 
  Color(0xFFE65100), Color(0xFFFF9800), Color(0xFFFFC107), Color(0xFFFFD54F),
  // Tons Frios (Verdes, Azuis, Cianos)
  Color(0xFF1B5E20), Color(0xFF4CAF50), Color(0xFF81C784),
  Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF2196F3), Color(0xFF4FC3F7),
  Color(0xFF006064), Color(0xFF00BCD4), Color(0xFF26A69A),
  // Tons Neutros e Luxuosos (Roxos, Rosas, Marrons, Cinzas Escuros)
  Color(0xFF4A148C), Color(0xFF9C27B0), Color(0xFFBA68C8),
  Color(0xFF880E4F), Color(0xFFE91E63), Color(0xFFF06292),
  Color(0xFF3E2723), Color(0xFF795548), Color(0xFF263238), Color(0xFF607D8B),
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
    
    var selectedIcon = _availableIcons.first;
    if (category != null) {
      final codePoint = int.tryParse(category.iconName);
      if (codePoint != null) {
        selectedIcon = IconData(codePoint, fontFamily: 'MaterialIcons');
      } else {
        selectedIcon = iconFromCategoryName(category.iconName);
      }
    }

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
                    const Text('Cor', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      height: 120,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Ícone', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      height: 180,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableIcons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedIcon = icon),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: isSelected ? selectedColor : Theme.of(context).colorScheme.surface,
                                child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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
                      iconName: selectedIcon.codePoint.toString(),
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
    if (iconName == null) return Icons.category;
    
    final codePoint = int.tryParse(iconName);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    
    return iconFromCategoryName(iconName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      drawer: const MainDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(category.colorHex, radix: 16)).withOpacity(0.15),
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