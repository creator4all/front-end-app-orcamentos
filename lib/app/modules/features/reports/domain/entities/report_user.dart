import 'package:equatable/equatable.dart';

class ReportUser extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String cargo;
  final double totalVendas;

  final int aprovados;
  final int pendentes;
  final int expirados;
  final int naoAprovados;
  final int rascunhos;

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
    this.rascunhos = 0,
  });

  int get totalOrcamentos =>
      aprovados + pendentes + expirados + naoAprovados + rascunhos;

  bool get isVendedor => cargo.toLowerCase() == 'vendedor';

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
        rascunhos,
      ];

  @override
  bool get stringify => true;
}
