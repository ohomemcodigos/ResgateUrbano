import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chamado.dart';
import '../providers/chamados_provider.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _responsavelController = TextEditingController();

  String _categoria = 'trânsito';
  String _prioridade = 'baixa';

  final _categorias = [
    'trânsito',
    'iluminação',
    'saneamento',
    'segurança',
    'limpeza urbana',
    'desastre natural'
  ];
  final _prioridades = ['baixa', 'média', 'alta', 'crítica'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Chamado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Não permitir descrição vazia'
                    : null,
              ),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Não permitir bairro vazio'
                    : null,
              ),
              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(labelText: 'Responsável'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              DropdownButtonFormField<String>(
                value: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: _prioridades
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _prioridade = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final novo = Chamado(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      titulo: _tituloController.text.trim(),
                      descricao: _descricaoController.text.trim(),
                      categoria: _categoria,
                      prioridade: _prioridade,
                      bairro: _bairroController.text.trim(),
                      responsavel: _responsavelController.text.trim(),
                      dataAbertura: DateTime.now(),
                    );

                    try {
                      await Provider.of<ChamadosProvider>(context,
                              listen: false)
                          .adicionarChamado(novo);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: const Text('Salvar Chamado'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
