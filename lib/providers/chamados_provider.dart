import 'package:flutter/material.dart';
import '../models/chamado.dart';
import '../database/db_helper.dart';

class ChamadosProvider extends ChangeNotifier {
  List<Chamado> _chamados = [];
  bool _isLoading = false;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;

  // Filtros rápidos para o Dashboard
  List<Chamado> get chamadosAbertos =>
      _chamados.where((c) => c.status == 'Aberto').toList();

  List<Chamado> get chamadosCriticos =>
      _chamados.where((c) => c.prioridade == 'Crítica').toList();

  List<Chamado> get chamadosFavoritos =>
      _chamados.where((c) => c.isFavorito).toList();

  Map<String, int> get rankingDeBairros {
    final map = <String, int>{};
    for (var c in _chamados) {
      final bairroNormalizado = c.bairro.trim().toUpperCase();
      map[bairroNormalizado] = (map[bairroNormalizado] ?? 0) + 1;
    }
    final mapOrdenado = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
    return mapOrdenado;
  }

  // Dashboard Avançado: Cálculo do SLA (Tempo Médio de Resolução) por Categoria
  Map<String, String> get tempoMedioResolucaoPorCategoria {
    final mapTempos = <String, List<int>>{};

    final chamadosConcluidos = _chamados
        .where((c) => c.status == 'Concluído' && c.dataFechamento != null);

    for (var c in chamadosConcluidos) {
      final minutosGastos =
          c.dataFechamento!.difference(c.dataAbertura).inMinutes;
      if (!mapTempos.containsKey(c.categoria)) {
        mapTempos[c.categoria] = [];
      }
      mapTempos[c.categoria]!.add(minutosGastos);
    }

    final medias = <String, String>{};
    mapTempos.forEach((categoria, tempos) {
      final mediaMinutos = tempos.reduce((a, b) => a + b) / tempos.length;
      if (mediaMinutos > 1440) {
        medias[categoria] = '${(mediaMinutos / 1440).toStringAsFixed(1)} dias';
      } else if (mediaMinutos > 60) {
        medias[categoria] = '${(mediaMinutos / 60).toStringAsFixed(1)} horas';
      } else {
        medias[categoria] = '${mediaMinutos.toInt()} minutos';
      }
    });

    return medias;
  }

  Future<void> carregarChamados() async {
    _isLoading = true;
    notifyListeners();

    _chamados = await DatabaseHelper.instance.lerTodosChamados();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarChamado(Chamado novoChamado) async {
    // Regra de Negócio: Não permitir título repetido
    bool tituloExiste = _chamados
        .any((c) => c.titulo.toLowerCase() == novoChamado.titulo.toLowerCase());

    if (tituloExiste) throw Exception('Já existe um chamado com este título.');

    await DatabaseHelper.instance.inserirChamado(novoChamado);
    _chamados.insert(0, novoChamado);
    notifyListeners();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    final index = _chamados.indexWhere((c) => c.id == id);
    if (index >= 0) {
      // Regra de Negócio: Chamados concluídos não podem ser editados
      if (_chamados[index].status == 'Concluído') {
        throw Exception('Chamados concluídos não podem ser alterados.');
      }

      DateTime? dataFechamento;
      if (novoStatus == 'Concluído') {
        dataFechamento = DateTime.now();
      }

      await DatabaseHelper.instance
          .atualizarStatusEFechamento(id, novoStatus, dataFechamento);

      _chamados[index].status = novoStatus;
      _chamados[index].dataFechamento = dataFechamento;
      notifyListeners();
    }
  }

  Future<void> alternarFavorito(String id) async {
    final index = _chamados.indexWhere((c) => c.id == id);
    if (index >= 0) {
      final novoEstado = !_chamados[index].isFavorito;
      await DatabaseHelper.instance.alternarFavorito(id, novoEstado);
      _chamados[index].isFavorito = novoEstado;
      notifyListeners();
    }
  }
}
