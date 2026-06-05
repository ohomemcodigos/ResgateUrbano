import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chamados_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chamado.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/chamado_tile.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import 'cadastro_screen.dart';

/// Painel público do cidadão: somente leitura + registro de novos chamados.
class DashboardCidadaoScreen extends StatefulWidget {
  const DashboardCidadaoScreen({
    super.key,
    required this.title,
    required this.handleBrightnessChange,
    required this.useLightMode,
  });
  final String title;
  final bool useLightMode;
  final void Function(bool useLightMode) handleBrightnessChange;

  @override
  State<DashboardCidadaoScreen> createState() =>
      _DashboardCidadaoScreenState();
}

class _DashboardCidadaoScreenState extends State<DashboardCidadaoScreen> {
  String _searchQuery = '';

  String _calcularTempoAberto(DateTime dataAbertura) {
    final d = DateTime.now().difference(dataAbertura);
    if (d.inDays > 0) return '${d.inDays} dia(s) atrás';
    if (d.inHours > 0) return '${d.inHours} hora(s) atrás';
    if (d.inMinutes > 0) return '${d.inMinutes} minuto(s) atrás';
    return 'Agora mesmo';
  }

  Map<String, String> _getOrgaoResponsavel(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'trânsito':
        return {'orgao': 'SEMOB', 'contato': '118'};
      case 'iluminação':
        return {'orgao': 'Energisa', 'contato': '0800 083 0196'};
      case 'saneamento':
        return {'orgao': 'Cagepa', 'contato': '115'};
      case 'segurança':
        return {
          'orgao': 'Polícia Militar / Guarda Municipal',
          'contato': '190 / 153'
        };
      case 'limpeza urbana':
        return {'orgao': 'EMLUR', 'contato': '(83) 3214-7628'};
      case 'desastre natural':
        return {'orgao': 'Defesa Civil', 'contato': '199'};
      default:
        return {'orgao': 'Prefeitura Municipal', 'contato': '156'};
    }
  }

  Widget _infoLinha(
      ThemeData theme, IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _abrirModalDetalhes(BuildContext context, Chamado chamado) {
    final infoOrgao = _getOrgaoResponsavel(chamado.categoria);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (chamado.imagemBase64 != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(chamado.imagemBase64!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(chamado.titulo,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [StatusBadge(status: chamado.status)]),
              const SizedBox(height: 16),
              _infoLinha(theme, Icons.category_outlined, 'Categoria',
                  chamado.categoria),
              _infoLinha(theme, Icons.location_on_outlined, 'Local',
                  '${chamado.rua}, ${chamado.bairro}'),
              _infoLinha(theme, Icons.schedule, 'Aberto há',
                  _calcularTempoAberto(chamado.dataAbertura)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.support_agent,
                          color: AppColors.brand, size: 18),
                      const SizedBox(width: 8),
                      Text('Órgão Responsável',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 6),
                    Text('${infoOrgao['orgao']}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Contato: ${infoOrgao['contato']}',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Descrição',
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(chamado.descricao, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final provider = Provider.of<ChamadosProvider>(context);

    final chamadosFiltrados = provider.chamados.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.titulo.toLowerCase().contains(q) ||
          c.bairro.toLowerCase().contains(q);
    }).toList();

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CadastroScreen())),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Novo Chamado'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                DashboardHeader(
                  totalChamados: provider.chamados.length,
                  subtitle:
                      'Acompanhe os problemas reportados na cidade',
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por título ou bairro...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 16),
                if (chamadosFiltrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Nenhum chamado encontrado',
                      subtitle:
                          'Seja o primeiro a registrar um problema na sua cidade.',
                    ),
                  )
                else
                  ...chamadosFiltrados.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChamadoTile(
                          chamado: c,
                          onTap: () => _abrirModalDetalhes(context, c),
                        ),
                      )),
              ],
            ),
    );
  }
}