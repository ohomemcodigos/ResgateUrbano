import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PriorityTag extends StatelessWidget {
  const PriorityTag({super.key, required this.prioridade});
  final String prioridade;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.prioridadeColor(prioridade);
    final p = prioridade.toLowerCase();
    final isCritica = p.startsWith('crít') || p.startsWith('crit');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCritica) ...[
            Icon(Icons.priority_high, size: 12, color: color),
            const SizedBox(width: 2),
          ],
          Text(
            prioridade.isEmpty
                ? prioridade
                : prioridade[0].toUpperCase() + prioridade.substring(1),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}