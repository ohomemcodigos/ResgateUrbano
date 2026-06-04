class Chamado {
  String id;
  String titulo;
  String descricao;
  String categoria;
  String prioridade;
  String bairro;
  String responsavel;
  DateTime dataAbertura;
  String status;

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.dataAbertura,
    this.status = 'Aberto',
  });
}
