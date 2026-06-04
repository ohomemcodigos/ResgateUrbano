import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chamados_provider.dart';
import '../models/chamado.dart';
import 'cadastro_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.title,
    required this.handleBrightnessChange,
    required this.useLightMode,
  });
  final String title;
  final bool useLightMode;
  final void Function(bool useLightMode) handleBrightnessChange;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = ''; // Estado da barra de busca

  // Função que calcula o tempo decorrido
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
              Text('Status atual: ${chamado.status}'),
              const SizedBox(height: 8),
              Text('Aberto há: ${_calcularTempoAberto(chamado.dataAbertura)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Alterar status para:'),
              Wrap(
                spacing: 8.0,
                children: [
                  ActionChip(
                    label: const Text('Andamento'),
                    onPressed: () =>
                        _atualizarStatus(context, chamado.id, 'Em andamento'),
                  ),
                  ActionChip(
                    label: const Text('Concluído'),
                    backgroundColor: Colors.green.shade100,
                    onPressed: () =>
                        _atualizarStatus(context, chamado.id, 'Concluído'),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            )
          ],
        );
      },
    );
  }

  void _abrirModalRanking(BuildContext context) {
    final ranking =
        Provider.of<ChamadosProvider>(context, listen: false).rankingDeBairros;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ranking de Bairros',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: ranking.isEmpty
              ? const Text('Nenhum chamado registrado ainda.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      String bairro = ranking.keys.elementAt(index);
                      int quantidade = ranking.values.elementAt(index);
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}º')),
                        title: Text(bairro),
                        trailing: Text('$quantidade chamado(s)',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            )
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadosProvider>(context);
    final chamados = provider.chamados;

    // Lógica de Busca: Filtra por título ou bairro
    final chamadosFiltrados = chamados.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.titulo.toLowerCase().contains(query) ||
          c.bairro.toLowerCase().contains(query);
    }).toList();

    // Regra: Alta e Crítica no topo
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

    final totalChamados = chamados.length;
    final abertos = provider.chamadosAbertos.length;
    final emAndamento =
        chamados.where((c) => c.status == 'Em andamento').length;
    final concluidos = chamados.where((c) => c.status == 'Concluído').length;
    final criticos = provider.chamadosCriticos.length;

    final isBright = Theme.of(context).brightness == Brightness.light;

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
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (criticos > 5)
                  Container(
                    color: Colors.redAccent,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'ALERTA: Mais de 5 chamados críticos registrados!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                          DateFormat('dd/MM/yyyy - HH:mm')
                              .format(DateTime.now()),
                          style: const TextStyle(fontSize: 16)),
                      Text('Total de Chamados: $totalChamados',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Ver Ranking de Bairros'),
                        onPressed: () => _abrirModalRanking(context),
                      ),
                    ],
                  ),
                ),
                Wrap(
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
                const SizedBox(height: 8),
                // BARRA DE PESQUISA
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar chamados...',
                      hintText: 'Digite o título ou bairro',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${c.categoria} • ${c.prioridade}\n${c.rua}, ${c.bairro}\n${_calcularTempoAberto(c.dataAbertura)}'),
                              // Trailing com botão de favorito e status
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      c.isFavorito
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: c.isFavorito
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      provider.alternarFavorito(c.id);
                                    },
                                  ),
                                  Chip(label: Text(c.status)),
                                ],
                              ),
                              onTap: () => _abrirModalStatus(context, c),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(String titulo, int valor, Color cor) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
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
}
