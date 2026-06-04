class Chamado {
  String id;
  String titulo;
  String descricao;
  String categoria;
  String prioridade;
  String rua;
  String bairro;
  String responsavel;
  DateTime dataAbertura;
  DateTime? dataFechamento;
  String status;

  // Campos para Funcionalidades Extras
  bool isFavorito;
  double? latitude;
  double? longitude;
  String? imagemBase64; // Armazena a imagem codificada em texto

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.rua,
    required this.bairro,
    required this.responsavel,
    required this.dataAbertura,
    this.dataFechamento,
    this.status = 'Aberto',
    this.isFavorito = false,
    this.latitude,
    this.longitude,
    this.imagemBase64,
  });
}
