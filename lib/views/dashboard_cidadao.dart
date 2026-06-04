import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/chamados_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chamado.dart';
import 'cadastro_screen.dart';

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
  int _indiceAbaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final List<Widget> telas = [
      const _OperacionalTab(),
      const _EstatisticasTab()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: 'Alternar tema',
            child: IconButton(
              icon: isBright
                  ? const Icon(Icons.dark_mode_outlined)
                  : const Icon(Icons.light_mode_outlined),
              onPressed: () => widget.handleBrightnessChange(!isBright),
            ),
          ),
          Tooltip(
            message: 'Sair',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Provider.of<AuthProvider>(context, listen: false)
                  .fazerLogout(),
            ),
          ),
        ],
      ),
      body: telas[_indiceAbaAtual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAbaAtual,
        onDestinationSelected: (int index) =>
            setState(() => _indiceAbaAtual = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.list_alt), label: 'Operacional'),
          NavigationDestination(
              icon: Icon(Icons.insights), label: 'Painel Gerencial'),
        ],
      ),
      floatingActionButton: _indiceAbaAtual == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CadastroScreen())),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// ABA 1: OPERACIONAL DO AUDITOR
class _OperacionalTab extends StatefulWidget {
  const _OperacionalTab();
  @override
  State<_OperacionalTab> createState() => _OperacionalTabState();
}

class _OperacionalTabState extends State<_OperacionalTab> {
  String _searchQuery = '';

  String _calcularTempoAberto(DateTime dataAbertura) {
    final diferenca = DateTime.now().difference(dataAbertura);
    if (diferenca.inDays > 0) return '${diferenca.inDays} dia(s) atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours} hora(s) atrás';
    if (diferenca.inMinutes > 0)
      return '${diferenca.inMinutes} minuto(s) atrás';
    return 'Agora mesmo';
  }

