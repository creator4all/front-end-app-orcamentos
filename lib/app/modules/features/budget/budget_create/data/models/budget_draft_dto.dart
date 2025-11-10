import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/location_entity.dart';
import 'cidade_dto.dart';
import 'orcamento_produto_dto.dart';

/// Data Transfer Object para Orçamento em Rascunho
/// Responsável pela serialização/deserialização de JSON
class BudgetDraftDto {
  final int id;
  final String? name;
  final int?
      partnerId; // ✅ Nullable - só existe quando admin escolhe parceiro destino
  final String? partnerName; // ✅ Nullable
  final int userId;
  final String userName;
  final String userEmail;
  final List<int> cityIds; // Lista de IDs das cidades
  final List<String> cityNames; // Lista de nomes das cidades
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime validityDate;
  final int validityDays;
  final String status;
  final double total;
  final bool createdByAdmin;
  final DateTime? createdAt;
  final DateTime dataValidade;
  final CidadeDto? cidade;
  final List<OrcamentoProdutoDto> orcamentoProdutos;

  const BudgetDraftDto({
    required this.id,
    this.name,
    this.partnerId, // ✅ Nullable
    this.partnerName, // ✅ Nullable
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cityIds,
    required this.cityNames,
    this.responsibleName,
    this.responsibleEmail,
    required this.validityDate,
    required this.validityDays,
    required this.status,
    required this.total,
    required this.createdByAdmin,
    this.createdAt,
    required this.dataValidade,
    this.cidade,
    required this.orcamentoProdutos,
  });

  /// Cria DTO a partir de JSON da API
  factory BudgetDraftDto.fromJson(Map<String, dynamic> json) {
    try {
      // Parse novo payload com orc_cidade_id (single value)
      final cityId = (json['orc_cidade_id'] as num?)?.toInt() ?? 0;
      final cityName = json['orc_nome'] as String? ?? '';
      
      final cityIds = cityId > 0 ? [cityId] : <int>[];
      final cityNames = cityName.isNotEmpty ? [cityName] : <String>[];

      // Parse usuario (pode ser null)
      final usuario = json['usuario'] as Map<String, dynamic>?;

      // Parse partner_destino (pode ser null)
      final partnerDestino = json['partner_destino'] as Map<String, dynamic>?;

      // Parse user ID com segurança
      final userId = usuario?['id'];
      final parsedUserId = userId != null ? (userId as num).toInt() : 0;

      // Parse validity date com segurança
      final validityDateStr = json['orc_data_validade'];
      final parsedValidityDate = validityDateStr != null
          ? DateTime.parse(validityDateStr as String)
          : DateTime.now();

      // Parse validity days com segurança
      final validityDaysValue = json['orc_dias_validade'];
      final parsedValidityDays =
          validityDaysValue != null ? (validityDaysValue as num).toInt() : 60;

      // Parse total com segurança
      final totalValue = json['orc_total'];
      final parsedTotal =
          totalValue != null ? (totalValue as num).toDouble() : 0.0;

      // Parse cidade completa
      final cidadeJson = json['cidade'] as Map<String, dynamic>?;
      final cidade = cidadeJson != null ? CidadeDto.fromJson(cidadeJson) : null;

      // Parse orcamento_produtos array
      final produtosArray = json['orcamento_produtos'] as List? ?? [];
      final orcamentoProdutos = produtosArray
          .map((item) => OrcamentoProdutoDto.fromJson(item as Map<String, dynamic>))
          .toList();

      return BudgetDraftDto(
        id: (json['orc_orcamentoId'] as num?)?.toInt() ?? 0,
        name: json['orc_nome'] as String?,
        partnerId: partnerDestino?['id'] != null
            ? (partnerDestino?['id'] as num?)?.toInt()
            : null,
        partnerName: partnerDestino?['nome_fantasia'] as String?,
        userId: parsedUserId,
        userName: usuario?['nome'] as String? ?? '',
        userEmail: usuario?['email'] as String? ?? '',
        cityIds: cityIds,
        cityNames: cityNames,
        responsibleName: json['orc_responsavel_nome'] as String?,
        responsibleEmail: json['orc_responsavel_email'] as String?,
        validityDate: parsedValidityDate,
        validityDays: parsedValidityDays,
        status: json['orc_status'] as String? ?? 'rascunho',
        total: parsedTotal,
        createdByAdmin: json['orc_criado_por_admin'] as bool? ?? false,
        createdAt: _parseDate(json['created_at']),
        dataValidade: parsedValidityDate,
        cidade: cidade,
        orcamentoProdutos: orcamentoProdutos,
      );
    } catch (e, stackTrace) {
      print('❌ [BudgetDraftDto] Erro ao parsear JSON:');
      print('   JSON recebido: $json');
      print('   Erro: $e');
      print('   StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Parse de data (pode vir em diferentes formatos)
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Converte DTO para Entity
  BudgetDraftEntity toEntity() {
    return BudgetDraftEntity(
      id: id,
      partnerId: partnerId, // ✅ Nullable
      partnerName: partnerName ?? '', // Default vazio se null
      location: LocationEntity(
        stateCode: '', // Estado não vem mais na response
        stateName: '',
        cityCode: cityIds.isNotEmpty ? cityIds.first.toString() : '',
        cityName: cityNames.isNotEmpty ? cityNames.first : '',
      ),
      responsibleName: responsibleName,
      responsibleEmail: responsibleEmail,
      validityDate: validityDate,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      createdByUserId: userId,
      validityDays: validityDays,
      total: total,
      createdByAdmin: createdByAdmin,
      dataValidade: dataValidade,
      cidade: cidade?.toEntity(),
      orcamentoProdutos: orcamentoProdutos.map((dto) => dto.toEntity()).toList(),
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'nome': name,
      'usuario_id': userId,
      'cidades': cityIds,
      'status': status,
      'total': total,
      'dias_validade': validityDays,
      'data_validade': validityDate.toIso8601String(),
      'criado_por_admin': createdByAdmin,
    };

    if (partnerId != null) {
      data['partner_destino_id'] = partnerId;
    }

    if (responsibleName != null) {
      data['orc_responsavel_nome'] = responsibleName;
    }

    if (responsibleEmail != null) {
      data['orc_responsavel_email'] = responsibleEmail;
    }

    return data;
  }
}
