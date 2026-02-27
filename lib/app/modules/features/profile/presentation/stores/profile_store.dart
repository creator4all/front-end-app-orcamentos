import 'dart:io';

import 'package:mobx/mobx.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final ProfileRepository _repository;
  _ProfileStore(this._repository);

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

  @observable
  File? selectedAvatar;

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
  void setSelectedAvatar(File? file) {
    selectedAvatar = file;
  }

  @action
  Future<bool> save() async {
    isSaving = true;
    error = null;

    final dados = {
      'usr_name': name,
      'usr_email': email,
      'usr_cargo': cargo.isEmpty ? null : cargo,
      'usr_phone': phone.isEmpty ? null : phone,
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
  Future<bool> uploadAvatar() async {
    if (selectedAvatar == null) {
      error = 'Nenhuma imagem selecionada';
      return false;
    }

    isUploadingAvatar = true;
    error = null;

    final result = await _repository.uploadAvatar(selectedAvatar!);

    bool success = false;
    result.fold(
      (failure) => error = failure.message,
      (userProfile) {
        profile = userProfile;
        selectedAvatar = null;
        success = true;
      },
    );

    isUploadingAvatar = false;
    return success;
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
      selectedAvatar = null;
    }
  }
}
