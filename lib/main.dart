import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamados_provider.dart';
import 'providers/auth_provider.dart';
import 'views/login_screen.dart';
import 'views/dashboard_auditor.dart';
import 'views/dashboard_cidadao.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => ChamadosProvider()..carregarChamados()),
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
        // Correção: Uso do PlatformDispatcher no lugar do window
        return PlatformDispatcher.instance.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void _handleBrightnessChange(bool useLightMode) {
    setState(() {
      _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Cidade',
      theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue),
      themeMode: _themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.isLogado) {
            return const LoginScreen();
          }
          if (auth.isAuditor) {
            // Removido o 'const' que causava erro de compilação
            return DashboardAuditorScreen(
              title: 'Painel do Auditor',
              useLightMode: useLightMode,
              handleBrightnessChange: _handleBrightnessChange,
            );
          } else {
            // Removido o 'const' que causava erro de compilação
            return DashboardCidadaoScreen(
              title: 'SOS Cidade - Cidadão',
              useLightMode: useLightMode,
              handleBrightnessChange: _handleBrightnessChange,
            );
          }
        },
      ),
    );
  }
}
