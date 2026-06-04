import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'providers/chamados_provider.dart';
import 'views/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChamadosProvider()..carregarChamados(),
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
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Cidade',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      themeMode: _themeMode,
      home: DashboardScreen(
        title: 'SOS Cidade',
        useLightMode: useLightMode,
        handleBrightnessChange: (useLightMode) => setState(() {
          _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}
