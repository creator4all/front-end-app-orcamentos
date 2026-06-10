import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/modules/features/partner/data/services/partner_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../shared/utils/document_validators.dart';
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
  String legalName = '';

  @observable
  String cnpj = '';

  @observable
  File? selectedLogo;

  @observable
  String url = '';

  @observable
  bool isViewingContract = false;

  @action
  Future<void> fetch() async {
    isLoading = true;
    error = null;
    try {
      partner = await _service.obterParceiro();

      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      url = partner!.url ?? '';
      legalName = partner!.legalName;
      cnpj = partner!.cnpj;
    } catch (e) {
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
  void setUrl(String value) {
    url = value;
  }

  @action
  void setLegalName(String value) {
    legalName = value;
  }

  @action
  void setCnpj(String value) {
    cnpj = value;
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
      final dados = {
        'par_trade_name': tradeName,
        'par_legal_name': legalName,
        'par_cnpj': DocumentValidators.normalizeDocument(cnpj),
        'par_email': email.isEmpty ? null : email,
        'par_phone': phone,
        'par_url': url.trim().isEmpty ? null : url.trim(),
      };

      partner = await _service.atualizarParceiro(dados);

      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      url = partner!.url ?? '';
      legalName = partner!.legalName;
      cnpj = partner!.cnpj;

      return true;
    } catch (e) {
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
      partner = await _service.uploadLogo(selectedLogo!);
      selectedLogo = null;

      return true;
    } catch (e) {
      error = e.toString();
      selectedLogo = null;
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<void> viewContract() async {
    if (partner == null) return;

    isViewingContract = true;
    error = null;
    try {
      final bytes = await _service.viewContract(partner!.id);

      final directory = await getTemporaryDirectory();
      final fileName = partner!.contractFileName ?? 'contrato.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        error =
            'Não foi possível abrir o contrato. Verifique se há um aplicativo de PDF instalado.';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isViewingContract = false;
    }
  }

  @action
  void reset() {
    if (partner != null) {
      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      selectedLogo = null;
      url = partner!.url ?? '';
      legalName = partner!.legalName;
      cnpj = partner!.cnpj;
    }
  }
}
