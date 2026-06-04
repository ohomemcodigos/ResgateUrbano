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

    if (tituloExiste) {
      throw Exception('Já existe um chamado com este título.');
    }

    await DatabaseHelper.instance.inserirChamado(novoChamado);
    _chamados.add(novoChamado);
    notifyListeners();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    final index = _chamados.indexWhere((c) => c.id == id);
    if (index >= 0) {
      // Regra de Negócio: Chamados concluídos não podem ser editados
      if (_chamados[index].status == 'Concluído') {
        throw Exception('Chamados concluídos não podem ser alterados.');
      }

      await DatabaseHelper.instance.atualizarStatusChamado(id, novoStatus);
      _chamados[index].status = novoStatus;
      notifyListeners();
    }
  }
}
