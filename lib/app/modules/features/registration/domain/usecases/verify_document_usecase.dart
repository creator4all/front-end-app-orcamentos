import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/company.dart';
import '../repositories/registration_repository.dart';

/// Use case para verificar documento (CNPJ) e buscar empresa
class VerifyDocumentUseCase {
  final RegistrationRepository repository;

  VerifyDocumentUseCase(this.repository);

  /// Executa a busca de empresa por documento
  /// Retorna [Company] se encontrada e ativa
  Future<Either<Failure, Company>> call(String documento) {
    // Remove formatação do documento (pontos, traços, barras)
    final cleanDocumento = documento.replaceAll(RegExp(r'[^0-9]'), '');
    return repository.verifyDocument(cleanDocumento);
  }
}
