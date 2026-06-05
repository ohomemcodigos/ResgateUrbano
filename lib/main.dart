import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_theme.dart';
import 'providers/chamados_provider.dart';
import 'providers/auth_provider.dart';
import 'views/login_screen.dart';
import 'views/dashboard_auditor.dart';
import 'views/dashboard_cidadao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ChamadosProvider()..carregarChamados(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  bool get useLightMode {
    switch (_themeMode) {
      case ThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void _handleBrightnessChange(bool useLightMode) {
    setState(() =>
        _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Cidade',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.isLogado) return const LoginScreen();
          if (auth.isAuditor) {
            return DashboardAuditorScreen(
              title: 'Painel do Auditor',
              useLightMode: useLightMode,
              handleBrightnessChange: _handleBrightnessChange,
            );
          }
          return DashboardCidadaoScreen(
            title: 'SOS Cidade',
            useLightMode: useLightMode,
            handleBrightnessChange: _handleBrightnessChange,
          );
        },
      ),
    );
  }
}