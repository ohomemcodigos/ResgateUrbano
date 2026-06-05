import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Cabeçalho do dashboard: nome do app, data/hora atual e total de chamados.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.totalChamados,
    required this.subtitle,
  });

  final int totalChamados;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agora = DateTime.now();
    final data = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(agora);
    final hora = DateFormat('HH:mm').format(agora);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text('SOS Cidade',
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(hora,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$totalChamados',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('chamados\nregistrados',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(data.isEmpty ? data : data[0].toUpperCase() + data.substring(1),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
        ],
      ),
    );
  }
}