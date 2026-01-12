import 'dart:io';

import 'package:mobx/mobx.dart';

import '../../domain/models/user_profile.dart';
import '../../external/services/profile_service.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final ProfileService _service;
  _ProfileStore(this._service);

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
    try {
      print('🔄 Carregando perfil...');
      profile = await _service.obterPerfil();

      // Preencher campos editáveis
      name = profile!.name;
      email = profile!.email;
      cargo = profile!.cargo ?? '';
      phone = profile!.phone ?? '';

      print('✅ Perfil carregado com sucesso!');
      print('   ID: ${profile!.id}');
      print('   Nome: ${profile!.name}');
      print('   Email: ${profile!.email}');
      print('   Cargo: ${profile!.cargo}');
      print('   Phone: ${profile!.phone}');
      print('   Role: ${profile!.roleName}');
      print('   Partner: ${profile!.partnerName}');
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
      error = e.toString();
    } finally {
      isLoading = false;
    }
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
    try {
      print('💾 Salvando perfil...');

      final dados = {
        'usr_name': name,
        'usr_email': email,
        'usr_cargo': cargo.isEmpty ? null : cargo,
        'usr_phone': phone.isEmpty ? null : phone,
      };

      profile = await _service.atualizarPerfil(dados);

      // Atualizar campos com dados salvos
      name = profile!.name;
      email = profile!.email;
      cargo = profile!.cargo ?? '';
      phone = profile!.phone ?? '';

      print('✅ Perfil atualizado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao salvar perfil: $e');
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<bool> uploadAvatar() async {
    if (selectedAvatar == null) {
      error = 'Nenhuma imagem selecionada';
      return false;
    }

    isUploadingAvatar = true;
    error = null;
    try {
      print('📤 Fazendo upload do avatar...');

      profile = await _service.uploadAvatar(selectedAvatar!);
      selectedAvatar = null;

      print('✅ Avatar atualizado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao fazer upload do avatar: $e');
      error = e.toString();
      return false;
    } finally {
      isUploadingAvatar = false;
    }
  }

  @action
  Future<bool> removeAvatar() async {
    isUploadingAvatar = true;
    error = null;
    try {
      print('🗑️ Removendo avatar...');

      profile = await _service.removerAvatar();

      print('✅ Avatar removido com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao remover avatar: $e');
      error = e.toString();
      return false;
    } finally {
      isUploadingAvatar = false;
    }
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
