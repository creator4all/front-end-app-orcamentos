import '../../domain/entities/report_user.dart';

/// DTO para conversão de JSON para entidade ReportUser.
///
/// Responsável por fazer o parsing dos dados vindos da API
/// e converter para a entidade de domínio.
class ReportUserDto {
  final int id;
  final String nome;
  final String email;
  final String cargo;
  final double totalVendas;
  final int aprovados;
  final int pendentes;
  final int expirados;
  final int naoAprovados;

  ReportUserDto({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.totalVendas,
    required this.aprovados,
    required this.pendentes,
    required this.expirados,
    required this.naoAprovados,
  });

  /// Cria um DTO a partir do JSON da API.
  ///
  /// A API retorna dados com estrutura:
  /// - usr_userId, usr_name, usr_email, usr_status
  /// - relations.role.rol_name (cargo)
  factory ReportUserDto.fromJson(Map<String, dynamic> json) {
    // Parsear cargo do role relacionado
    String cargo = 'Vendedor';

    // Tentar obter do campo "relations.role.rol_name"
    if (json['relations'] is Map<String, dynamic>) {
      final relations = json['relations'] as Map<String, dynamic>;
      if (relations['role'] is Map<String, dynamic>) {
        final role = relations['role'] as Map<String, dynamic>;
        cargo = role['rol_name'] ?? 'Vendedor';
      }
    }
    // Fallback para outros formatos
    else if (json['role'] is Map<String, dynamic>) {
      final role = json['role'] as Map<String, dynamic>;
      cargo = role['rol_name'] ?? role['name'] ?? 'Vendedor';
    } else if (json['cargo'] != null) {
      cargo = json['cargo'].toString();
    }

    // Parsear estatísticas - podem vir como números ou strings
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // Extrair atributos - podem estar em "attributes" ou diretamente no json
    final attributes = json['attributes'] is Map<String, dynamic>
        ? json['attributes'] as Map<String, dynamic>
        : json;

    return ReportUserDto(
      id: attributes['usr_userId'] ?? attributes['id'] ?? json['id'] ?? 0,
      nome: attributes['usr_name'] ??
          attributes['nome'] ??
          json['nome'] ??
          json['name'] ??
          '',
      email:
          attributes['usr_email'] ?? attributes['email'] ?? json['email'] ?? '',
      cargo: cargo,
      totalVendas: parseDouble(attributes['total_vendas'] ??
          json['total_vendas'] ??
          json['totalVendas']),
      aprovados: parseCount(attributes['aprovados'] ?? json['aprovados']),
      pendentes: parseCount(attributes['pendentes'] ?? json['pendentes']),
      expirados: parseCount(attributes['expirados'] ?? json['expirados']),
      naoAprovados: parseCount(attributes['nao_aprovados'] ??
          json['nao_aprovados'] ??
          json['naoAprovados']),
    );
  }

  /// Converte o DTO para a entidade de domínio.
  ReportUser toEntity() {
    return ReportUser(
      id: id,
      nome: nome,
      email: email,
      cargo: cargo,
      totalVendas: totalVendas,
      aprovados: aprovados,
      pendentes: pendentes,
      expirados: expirados,
      naoAprovados: naoAprovados,
    );
  }
}
