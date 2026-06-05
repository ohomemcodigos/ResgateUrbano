import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/chamados_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chamado.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/chamado_tile.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import 'cadastro_screen.dart';

/// Painel administrativo (auditor): métricas, edição de status, gráficos e SLA.
class DashboardAuditorScreen extends StatefulWidget {
  const DashboardAuditorScreen({
    super.key,
    required this.title,
    required this.handleBrightnessChange,
    required this.useLightMode,
  });
  final String title;
  final bool useLightMode;
  final void Function(bool useLightMode) handleBrightnessChange;

  @override
  State<DashboardAuditorScreen> createState() => _DashboardAuditorScreenState();
}

class _DashboardAuditorScreenState extends State<DashboardAuditorScreen> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final telas = const [_OperacionalTab(), _EstatisticasTab()];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            icon: Icon(isBright
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: () => widget.handleBrightnessChange(!isBright),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().fazerLogout(),
          ),
        ],
      ),
      body: telas[_indice],
      floatingActionButton: _indice == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CadastroScreen())),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Operacional'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Painel'),
        ],
      ),
    );
  }
}

// ===== ABA 1: OPERACIONAL =====
class _OperacionalTab extends StatefulWidget {
  const _OperacionalTab();
  @override
  State<_OperacionalTab> createState() => _OperacionalTabState();
}

class _OperacionalTabState extends State<_OperacionalTab> {
  String _searchQuery = '';

  String _calcularTempoAberto(DateTime d0) {
    final d = DateTime.now().difference(d0);
    if (d.inDays > 0) return '${d.inDays} dia(s) atrás';
    if (d.inHours > 0) return '${d.inHours} hora(s) atrás';
    if (d.inMinutes > 0) return '${d.inMinutes} minuto(s) atrás';
    return 'Agora mesmo';
  }

  void _atualizarStatus(BuildContext context, String id, String novo) async {
    try {
      await context.read<ChamadosProvider>().atualizarStatus(id, novo);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.statusCritico));
      }
    }
  }

  void _abrirModalStatus(BuildContext context, Chamado chamado) {
    final theme = Theme.of(context);
    final concluido = chamado.status.toLowerCase() == 'concluído';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            if (chamado.imagemBase64 != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(base64Decode(chamado.imagemBase64!),
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
            ],
            Text(chamado.titulo,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [StatusBadge(status: chamado.status)]),
            const SizedBox(height: 12),
            Text('${chamado.rua}, ${chamado.bairro}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Aberto há: ${_calcularTempoAberto(chamado.dataAbertura)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const Divider(height: 28),
            if (concluido)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.statusConcluido.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.statusConcluido, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Chamado concluído não pode ser editado.',
                          style: theme.textTheme.bodySmall)),
                ]),
              )
            else ...[
              Text('Alterar status',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _atualizarStatus(context, chamado.id, 'Em andamento'),
                    icon: const Icon(Icons.timelapse, size: 18),
                    label: const Text('Andamento'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _atualizarStatus(context, chamado.id, 'Concluído'),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Concluir'),
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadosProvider>(context);
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final chamados = provider.chamados;
    final filtrados = chamados.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.titulo.toLowerCase().contains(q) ||
          c.bairro.toLowerCase().contains(q);
    }).toList();

    int peso(String p) {
      switch (p.toLowerCase()) {
        case 'crítica':
          return 4;
        case 'alta':
          return 3;
        case 'média':
          return 2;
        default:
          return 1;
      }
    }

    final ordenados = List<Chamado>.from(filtrados)
      ..sort((a, b) => peso(b.prioridade).compareTo(peso(a.prioridade)));

    final abertos = provider.chamadosAbertos.length;
    final andamento = chamados.where((c) => c.status == 'Em andamento').length;
    final concluidos = chamados.where((c) => c.status == 'Concluído').length;
    final criticos = provider.chamadosCriticos.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (criticos > 5)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.statusCritico.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.statusCritico.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.statusCritico),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Alerta: mais de 5 chamados críticos ativos!',
                      style: TextStyle(
                          color: AppColors.statusCritico,
                          fontWeight: FontWeight.w700))),
            ]),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            StatCard(
                label: 'Abertos',
                value: abertos,
                color: AppColors.statusAberto,
                icon: Icons.folder_open_outlined),
            StatCard(
                label: 'Em andamento',
                value: andamento,
                color: AppColors.statusAndamento,
                icon: Icons.timelapse),
            StatCard(
                label: 'Concluídos',
                value: concluidos,
                color: AppColors.statusConcluido,
                icon: Icons.check_circle_outline),
            StatCard(
                label: 'Críticos',
                value: criticos,
                color: AppColors.statusCritico,
                icon: Icons.priority_high),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
              hintText: 'Buscar chamados...', prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Fila de Atendimento'),
        const SizedBox(height: 12),
        if (ordenados.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: EmptyState(
                icon: Icons.task_alt, title: 'Nenhum chamado na fila'),
          )
        else
          ...ordenados.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ChamadoTile(
                  chamado: c,
                  onTap: () => _abrirModalStatus(context, c),
                  trailing: IconButton(
                    icon: Icon(c.isFavorito ? Icons.star : Icons.star_border,
                        color: c.isFavorito
                            ? Colors.amber
                            : Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () => provider.alternarFavorito(c.id),
                  ),
                ),
              )),
      ],
    );
  }
}

