class CidadeEntity {
  final int id;
  final String nome;
  final int estadoId;
  final int? censoAno;

  CidadeEntity({
    required this.id,
    required this.nome,
    required this.estadoId,
    this.censoAno,
  });

  factory CidadeEntity.fromJson(Map<String, dynamic> json) {
    final estadoId = json['estado_id'] ??
        json['estados_idestados'] ??
        (json['estado'] is Map
            ? (json['estado']['id'] ?? json['estado']['estado_id'])
            : null);
    final censoAno = json['censo_ano'];
    return CidadeEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      nome: (json['nome_cidade'] ?? json['nome'] ?? '').toString(),
      estadoId: estadoId is int ? estadoId : int.tryParse('$estadoId') ?? 0,
      censoAno: censoAno is int ? censoAno : int.tryParse('$censoAno'),
    );
  }
}
