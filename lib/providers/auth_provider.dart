import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _perfilAcesso; // Pode ser 'cidadao' ou 'auditor'

  String? get perfilAcesso => _perfilAcesso;

  // Atalhos para facilitar as verificações na interface
  bool get isAuditor => _perfilAcesso == 'auditor';
  bool get isLogado => _perfilAcesso != null;

  void fazerLogin(String perfil) {
    _perfilAcesso = perfil;
    notifyListeners();
  }

  void fazerLogout() {
    _perfilAcesso = null;
    notifyListeners();
  }
}
