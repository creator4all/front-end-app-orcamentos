import 'package:equatable/equatable.dart';

import 'indicador_update_dto.dart';
import 'product_selection_update_dto.dart';

/// DTO principal para atualização de orçamentos
///
/// Usado por:
/// - **budget_config**: Salvar orçamento como "pendente" após configuração
/// - **budget_edit**: Editar orçamento existente (produtos, status, dados gerais)
///
/// Endpoint: `PUT /api/orcamentos/{id}`
///
/// Suporta **partial updates** - apenas campos não-nulos são enviados à API.
/// Isso permite atualizar apenas os campos necessários sem sobrescrever outros dados.
///
/// Exemplo de uso em budget_config:
/// ```dart
/// final dto = BudgetUpdateDto(
///   status: 'pendente',
///   total: 15000.00,
///   diasValidade: 90,
///   produtos: [...],
/// );
/// ```
///
/// Exemplo de uso em budget_edit:
/// ```dart
/// final dto = BudgetUpdateDto(
///   status: 'aprovado',
///   nome: 'São Paulo - SP Atualizado',
///   produtos: [...],
/// );
/// ```
class BudgetUpdateDto extends Equatable {
  /// Nome do orçamento (opcional)
  /// Ex: "São Paulo - SP"
  final String? nome;

  /// Dias de validade do orçamento (1-365)
  final int? diasValidade;

  /// Status do orçamento
  /// Valores: 'rascunho', 'pendente', 'arquivado', 'aprovado', 'expirado', 'nao_aprovado'
  ///
  /// **budget_config**: Sempre envia 'pendente'
  /// **budget_edit**: Usuário escolhe o status
  final String? status;

  /// Indica se o orçamento está arquivado
  ///
  /// **budget_config**: Sempre false
  /// **budget_edit**: Usuário pode arquivar/desarquivar
  final bool? isArchived;

  /// Total calculado do orçamento
  final double? total;

  /// Array de IDs de cidades (relação N:N)
  ///
  /// **Importante**: Usado para adicionar/remover cidades via tabela pivô.
  /// Não confundir com modificação de valores de indicadores.
  final List<int>? cidades;

  /// Array de indicadores do Censo Escolar com valores atualizados
  ///
  /// Permite modificar VALORES dos indicadores (quantidades de alunos, turmas, etc)
  /// sem alterar as cidades do orçamento.
  final List<IndicadorUpdateDto>? indicadores;

  /// Array de produtos com estado de seleção e quantidade
  ///
  /// Sincroniza todos os produtos do orçamento (selecionados e não selecionados)
  /// com seus estados atuais.
  final List<ProductSelectionUpdateDto>? produtos;

  /// ID do parceiro destino (apenas admin pode alterar)
  final int? partnerDestinoId;

  const BudgetUpdateDto({
    this.nome,
    this.diasValidade,
    this.status,
    this.isArchived,
    this.total,
    this.cidades,
    this.indicadores,
    this.produtos,
    this.partnerDestinoId,
  });

  /// Converte para Map para envio via API
  ///
  /// Apenas campos não-nulos são incluídos (partial update)
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (nome != null) map['orc_nome'] = nome;
    if (diasValidade != null) map['orc_dias_validade'] = diasValidade;
    if (status != null) map['orc_status'] = status;
    if (isArchived != null) map['orc_arquivado'] = isArchived;
    if (total != null) map['orc_total'] = total;
    if (cidades != null) map['cidades'] = cidades;
    if (indicadores != null) {
      map['indicadores'] = indicadores!.map((i) => i.toJson()).toList();
    }
    if (produtos != null) {
      map['produtos'] = produtos!.map((p) => p.toJson()).toList();
    }
    if (partnerDestinoId != null) {
      map['orc_partner_destino_id'] = partnerDestinoId;
    }

    return map;
  }

  @override
  List<Object?> get props => [
        nome,
        diasValidade,
        status,
        isArchived,
        total,
        cidades,
        indicadores,
        produtos,
        partnerDestinoId,
      ];

  @override
  String toString() {
    return 'BudgetUpdateDto('
        'nome: $nome, '
        'diasValidade: $diasValidade, '
        'status: $status, '
        'isArchived: $isArchived, '
        'total: $total, '
        'cidades: ${cidades?.length ?? 0}, '
        'indicadores: ${indicadores?.length ?? 0}, '
        'produtos: ${produtos?.length ?? 0}, '
        'partnerDestinoId: $partnerDestinoId'
        ')';
  }
}
