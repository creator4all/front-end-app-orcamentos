import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user_profile.dart';

/// Store chama este repositório diretamente (sem UseCases).
abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  Future<Either<Failure, UserProfile>> updateProfile(Map<String, dynamic> data);

  Future<Either<Failure, String>> deleteAccount();

  Future<Either<Failure, UserProfile>> uploadAvatar(File imageFile);

  Future<Either<Failure, UserProfile>> removeAvatar();
}
