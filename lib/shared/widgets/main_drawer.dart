import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  const Text('FlowFinance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.home_outlined, color: currentRoute == '/' ? Theme.of(context).colorScheme.primary : null),
            title: Text('Início', style: TextStyle(color: currentRoute == '/' ? Theme.of(context).colorScheme.primary : null, fontWeight: currentRoute == '/' ? FontWeight.bold : FontWeight.normal)),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),

          ListTile(
            leading: Icon(Icons.pie_chart_outline, color: currentRoute == '/insights' ? Theme.of(context).colorScheme.primary : null),
            title: Text('Resumo & Insights', style: TextStyle(color: currentRoute == '/insights' ? Theme.of(context).colorScheme.primary : null, fontWeight: currentRoute == '/insights' ? FontWeight.bold : FontWeight.normal)),
            onTap: () {
              Navigator.pop(context);
              context.go('/insights');
            },
          ),

          ListTile(
            leading: Icon(Icons.category_outlined, color: currentRoute == '/categories' ? Theme.of(context).colorScheme.primary : null),
            title: Text('Categorias', style: TextStyle(color: currentRoute == '/categories' ? Theme.of(context).colorScheme.primary : null, fontWeight: currentRoute == '/categories' ? FontWeight.bold : FontWeight.normal)),
            onTap: () {
              Navigator.pop(context);
              context.go('/categories');
            },
          ),

          ListTile(
            leading: Icon(Icons.settings_outlined, color: currentRoute == '/settings' ? Theme.of(context).colorScheme.primary : null),
            title: Text('Configurações', style: TextStyle(color: currentRoute == '/settings' ? Theme.of(context).colorScheme.primary : null, fontWeight: currentRoute == '/settings' ? FontWeight.bold : FontWeight.normal)),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          
          const Spacer(),
          const Divider(),
          
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier, 
            builder: (context, currentMode, child) {
              final isDark = currentMode == ThemeMode.dark || 
                  (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
              
              return SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.amber : Colors.orange),
                title: const Text('Modo Escuro'),
                value: isDark,
                onChanged: (value) {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}