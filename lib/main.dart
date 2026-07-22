import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/security/auth_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FlowFinanceApp()));
}

class FlowFinanceApp extends StatelessWidget {
  const FlowFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp.router(
          title: 'FlowFinance',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32), surface: const Color(0xFFF8F9FA)),
            textTheme: textTheme,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, scrolledUnderElevation: 0, backgroundColor: Colors.transparent, elevation: 0),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50), brightness: Brightness.dark, surface: const Color(0xFF121212)),
            textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, scrolledUnderElevation: 0, backgroundColor: Colors.transparent, elevation: 0),
          ),
          routerConfig: appRouter,
          
          builder: (context, child) {
            return AuthWrapper(child: child!);
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isEnabled = await _authService.isProtectionEnabled();
    if (!isEnabled) {
      setState(() {
        _isAuthenticated = true;
        _isChecking = false;
      });
      return;
    }

    final success = await _authService.authenticate();
    setState(() {
      _isAuthenticated = success;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Aplicativo Bloqueado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Use a sua biometria para acessar.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _checkAuth, // Tenta de novo
                icon: const Icon(Icons.fingerprint),
                label: const Text('Desbloquear'),
              )
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}