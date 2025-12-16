import '../../domain/entities/indicador_etapa_entity.dart';

/// DTO para parsing JSON dos indicadores de etapa da API
class IndicadorEtapaDTO {
  final int produtoIndicadorId;
  final int indicadorId;
  final String indicadorNome;
  final String? nomeEtapa; // Nome técnico (ex: ef1ano)
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

  /// Cria um DTO a partir do JSON da API
  ///
  /// Estrutura esperada da API:
  /// ```json
  /// {
  ///   "produto_indicador_id": 1399,
  ///   "indicador_id": 19,
  ///   "indicador_nome": "Cursistas",
  ///   "nome_etapa": "cursistas",
  ///   "grupo_id": 5,
  ///   "grupo_nome": "Cursistas",
  ///   "selecionado": true,
  ///   "valor_padrao": true
  /// }
  /// ```
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

  /// Converte o DTO para Entity
  IndicadorEtapaEntity toEntity() {
    return IndicadorEtapaEntity(
      produtoIndicadorId: produtoIndicadorId,
      indicadorId: indicadorId,
      indicadorNome: indicadorNome,
      nomeEtapa: nomeEtapa ??
          indicadorNome, // Fallback para indicadorNome se nomeEtapa for nulo
      grupoId: grupoId,
      grupoNome: grupoNome,
      selecionado: selecionado,
      valorPadrao: valorPadrao,
    );
  }

  /// Converte o DTO para JSON
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

  /// Converte uma Entity para DTO
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
