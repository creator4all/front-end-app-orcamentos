import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/partner_request.dart';
import '../../domain/entities/user_registration.dart';
import '../../domain/repositories/registration_repository.dart';
import '../datasources/registration_datasource.dart';
import '../models/partner_request_dto.dart';
import '../models/user_registration_dto.dart';

/// Implementação do repository de registro
class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationDatasource datasource;

  RegistrationRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Company>> verifyDocument(String documento) async {
    try {
      final response = await datasource.verifyDocument(documento);

      if (!response.existe) {
        return const Left(
          ValidationFailure('Empresa não encontrada com o CNPJ informado.'),
        );
      }

      if (response.empresa == null) {
        return const Left(
          ServerFailure('Erro ao carregar dados da empresa.'),
        );
      }

      return Right(response.empresa!.toEntity());
    } catch (e) {
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão') ||
          e.toString().contains('SocketException')) {
        return const Left(
          NetworkFailure(
              'Falha na conexão. Verifique sua internet e tente novamente.'),
        );
      }
      return Left(ServerFailure('Erro ao verificar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(
      UserRegistration registration) async {
    try {
      final dto = UserRegistrationDto.fromEntity(registration);
      await datasource.registerUser(dto);
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão') ||
          e.toString().contains('SocketException')) {
        return const Left(
          NetworkFailure(
              'Falha na conexão. Verifique sua internet e tente novamente.'),
        );
      }
      if (e.toString().contains('409') || e.toString().contains('duplicate')) {
        return const Left(
          ValidationFailure('Este e-mail já está cadastrado no sistema.'),
        );
      }
      return Left(ServerFailure('Erro ao cadastrar usuário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPartner(PartnerRequest request) async {
    try {
      final dto = PartnerRequestDto.fromEntity(request);
      await datasource.requestPartner(dto);
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão') ||
          e.toString().contains('SocketException')) {
        return const Left(
          NetworkFailure(
              'Falha na conexão. Verifique sua internet e tente novamente.'),
        );
      }
      return Left(ServerFailure('Erro ao enviar solicitação: $e'));
    }
  }
}
