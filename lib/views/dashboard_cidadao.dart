import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chamados_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chamado.dart';
import 'cadastro_screen.dart';

// Interface dedicada ao cidadão comum.
// Bloqueia ações de edição e foca na transparência pública.
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
  State<DashboardCidadaoScreen> createState() => _DashboardCidadaoScreenState();
}

class _DashboardCidadaoScreenState extends State<DashboardCidadaoScreen> {
  String _searchQuery = '';

  String _calcularTempoAberto(DateTime dataAbertura) {
    final diferenca = DateTime.now().difference(dataAbertura);
    if (diferenca.inDays > 0) return '${diferenca.inDays} dia(s) atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours} hora(s) atrás';
    if (diferenca.inMinutes > 0)
      return '${diferenca.inMinutes} minuto(s) atrás';
    return 'Agora mesmo';
  }

  // Mapeamento dinâmico de órgãos públicos e contactos de emergência
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

  void _abrirModalDetalhes(BuildContext context, Chamado chamado) {
    final infoOrgao = _getOrgaoResponsavel(chamado.categoria);

    // Modal formatado como "Read-Only"
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chamado.titulo),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verificação e exibição do anexo fotográfico
                if (chamado.imagemBase64 != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(chamado.imagemBase64!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text('Categoria: ${chamado.categoria}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Descrição: ${chamado.descricao}'),
                const SizedBox(height: 8),
                Text('Local: ${chamado.rua}, ${chamado.bairro}'),
                const SizedBox(height: 16),

                // Módulo de encaminhamento público para o cidadão
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Órgão Responsável:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue)),
                      Text(
                          '${infoOrgao['orgao']} - Ligue ${infoOrgao['contato']}',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                Text('Status: ${chamado.status}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: chamado.status == 'Concluído'
                            ? Colors.green
                            : Colors.orange)),
                const SizedBox(height: 8),
                Text(
                    'Aberto há: ${_calcularTempoAberto(chamado.dataAbertura)}'),
              ],
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

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final provider = Provider.of<ChamadosProvider>(context);

    final chamadosFiltrados = provider.chamados.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.titulo.toLowerCase().contains(query) ||
          c.bairro.toLowerCase().contains(query);
    }).toList();

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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Lista de Problemas Públicos',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${provider.chamados.length} chamados'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar chamados...',
                      hintText: 'Digite o título ou bairro',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: chamadosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum chamado encontrado.'))
                      : ListView.builder(
                          itemCount: chamadosFiltrados.length,
                          itemBuilder: (context, index) {
                            final c = chamadosFiltrados[index];
                            return ListTile(
                              leading: const Icon(Icons.report_problem,
                                  color: Colors.blueGrey),
                              title: Text(c.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${c.categoria} • ${c.rua}, ${c.bairro}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (c.imagemBase64 != null)
                                    const Icon(Icons.photo_camera,
                                        color: Colors.grey, size: 16),
                                  const SizedBox(width: 8),
                                  Chip(label: Text(c.status)),
                                ],
                              ),
                              onTap: () => _abrirModalDetalhes(context, c),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CadastroScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Novo Chamado'),
      ),
    );
  }
}
