import 'package:equatable/equatable.dart';

/// Classe abstrata base para todos os failures relacionados a orçamentos
abstract class BudgetFailure extends Equatable {
  final String message;

  const BudgetFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Falha ao buscar dados da API
class ServerFailure extends BudgetFailure {
  const ServerFailure([super.message = 'Erro no servidor']);
}

/// Falha de conexão com a internet
class ConnectionFailure extends BudgetFailure {
  const ConnectionFailure([super.message = 'Sem conexão com a internet']);
}

/// Falha de validação de dados
class ValidationFailure extends BudgetFailure {
  const ValidationFailure([super.message = 'Dados inválidos']);
}

/// Falha de autorização/autenticação
class UnauthorizedFailure extends BudgetFailure {
  const UnauthorizedFailure([super.message = 'Não autorizado']);
}

/// Falha quando recurso não é encontrado
class NotFoundFailure extends BudgetFailure {
  const NotFoundFailure([super.message = 'Recurso não encontrado']);
}

/// Falha genérica/desconhecida
class UnknownFailure extends BudgetFailure {
  const UnknownFailure([super.message = 'Erro desconhecido']);
}

/// Falha de cache local
class CacheFailure extends BudgetFailure {
  const CacheFailure([super.message = 'Erro ao acessar cache local']);
}
