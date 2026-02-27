import '../../domain/entities/indicador_etapa_entity.dart';

class IndicadorEtapaDTO {
  final int produtoIndicadorId;
  final int indicadorId;
  final String indicadorNome;
  final String? nomeEtapa;
  final int grupoId;
  final String grupoNome;
  final bool selecionado;
  final bool? valorPadrao;

  IndicadorEtapaDTO({
    required this.produtoIndicadorId,
    required this.indicadorId,
    required this.indicadorNome,
    this.nomeEtapa,
    required this.grupoId,
    required this.grupoNome,
    required this.selecionado,
    this.valorPadrao,
  });

  factory IndicadorEtapaDTO.fromJson(Map<String, dynamic> json) {
    try {
      return IndicadorEtapaDTO(
        produtoIndicadorId: json['produto_indicador_id'] as int,
        indicadorId: json['indicador_id'] as int,
        indicadorNome: json['indicador_nome'] as String,
        nomeEtapa: json['nome_etapa'] as String?,
        grupoId: json['grupo_id'] as int,
        grupoNome: json['grupo_nome'] as String,
        selecionado: json['selecionado'] as bool,
        valorPadrao: json['valor_padrao'] as bool?,
      );
    } catch (e) {
      throw Exception(
          'Erro ao fazer parse de IndicadorEtapaDTO: $e - JSON: $json');
    }
  }

  IndicadorEtapaEntity toEntity() {
    return IndicadorEtapaEntity(
      produtoIndicadorId: produtoIndicadorId,
      indicadorId: indicadorId,
      indicadorNome: indicadorNome,
      nomeEtapa: nomeEtapa ??
          indicadorNome,
      grupoId: grupoId,
      grupoNome: grupoNome,
      selecionado: selecionado,
      valorPadrao: valorPadrao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produto_indicador_id': produtoIndicadorId,
      'indicador_id': indicadorId,
      'indicador_nome': indicadorNome,
      'nome_etapa': nomeEtapa,
      'grupo_id': grupoId,
      'grupo_nome': grupoNome,
      'selecionado': selecionado,
      'valor_padrao': valorPadrao,
    };
  }

  factory IndicadorEtapaDTO.fromEntity(IndicadorEtapaEntity entity) {
    return IndicadorEtapaDTO(
      produtoIndicadorId: entity.produtoIndicadorId,
      indicadorId: entity.indicadorId,
      indicadorNome: entity.indicadorNome,
      nomeEtapa: entity.nomeEtapa,
      grupoId: entity.grupoId,
      grupoNome: entity.grupoNome,
      selecionado: entity.selecionado,
      valorPadrao: entity.valorPadrao,
    );
  }
}