  void _abrirModalStatus(BuildContext context, Chamado chamado) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chamado.titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descrição: ${chamado.descricao}'),
              const SizedBox(height: 8),
              Text('Local: ${chamado.rua}, ${chamado.bairro}'),
              const SizedBox(height: 16),
              const Divider(),
              Text('Status atual: ${chamado.status}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Aberto há: ${_calcularTempoAberto(chamado.dataAbertura)}'),
              const SizedBox(height: 16),
              const Text('Alterar status para:'),
              Wrap(
                spacing: 8.0,
                children: [
                  ActionChip(
                      label: const Text('Andamento'),
                      onPressed: () => _atualizarStatus(
                          context, chamado.id, 'Em andamento')),
                  ActionChip(
                      label: const Text('Concluído'),
                      backgroundColor: Colors.green.shade100,
                      onPressed: () =>
                          _atualizarStatus(context, chamado.id, 'Concluído')),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'))
          ],
        );
      },
    );
  }

  void _atualizarStatus(
      BuildContext context, String id, String novoStatus) async {
    try {
      await Provider.of<ChamadosProvider>(context, listen: false)
          .atualizarStatus(id, novoStatus);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildCard(String titulo, int valor, Color cor) {
    return Card(
      elevation: 2,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(titulo,
                style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
            Text('$valor', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadosProvider>(context);
    if (provider.isLoading)
      return const Center(child: CircularProgressIndicator());

    final chamados = provider.chamados;
    final chamadosFiltrados = chamados.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.titulo.toLowerCase().contains(query) ||
          c.bairro.toLowerCase().contains(query);
    }).toList();

    final sortedChamados = List<Chamado>.from(chamadosFiltrados);
    sortedChamados.sort((a, b) {
      int peso(String p) {
        if (p == 'crítica') return 4;
        if (p == 'alta') return 3;
        if (p == 'média') return 2;
        return 1;
      }

      return peso(b.prioridade.toLowerCase())
          .compareTo(peso(a.prioridade.toLowerCase()));
    });

    final abertos = provider.chamadosAbertos.length;
    final emAndamento =
        chamados.where((c) => c.status == 'Em andamento').length;
    final concluidos = chamados.where((c) => c.status == 'Concluído').length;
    final criticos = provider.chamadosCriticos.length;

    return Column(
      children: [
        if (criticos > 5)
          Container(
              color: Colors.redAccent,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: const Text('ALERTA: Mais de 5 chamados críticos!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              _buildCard('Abertos', abertos, Colors.blue),
              _buildCard('Andamento', emAndamento, Colors.orange),
              _buildCard('Concluídos', concluidos, Colors.green),
              _buildCard('Críticos', criticos, Colors.red),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Buscar chamados...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0))),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const Divider(),
        Expanded(
          child: sortedChamados.isEmpty
              ? const Center(child: Text('Nenhum chamado encontrado.'))
              : ListView.builder(
                  itemCount: sortedChamados.length,
                  itemBuilder: (context, index) {
                    final c = sortedChamados[index];
                    return ListTile(
                      leading: const Icon(Icons.report_problem),
                      title: Text(c.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${c.categoria} • ${c.prioridade}\n${c.rua}, ${c.bairro}\n${_calcularTempoAberto(c.dataAbertura)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(
                                  c.isFavorito ? Icons.star : Icons.star_border,
                                  color: c.isFavorito
                                      ? Colors.amber
                                      : Colors.grey),
                              onPressed: () => provider.alternarFavorito(c.id)),
                          Chip(label: Text(c.status)),
                        ],
                      ),
                      onTap: () => _abrirModalStatus(context, c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ABA 2: PAINEL GERENCIAL DO AUDITOR
class _EstatisticasTab extends StatelessWidget {
  const _EstatisticasTab();

  Widget _legenda(Color cor, String texto) {
    return Row(children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(texto, style: const TextStyle(fontWeight: FontWeight.w500))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadosProvider>(context);
    final chamados = provider.chamados;
    final abertos = provider.chamadosAbertos.length;
    final andamento = chamados.where((c) => c.status == 'Em andamento').length;
    final concluidos = chamados.where((c) => c.status == 'Concluído').length;
    final ranking = provider.rankingDeBairros;
    final mediaSLA = provider.tempoMedioResolucaoPorCategoria;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuição de Chamados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (chamados.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (abertos > 0)
                          PieChartSectionData(
                              color: Colors.blue,
                              value: abertos.toDouble(),
                              title: '$abertos',
                              radius: 30,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        if (andamento > 0)
                          PieChartSectionData(
                              color: Colors.orange,
                              value: andamento.toDouble(),
                              title: '$andamento',
                              radius: 30,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        if (concluidos > 0)
                          PieChartSectionData(
                              color: Colors.green,
                              value: concluidos.toDouble(),
                              title: '$concluidos',
                              radius: 30,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                      ])),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _legenda(Colors.blue, 'Abertos'),
                  const SizedBox(height: 8),
                  _legenda(Colors.orange, 'Andamento'),
                  const SizedBox(height: 8),
                  _legenda(Colors.green, 'Concluídos')
                ])
              ],
            )
          else
            const Center(child: Text('Dados insuficientes para o gráfico.')),
          const SizedBox(height: 32),
          const Divider(),
          const Text('SLA - Tempo Médio de Resolução',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          mediaSLA.isEmpty
              ? const Text('Nenhum chamado concluído.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mediaSLA.length,
                  itemBuilder: (context, index) => Card(
                      child: ListTile(
                          leading: const Icon(Icons.timer),
                          title: Text(
                              mediaSLA.keys.elementAt(index).toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text(mediaSLA.values.elementAt(index),
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)))),
                ),
          const SizedBox(height: 32),
          const Divider(),
          const Text('Ranking de Bairros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ranking.isEmpty
              ? const Text('Sem registos.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ranking.length,
                  itemBuilder: (context, index) => ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}º')),
                      title: Text(ranking.keys.elementAt(index),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                          '${ranking.values.elementAt(index)} ocorrências')),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
