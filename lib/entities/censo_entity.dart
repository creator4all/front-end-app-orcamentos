class CensoGroupItem {
  final String name;
  final int value;

  CensoGroupItem({required this.name, required this.value});

  factory CensoGroupItem.fromJson(Map<String, dynamic> json) {
    final v = json['value'] ?? json['quantidade'] ?? 0;
    return CensoGroupItem(
      name: (json['name'] ?? json['nome'] ?? '').toString(),
      value: v is int ? v : int.tryParse('$v') ?? 0,
    );
  }
}

class CensoGroup {
  final String name;
  final List<CensoGroupItem> items;

  CensoGroup({required this.name, required this.items});

  factory CensoGroup.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] ?? json['itens'] ?? []) as List;
    return CensoGroup(
      name: (json['name'] ?? json['nome'] ?? '').toString(),
      items: items
          .map((e) => CensoGroupItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GrupoIndice {
  final int grupoId;
  final String nomeGrupo;

  GrupoIndice({
    required this.grupoId,
    required this.nomeGrupo,
  });

  factory GrupoIndice.fromJson(Map<String, dynamic> json) {
    return GrupoIndice(
      grupoId: json['grupo_id'] is int
          ? json['grupo_id'] as int
          : int.tryParse('${json['grupo_id']}') ?? 0,
      nomeGrupo: (json['nome_grupo'] ?? '').toString(),
    );
  }
}

class CidadeIndice {
  final int indiceEtapaId;
  final String nomeEtapa;
  final double valor;
  final GrupoIndice? grupo;

  CidadeIndice({
    required this.indiceEtapaId,
    required this.nomeEtapa,
    required this.valor,
    this.grupo,
  });

  factory CidadeIndice.fromJson(Map<String, dynamic> json) {
    return CidadeIndice(
      indiceEtapaId: json['indice_etapa_id'] is int
          ? json['indice_etapa_id'] as int
          : int.tryParse('${json['indice_etapa_id']}') ?? 0,
      nomeEtapa: (json['nome_etapa'] ?? '').toString(),
      valor: json['valor'] is double
          ? json['valor'] as double
          : double.tryParse('${json['valor']}') ?? 0.0,
      grupo: json['grupo'] != null
          ? GrupoIndice.fromJson(json['grupo'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CidadeData {
  final int id;
  final String nome;
  final int estadoId;
  final int? censoAno;
  final List<CidadeIndice> indicesEtapa;
  final Map<String, dynamic>? estado;

  CidadeData({
    required this.id,
    required this.nome,
    required this.estadoId,
    this.censoAno,
    required this.indicesEtapa,
    this.estado,
  });

  factory CidadeData.fromJson(Map<String, dynamic> json) {
    final indices = (json['indices_etapa'] ?? []) as List;
    return CidadeData(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      nome: (json['nome'] ?? '').toString(),
      estadoId: json['estado_id'] is int
          ? json['estado_id'] as int
          : int.tryParse('${json['estado_id']}') ?? 0,
      censoAno: json['censo_ano'] is int
          ? json['censo_ano'] as int
          : int.tryParse('${json['censo_ano']}'),
      indicesEtapa: indices
          .map((e) => CidadeIndice.fromJson(e as Map<String, dynamic>))
          .toList(),
      estado: json['estado'] as Map<String, dynamic>?,
    );
  }

  int get totalEstudantes =>
      indicesEtapa.fold(0, (sum, item) => sum + item.valor.toInt());
  int get quantidadeTurmas => indicesEtapa.length;
}

class CensoData {
  final int totalStudents;
  final String censusYear;
  final List<CensoGroup> groups;
  final CidadeData? cidadeData;

  CensoData(
      {required this.totalStudents,
      required this.censusYear,
      required this.groups,
      this.cidadeData});

  factory CensoData.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] ?? json['grupos'] ?? []) as List;
    final total = json['totalStudents'] ?? json['total_alunos'] ?? 0;
    final cidadeData = json['id'] != null ? CidadeData.fromJson(json) : null;

    return CensoData(
      totalStudents: total is int ? total : int.tryParse('$total') ?? 0,
      censusYear: (json['censusYear'] ?? json['ano'] ?? json['censo_ano'] ?? '')
          .toString(),
      groups: groups
          .map((e) => CensoGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      cidadeData: cidadeData,
    );
  }
}