// ===== ABA 2: ESTATÍSTICAS E SLA =====
class _EstatisticasTab extends StatelessWidget {
  const _EstatisticasTab();

  Widget _legenda(Color cor, String texto) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(texto, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _cardWrap(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ChamadosProvider>(context);
    final chamados = provider.chamados;
    final abertos = provider.chamadosAbertos.length;
    final andamento = chamados.where((c) => c.status == 'Em andamento').length;
    final concluidos = chamados.where((c) => c.status == 'Concluído').length;
    final ranking = provider.rankingDeBairros;
    final mediaSLA = provider.tempoMedioResolucaoPorCategoria;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Distribuição de Chamados'),
        const SizedBox(height: 12),
        _cardWrap(
            context,
            chamados.isEmpty
                ? const EmptyState(
                    icon: Icons.pie_chart_outline, title: 'Dados insuficientes')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 42,
                          sections: [
                            if (abertos > 0)
                              PieChartSectionData(
                                  color: AppColors.statusAberto,
                                  value: abertos.toDouble(),
                                  title: '$abertos',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            if (andamento > 0)
                              PieChartSectionData(
                                  color: AppColors.statusAndamento,
                                  value: andamento.toDouble(),
                                  title: '$andamento',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            if (concluidos > 0)
                              PieChartSectionData(
                                  color: AppColors.statusConcluido,
                                  value: concluidos.toDouble(),
                                  title: '$concluidos',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                          ],
                        )),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legenda(AppColors.statusAberto, 'Abertos'),
                          const SizedBox(height: 8),
                          _legenda(AppColors.statusAndamento, 'Andamento'),
                          const SizedBox(height: 8),
                          _legenda(AppColors.statusConcluido, 'Concluídos'),
                        ],
                      ),
                    ],
                  )),
        const SizedBox(height: 24),
        const SectionHeader(title: 'SLA — Tempo Médio de Resolução'),
        const SizedBox(height: 12),
        _cardWrap(
            context,
            mediaSLA.isEmpty
                ? Text('Nenhum chamado concluído ainda.',
                    style: theme.textTheme.bodyMedium)
                : Column(
                    children: List.generate(mediaSLA.length, (i) {
                      final cat = mediaSLA.keys.elementAt(i);
                      final val = mediaSLA.values.elementAt(i);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          Icon(AppColors.categoriaIcon(cat),
                              size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  cat.isEmpty
                                      ? cat
                                      : cat[0].toUpperCase() + cat.substring(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text(val,
                              style: const TextStyle(
                                  color: AppColors.statusConcluido,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      );
                    }),
                  )),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Ranking de Bairros'),
        const SizedBox(height: 12),
        _cardWrap(
            context,
            ranking.isEmpty
                ? Text('Sem registros.', style: theme.textTheme.bodyMedium)
                : Column(
                    children: List.generate(ranking.length, (i) {
                      final bairro = ranking.keys.elementAt(i);
                      final qtd = ranking.values.elementAt(i);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(bairro,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text('$qtd ocorrências',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ]),
                      );
                    }),
                  )),
        const SizedBox(height: 40),
      ],
    );
  }
}
