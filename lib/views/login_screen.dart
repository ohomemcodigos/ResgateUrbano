import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

/// Tela de login por perfil de acesso (cidadão ou auditor).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text('SOS Cidade',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    'Plataforma municipal de chamados urbanos emergenciais',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 36),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Selecione seu perfil de acesso',
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 16),
                  _PerfilCard(
                    icon: Icons.people_alt_outlined,
                    titulo: 'Cidadão',
                    descricao: 'Registrar e acompanhar problemas urbanos',
                    color: AppColors.brand,
                    onTap: () =>
                        context.read<AuthProvider>().fazerLogin('cidadao'),
                  ),
                  const SizedBox(height: 12),
                  _PerfilCard(
                    icon: Icons.admin_panel_settings_outlined,
                    titulo: 'Auditor / Prefeitura',
                    descricao: 'Gerenciar status, métricas e indicadores',
                    color: AppColors.brandDark,
                    onTap: () =>
                        context.read<AuthProvider>().fazerLogin('auditor'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  const _PerfilCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String descricao;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(descricao,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}