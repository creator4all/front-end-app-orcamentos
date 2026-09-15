import 'dart:io';

import 'package:mobx/mobx.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/avatar_image_validator.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final ProfileRepository _repository;
  final AvatarImageValidator _avatarImageValidator;
  _ProfileStore(this._repository, this._avatarImageValidator);

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  bool isUploadingAvatar = false;

  @observable
  String? error;

  @observable
  UserProfile? profile;

  @observable
  String name = '';

  @observable
  String email = '';

  @observable
  String cargo = '';

  @observable
  String phone = '';

  @action
  Future<void> fetch() async {
    isLoading = true;
    error = null;

    final result = await _repository.getProfile();

    result.fold(
      (failure) => error = failure.message,
      (userProfile) {
        profile = userProfile;
        name = userProfile.name;
        email = userProfile.email;
        cargo = userProfile.cargo ?? '';
        phone = userProfile.phone ?? '';
      },
    );

    isLoading = false;
  }

  @action
  void setName(String value) {
    name = value;
  }

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setCargo(String value) {
    cargo = value;
  }

  @action
  void setPhone(String value) {
    phone = value;
  }

  @action
  Future<bool> save() async {
    isSaving = true;
    error = null;

    // `PUT /api/perfil/me` valida atualização completa: todas as chaves do
    // schema precisam estar presentes. `partners_par_partnerId` é reenviado
    // como veio do perfil porque o backend só o descarta para quem não é
    // administrador — omiti-lo desvincularia a empresa de um usuário admin.
    final dados = {
      'usr_name': name,
      'usr_email': email,
      'usr_cargo': cargo,
      'usr_phone': phone,
      'partners_par_partnerId': profile?.partnerId,
    };

    final result = await _repository.updateProfile(dados);

    bool success = false;
    result.fold(
      (failure) => error = failure.message,
      (userProfile) {
        profile = userProfile;
        name = userProfile.name;
        email = userProfile.email;
        cargo = userProfile.cargo ?? '';
        phone = userProfile.phone ?? '';
        success = true;
      },
    );

    isSaving = false;
    return success;
  }

  @action
  Future<bool> uploadAvatar({
    required Future<String?> Function() selectOriginal,
    required Future<String?> Function(String path) cropImage,
    required bool Function() isActive,
  }) async {
    if (isUploadingAvatar) return false;
    isUploadingAvatar = true;
    error = null;

    try {
      final originalPath = await selectOriginal();
      if (!isActive() || originalPath == null) return false;
      final originalValidation =
          await _avatarImageValidator.validate(originalPath);
      if (!isActive()) return false;
      if (!_acceptAvatar(originalValidation)) return false;

      final croppedPath = await cropImage(originalPath);
      if (!isActive() || croppedPath == null) return false;
      final finalValidation =
          await _avatarImageValidator.validate(croppedPath, jpegOnly: true);
      if (!isActive()) return false;
      if (!_acceptAvatar(finalValidation)) return false;

      final result = await _repository.uploadAvatar(File(croppedPath));
      if (!isActive()) return false;
      return result.fold(
        (failure) {
          error = failure.message;
          return false;
        },
        (userProfile) {
          profile = userProfile;
          return true;
        },
      );
    } catch (_) {
      if (isActive()) {
        error =
            'Não foi possível abrir ou atualizar a imagem. Tente novamente.';
      }
      return false;
    } finally {
      isUploadingAvatar = false;
    }
  }

  bool _acceptAvatar(AvatarImageValidation validation) {
    switch (validation) {
      case AvatarImageValidation.valid:
        return true;
      case AvatarImageValidation.tooLarge:
        error = 'A imagem excede o tamanho máximo de 5 MB.';
        return false;
      case AvatarImageValidation.invalid:
        error = 'O arquivo não é uma imagem válida ou não pode ser aberto.';
        return false;
    }
  }

  @action
  Future<bool> removeAvatar() async {
    isUploadingAvatar = true;
    error = null;

    final result = await _repository.removeAvatar();

    bool success = false;
    result.fold(
      (failure) => error = failure.message,
      (userProfile) {
        profile = userProfile;
        success = true;
      },
    );

    isUploadingAvatar = false;
    return success;
  }

  @action
  void reset() {
    if (profile != null) {
      name = profile!.name;
      email = profile!.email;
      cargo = profile!.cargo ?? '';
      phone = profile!.phone ?? '';
    }
  }
}
