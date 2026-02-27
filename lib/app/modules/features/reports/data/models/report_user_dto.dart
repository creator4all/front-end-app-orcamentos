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
  /// Contrato do endpoint `/api/partners/{id}/usuarios`:
  /// `{ usr_userId, usr_name, usr_email, usr_status, role: { rol_name } }`
  ///
  /// Estatísticas de vendas não vêm desse endpoint — são
  /// calculadas pelo store cruzando com `/api/relatorios/.../vendas`.
  factory ReportUserDto.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;

    return ReportUserDto(
      id: json['usr_userId'] ?? 0,
      nome: json['usr_name'] ?? '',
      email: json['usr_email'] ?? '',
      cargo: role?['rol_name'] ?? 'Vendedor',
      totalVendas: 0.0,
      aprovados: 0,
      pendentes: 0,
      expirados: 0,
      naoAprovados: 0,
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
