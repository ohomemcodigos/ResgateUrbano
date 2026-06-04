import 'dart:convert'; // Suporte de descodificação/codificação binária
import 'dart:typed_data'; // Gestão de buffer de ficheiros
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chamado.dart';
import '../providers/chamados_provider.dart';
import '../services/via_cep_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _responsavelController = TextEditingController();

  String _categoria = 'trânsito';
  String _prioridade = 'baixa';
  bool _buscandoCep = false;

  // Variáveis para a gestão do anexo fotográfico
  String? _imagemBase64;
  final ImagePicker _picker = ImagePicker();

  final _categorias = [
    'trânsito',
    'iluminação',
    'saneamento',
    'segurança',
    'limpeza urbana',
    'desastre natural'
  ];
  final _prioridades = ['baixa', 'média', 'alta', 'crítica'];

  Future<void> _buscarCep() async {
    final cep = _cepController.text;
    if (cep.isEmpty) return;

    setState(() => _buscandoCep = true);

    // Conexão ao serviço de autopreenchimento de moradas
    final endereco = await ViaCepService.buscarEnderecoPorCep(cep);

    setState(() {
      _buscandoCep = false;
      if (endereco != null) {
        _ruaController.text = endereco['rua'] ?? '';
        _bairroController.text = endereco['bairro'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Endereço preenchido automaticamente!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'CEP não encontrado. Preencha os dados manualmente ou tente novamente.'),
              backgroundColor: Colors.orange),
        );
      }
    });
  }

  // Função central para a captura e conversão da imagem em texto (Base64)
  Future<void> _capturarImagem(ImageSource fonte) async {
    try {
      // Compressão configurada para 30% a fim de otimizar a carga no SQLite local
      final XFile? image =
          await _picker.pickImage(source: fonte, imageQuality: 30);
      if (image != null) {
        // Extrai os bytes da imagem
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _imagemBase64 = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao processar imagem.')));
      }
    }
  }

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
                decoration:
                    const InputDecoration(labelText: 'Descrição do Problema'),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Não permitir descrição vazia'
                    : null,
              ),

              const SizedBox(height: 24),
              // Área de anexo de evidências fotográficas
              const Text('Evidência Fotográfica (Opcional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: _imagemBase64 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(base64Decode(_imagemBase64!),
                            fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(Icons.camera_alt,
                            size: 50, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _capturarImagem(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Câmara'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _capturarImagem(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                  if (_imagemBase64 != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _imagemBase64 = null),
                      tooltip: 'Remover imagem',
                    )
                ],
              ),

              const SizedBox(height: 24),
              const Text('Localização',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP (Busca Automática via API)',
                  hintText: 'Digite apenas números',
                  suffixIcon: _buscandoCep
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _buscarCep,
                          tooltip: 'Buscar Endereço'),
                ),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _buscarCep(),
              ),
              TextFormField(
                controller: _ruaController,
                decoration:
                    const InputDecoration(labelText: 'Logradouro / Rua'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Rua é obrigatória' : null,
              ),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Não permitir bairro vazio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _responsavelController,
                decoration:
                    const InputDecoration(labelText: 'Nome do Reportante'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(
                    labelText: 'Categoria de Atendimento'),
                items: _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              DropdownButtonFormField<String>(
                value: _prioridade,
                decoration:
                    const InputDecoration(labelText: 'Nível de Prioridade'),
                items: _prioridades
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _prioridade = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final novo = Chamado(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      titulo: _tituloController.text.trim(),
                      descricao: _descricaoController.text.trim(),
                      categoria: _categoria,
                      prioridade: _prioridade,
                      rua: _ruaController.text.trim(),
                      bairro: _bairroController.text.trim(),
                      responsavel: _responsavelController.text.trim(),
                      dataAbertura: DateTime.now(),
                      imagemBase64: _imagemBase64, // Anexando a string gerada
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
                child: const Text('Submeter Chamado Oficial',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
