import 'package:flutter/material.dart';

/// Paleta semântica do SOS Cidade.
/// Centraliza todas as cores e os mapeamentos visuais (status, prioridade, categoria).
class AppColors {
  AppColors._();

  // Marca / institucional
  static const Color brand = Color(0xFF1D4ED8);
  static const Color brandDark = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF0EA5E9);

  // Status
  static const Color statusAberto = Color(0xFF2563EB);
  static const Color statusAndamento = Color(0xFFF59E0B);
  static const Color statusConcluido = Color(0xFF16A34A);
  static const Color statusCritico = Color(0xFFDC2626);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'em andamento':
        return statusAndamento;
      case 'concluído':
      case 'concluido':
        return statusConcluido;
      case 'aberto':
      default:
        return statusAberto;
    }
  }

  // Prioridade
  static Color prioridadeColor(String p) {
    switch (p.toLowerCase()) {
      case 'crítica':
      case 'critica':
        return const Color(0xFFDC2626);
      case 'alta':
        return const Color(0xFFEA580C);
      case 'média':
      case 'media':
        return const Color(0xFFF59E0B);
      case 'baixa':
      default:
        return const Color(0xFF0D9488);
    }
  }

  // Ícone por categoria
  static IconData categoriaIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'trânsito':
      case 'transito':
        return Icons.traffic;
      case 'iluminação':
      case 'iluminacao':
        return Icons.lightbulb_outline;
      case 'saneamento':
        return Icons.water_drop_outlined;
      case 'segurança':
      case 'seguranca':
        return Icons.local_police_outlined;
      case 'limpeza urbana':
        return Icons.delete_outline;
      case 'desastre natural':
        return Icons.warning_amber_rounded;
      default:
        return Icons.report_problem_outlined;
    }
  }
}