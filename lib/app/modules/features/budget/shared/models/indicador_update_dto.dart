import 'package:equatable/equatable.dart';

/// DTO para atualização de indicadores do Censo Escolar
///
/// Usado tanto por budget_config quanto budget_edit para enviar
/// valores atualizados dos indicadores (quantidades de alunos, turmas, etc)
/// ao endpoint PUT /api/orcamentos/{id}
///
/// Mapeia para o formato da API:
/// ```json
/// {
///   "cidade_id": 3550308,
///   "ine_indice_etapa_id": 1,
///   "valor": 500.0
/// }
/// ```
///
/// **Importante**: Este DTO permite modificar apenas os VALORES dos indicadores,
/// não as cidades do orçamento. As cidades são fixas após a criação.
class IndicadorUpdateDto extends Equatable {
  /// ID da cidade (referência à cidade do orçamento)
  final int cidadeId;

  /// ID do índice/etapa do Censo Escolar
  /// Exemplos: Turmas EF1, Alunos EF2, etc
  final int indiceEtapaId;

  /// Valor do indicador (quantidade de alunos, turmas, etc)
  final double valor;

  const IndicadorUpdateDto({
    required this.cidadeId,
    required this.indiceEtapaId,
    required this.valor,
  });

  /// Converte para Map para envio via API
  Map<String, dynamic> toJson() => {
        'cidade_id': cidadeId,
        'ine_indice_etapa_id': indiceEtapaId,
        'valor': valor,
      };

  @override
  List<Object?> get props => [cidadeId, indiceEtapaId, valor];

  @override
  String toString() =>
      'IndicadorUpdateDto(cidadeId: $cidadeId, indiceEtapaId: $indiceEtapaId, valor: $valor)';
}
