import 'dart:io';
import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/modules/features/partner/data/services/partner_service.dart';
import '../../domain/models/partner_profile.dart';

part 'partner_store.g.dart';

class PartnerStore = _PartnerStoreBase with _$PartnerStore;

abstract class _PartnerStoreBase with Store {
  final PartnerService _service;

  _PartnerStoreBase(this._service);

  @observable
  PartnerProfile? partner;

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  @observable
  String tradeName = '';

  @observable
  String email = '';

  @observable
  String phone = '';

  @observable
  File? selectedLogo;

  @action
  Future<void> fetch() async {
    isLoading = true;
    error = null;
    try {
      print('🔄 Carregando informações da empresa...');
      partner = await _service.obterParceiro();
      
      print('✅ Empresa carregada com sucesso!');
      print('   Razão Social: ${partner!.legalName}');
      print('   Nome Fantasia: ${partner!.tradeName}');
      print('   Email: ${partner!.email}');
      print('   CNPJ: ${partner!.cnpj}');
      print('   Telefone: ${partner!.phone}');
      
      // Atualizar campos editáveis
      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      
      print('🔄 Controllers atualizados via reaction');
    } catch (e) {
      print('❌ Erro ao carregar empresa: $e');
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setTradeName(String value) {
    tradeName = value;
  }

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setPhone(String value) {
    phone = value;
  }

  @action
  void setSelectedLogo(File? file) {
    selectedLogo = file;
  }

  @action
  Future<bool> save() async {
    isSaving = true;
    error = null;
    try {
      print('💾 Salvando informações da empresa...');
      
      final dados = {
        'par_trade_name': tradeName,
        'par_email': email.isEmpty ? null : email,
        'par_phone': phone,
      };

      partner = await _service.atualizarParceiro(dados);
      
      // Atualizar campos com dados salvos
      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      
      print('✅ Empresa atualizada com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao salvar empresa: $e');
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<bool> uploadLogo() async {
    if (selectedLogo == null) {
      error = 'Nenhum logo selecionado';
      return false;
    }

    isSaving = true;
    error = null;
    try {
      print('📤 Fazendo upload do logo...');
      
      partner = await _service.uploadLogo(selectedLogo!);
      selectedLogo = null;
      
      print('✅ Logo atualizado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao fazer upload do logo: $e');
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  void reset() {
    if (partner != null) {
      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      selectedLogo = null;
    }
  }
}
