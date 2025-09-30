class EstadoEntity {
  final int id;
  final String nome;
  final String uf;

  EstadoEntity({required this.id, required this.nome, required this.uf});

  factory EstadoEntity.fromJson(Map<String, dynamic> json) {
    return EstadoEntity(
      id: json['id_estado'] is int
          ? json['id_estado'] as int
          : int.tryParse('${json['id_estado']}') ?? 0,
      nome: (json['nome_estado'] ?? json['nome'] ?? '').toString(),
      uf: (json['uf'] ?? '').toString(),
    );
  }
}
