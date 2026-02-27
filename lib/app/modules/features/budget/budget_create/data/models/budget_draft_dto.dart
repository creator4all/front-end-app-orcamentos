import '../../../../../../../app/shared/utils/date_utils.dart';
import '../../../budget_config/data/models/category_dto.dart' as config;
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/location_entity.dart';
import 'cidade_dto.dart';
import 'orcamento_produto_dto.dart';

class BudgetDraftDto {
  final int id;
  final String? name;
  final int? partnerId;
  final String? partnerName;
  final int userId;
  final String userName;
  final String userEmail;
  final List<int> cityIds;
  final List<String> cityNames;
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
  final List<config.CategoryDTO> categories;

  const BudgetDraftDto({
    required this.id,
    this.name,
    this.partnerId,
    this.partnerName,
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
    this.categories = const [],
  });

  factory BudgetDraftDto.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>?;
    final partnerDestino = json['partner_destino'] as Map<String, dynamic>?;
    final cidadeJson = json['cidade'] as Map<String, dynamic>?;
    final produtosArray = json['orcamento_produtos'] as List? ?? [];
    final categoriasArray = json['categorias'] as List? ?? [];

    final cityId = (json['cidade_id'] as num?)?.toInt() ?? 0;
    final cityName = cidadeJson?['nome'] as String? ?? '';
    final cityIds = cityId > 0 ? [cityId] : <int>[];
    final cityNames = cityName.isNotEmpty ? [cityName] : <String>[];

    final validityDateStr = json['data_validade'];
    final parsedValidityDate = validityDateStr != null
        ? DateTime.parse(validityDateStr as String)
        : DateTime.now();

    final orcamentoProdutos = produtosArray
        .map((item) =>
            OrcamentoProdutoDto.fromJson(item as Map<String, dynamic>))
        .toList();

    final categories = categoriasArray
        .map(
            (item) => config.CategoryDTO.fromJson(item as Map<String, dynamic>))
        .toList();

    final cidade = cidadeJson != null ? CidadeDto.fromJson(cidadeJson) : null;

    return BudgetDraftDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['nome'] as String?,
      partnerId: partnerDestino?['id'] != null
          ? (partnerDestino!['id'] as num?)?.toInt()
          : null,
      partnerName: partnerDestino?['nome_fantasia'] as String?,
      userId: (usuario?['id'] as num?)?.toInt() ?? 0,
      userName: usuario?['nome'] as String? ?? '',
      userEmail: usuario?['email'] as String? ?? '',
      cityIds: cityIds,
      cityNames: cityNames,
      responsibleName: json['orc_responsavel_nome'] as String?,
      responsibleEmail: json['orc_responsavel_email'] as String?,
      validityDate: parsedValidityDate,
      validityDays: (json['dias_validade'] as num?)?.toInt() ?? 60,
      status: json['status'] as String? ?? 'rascunho',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdByAdmin: json['criado_por_admin'] as bool? ?? false,
      createdAt: parseDate(json['created_at']),
      dataValidade: parsedValidityDate,
      cidade: cidade,
      orcamentoProdutos: orcamentoProdutos,
      categories: categories,
    );
  }

  BudgetDraftEntity toEntity() {
    return BudgetDraftEntity(
      id: id,
      name: name,
      partnerId: partnerId,
      partnerName: partnerName ?? '',
      location: LocationEntity(
        stateCode: '',
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
      orcamentoProdutos:
          orcamentoProdutos.map((dto) => dto.toEntity()).toList(),
      categories: categories.map((dto) => dto.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'nome': name,
      'usuario_id': userId,
      'cidades': cityIds,
      'status': status,
      'total': total,
      'dias_validade': validityDays,
      'data_validade': validityDate?.toIso8601String(),
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
