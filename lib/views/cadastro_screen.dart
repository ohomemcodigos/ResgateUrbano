import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/chamado.dart';
import '../providers/chamados_provider.dart';
import '../theme/app_colors.dart';

/// Formulário de registro de um novo chamado.
/// Não aplica regra de negócio: apenas monta o Chamado e chama o provider.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _ruaCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();

  // Valores EXATOS exigidos pelos filtros do ChamadosProvider.
  static const _categorias = [
    'Trânsito',
    'Iluminação',
    'Saneamento',
    'Segurança',
    'Limpeza urbana',
    'Desastre natural',
  ];
  static const _prioridades = ['Crítica', 'Alta', 'Média', 'Baixa'];

  String _categoria = _categorias.first;
  String _prioridade = 'Média';
  String? _imagemBase64;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _ruaCtrl.dispose();
    _bairroCtrl.dispose();
    _responsavelCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final XFile? arquivo = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 60);
    if (arquivo != null) {
      final bytes = await arquivo.readAsBytes();
      setState(() => _imagemBase64 = base64Encode(bytes));
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final chamado = Chamado(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      categoria: _categoria,
      prioridade: _prioridade,
      rua: _ruaCtrl.text.trim(),
      bairro: _bairroCtrl.text.trim(),
      responsavel: _responsavelCtrl.text.trim(),
      dataAbertura: DateTime.now(),
      status: 'Aberto',
      isFavorito: false,
      imagemBase64: _imagemBase64,
    );

    try {
      await context.read<ChamadosProvider>().adicionarChamado(chamado);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Chamado registrado com sucesso!'),
          backgroundColor: AppColors.statusConcluido,
        ));
      }
    } catch (e) {
      // Regra de negócio (ex.: título duplicado) vem do provider.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.statusCritico,
        ));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Chamado')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            GestureDetector(
              onTap: _selecionarImagem,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagemBase64 == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('Adicionar foto (opcional)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        ],
                      )
                    : Image.memory(base64Decode(_imagemBase64!),
                        fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            const SizedBox(height: 20),
            _label(theme, 'Título *'),
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                  hintText: 'Ex.: Buraco na via principal'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o título'
                  : null,
            ),
            const SizedBox(height: 16),
            _label(theme, 'Descrição *'),
            TextFormField(
              controller: _descricaoCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Descreva o problema com detalhes'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'A descrição não pode ficar vazia'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(theme, 'Categoria'),
                      DropdownButtonFormField<String>(
                        value: _categoria,
                        isExpanded: true,
                        items: _categorias
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _categoria = v ?? _categoria),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(theme, 'Prioridade'),
                      DropdownButtonFormField<String>(
                        value: _prioridade,
                        isExpanded: true,
                        items: _prioridades
                            .map((p) => DropdownMenuItem(
                                value: p,
                                child: Row(children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.prioridadeColor(p),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(p),
                                ])))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _prioridade = v ?? _prioridade),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label(theme, 'Rua'),
            TextFormField(
              controller: _ruaCtrl,
              decoration: const InputDecoration(hintText: 'Nome da rua'),
            ),
            const SizedBox(height: 16),
            _label(theme, 'Bairro *'),
            TextFormField(
              controller: _bairroCtrl,
              decoration:
                  const InputDecoration(hintText: 'Nome do bairro'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'O bairro não pode ficar vazio'
                  : null,
            ),
            const SizedBox(height: 16),
            _label(theme, 'Responsável'),
            TextFormField(
              controller: _responsavelCtrl,
              decoration:
                  const InputDecoration(hintText: 'Quem está reportando'),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label:
                  Text(_salvando ? 'Salvando...' : 'Registrar Chamado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(texto,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
      );
}