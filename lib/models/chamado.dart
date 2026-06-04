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
  String status;

  // Novos campos para Funcionalidades Extras
  bool isFavorito;
  double? latitude;
  double? longitude;

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
    this.status = 'Aberto',
    this.isFavorito = false,
    this.latitude,
    this.longitude,
  });
}
