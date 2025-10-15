import 'package:equatable/equatable.dart';

/// Classe base para falhas do módulo New Drive
abstract class NewDriveFailure extends Equatable {
  final String message;

  const NewDriveFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Falha ao carregar itens recentes
class LoadRecentItemsFailure extends NewDriveFailure {
  const LoadRecentItemsFailure(super.message);
}

/// Falha ao carregar categorias
class LoadCategoriesFailure extends NewDriveFailure {
  const LoadCategoriesFailure(super.message);
}

/// Falha ao buscar arquivos
class SearchFilesFailure extends NewDriveFailure {
  const SearchFilesFailure(super.message);
}

/// Falha de conexão
class ConnectionFailure extends NewDriveFailure {
  const ConnectionFailure(super.message);
}
