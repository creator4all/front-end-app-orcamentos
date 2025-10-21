import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/location_entity.dart';

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
  });

  /// Cria DTO a partir de JSON da API
  factory BudgetDraftDto.fromJson(Map<String, dynamic> json) {
    try {
      // Parse cidades array
      final cidadesArray = json['cidades'] as List? ?? [];
      final cityIds = <int>[];
      final cityNames = <String>[];

      for (var cidade in cidadesArray) {
        if (cidade is Map<String, dynamic>) {
          final cidadeId = cidade['id'];
          if (cidadeId != null) {
            cityIds.add((cidadeId as num).toInt());
            cityNames.add(cidade['nome'] as String? ?? '');
          }
        }
      }

      // Parse usuario
      final usuario = json['usuario'] as Map<String, dynamic>?;

      // Parse partner_destino (pode ser null)
      final partnerDestino = json['partner_destino'] as Map<String, dynamic>?;

      // Parse user ID com segurança
      final userId = usuario?['id'];
      final parsedUserId = userId != null ? (userId as num).toInt() : 0;

      // Parse validity date com segurança
      final validityDateStr = json['data_validade'];
      final parsedValidityDate = validityDateStr != null
          ? DateTime.parse(validityDateStr as String)
          : DateTime.now();

      // Parse validity days com segurança
      final validityDaysValue = json['dias_validade'];
      final parsedValidityDays =
          validityDaysValue != null ? (validityDaysValue as num).toInt() : 0;

      // Parse total com segurança
      final totalValue = json['total'];
      final parsedTotal =
          totalValue != null ? (totalValue as num).toDouble() : 0.0;

      print('📊 [BudgetDraftDto] Parseando:');
      try {
        print(
            '   id: ${json['id']} (type: ${json['id'] != null ? json['id'].runtimeType : 'null'})');
        print(
            '   dias_validade: $validityDaysValue (type: ${validityDaysValue != null ? validityDaysValue.runtimeType : 'null'})');
        print(
            '   total: $totalValue (type: ${totalValue != null ? totalValue.runtimeType : 'null'})');
        print(
            '   data_validade: $validityDateStr (type: ${validityDateStr != null ? validityDateStr.runtimeType : 'null'})');
      } catch (_) {
        // runtimeType access can sometimes throw on web or unusual objects; ignore logging in that case
      }

      return BudgetDraftDto(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['nome'] as String?,
        partnerId: partnerDestino?['id'] != null
            ? (partnerDestino?['id'] as num?)?.toInt()
            : null,
        partnerName: partnerDestino?['nome_fantasia'] as String?, // ✅ Nullable
        userId: parsedUserId,
        userName: usuario?['nome'] as String? ?? '',
        userEmail: usuario?['email'] as String? ?? '',
        cityIds: cityIds,
        cityNames: cityNames,
        responsibleName: json['orc_responsavel_nome'] as String?,
        responsibleEmail: json['orc_responsavel_email'] as String?,
        validityDate: parsedValidityDate,
        validityDays: parsedValidityDays,
        status: json['status'] as String? ?? '',
        total: parsedTotal,
        createdByAdmin: json['criado_por_admin'] as bool? ?? false,
        createdAt: _parseDate(json['created_at']),
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
