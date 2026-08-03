import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/security/auth_service.dart';
import 'core/notifications/notification_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
          title: 'Finari',
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
            scaffoldBackgroundColor: const Color(0xFF121212), 
            
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E), 
              onSurface: Colors.white.withOpacity(0.87),
            ),
            
            textTheme: textTheme.apply(
              bodyColor: Colors.white.withOpacity(0.87), 
              displayColor: Colors.white,
            ),
            
            useMaterial3: true,
            
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              scrolledUnderElevation: 0,
              backgroundColor: Color(0xFF121212), 
              elevation: 0,
            ),
            
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF1A1A1A),
            ),
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
    final results = await Future.wait([
      _authService.isProtectionEnabled(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    
    final isEnabled = results[0] as bool; 
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
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Finari',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entenda. Organize. Evolua.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
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