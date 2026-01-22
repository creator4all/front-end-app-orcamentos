import 'package:equatable/equatable.dart';

/// Entidade representando um usuário com estatísticas de vendas
/// para o módulo de relatórios.
///
/// Esta classe não tem dependência de JSON, API ou camada de dados.
/// Representa as regras de negócio puras da aplicação.
class ReportUser extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String cargo; // "Vendedor", "Gerente", "Gestor"
  final double totalVendas;

  // Contagem por status
  final int aprovados;
  final int pendentes;
  final int expirados;
  final int naoAprovados;

  const ReportUser({
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

  /// Total de orçamentos do usuário
  int get totalOrcamentos => aprovados + pendentes + expirados + naoAprovados;

  /// Verifica se o usuário é um vendedor
  bool get isVendedor => cargo.toLowerCase() == 'vendedor';

  /// Verifica se o usuário é um gestor/gerente
  bool get isGestor =>
      cargo.toLowerCase() == 'gestor' || cargo.toLowerCase() == 'gerente';

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        cargo,
        totalVendas,
        aprovados,
        pendentes,
        expirados,
        naoAprovados,
      ];

  @override
  String toString() {
    return 'ReportUser(id: $id, nome: $nome, cargo: $cargo, totalVendas: $totalVendas)';
  }
}
