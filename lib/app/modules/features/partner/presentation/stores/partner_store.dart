import 'dart:io';

import 'package:mobx/mobx.dart';

import '../../../../../shared/utils/document_validators.dart';
import '../../../new_drive/domain/repositories/file_opener.dart';
import '../../../new_drive/domain/repositories/temp_file_store.dart';
import '../../domain/models/partner_profile.dart';
import '../../domain/usecases/get_partner_usecase.dart';
import '../../domain/usecases/update_partner_usecase.dart';
import '../../domain/usecases/upload_logo_usecase.dart';
import '../../domain/usecases/view_contract_usecase.dart';

part 'partner_store.g.dart';

class PartnerStore = _PartnerStoreBase with _$PartnerStore;

abstract class _PartnerStoreBase with Store {
  final GetPartnerUseCase _getPartnerUseCase;
  final UpdatePartnerUseCase _updatePartnerUseCase;
  final UploadLogoUseCase _uploadLogoUseCase;
  final ViewContractUseCase _viewContractUseCase;
  final TempFileStore _tempFileStore;
  final FileOpener _fileOpener;

  _PartnerStoreBase(
    this._getPartnerUseCase,
    this._updatePartnerUseCase,
    this._uploadLogoUseCase,
    this._viewContractUseCase,
    this._tempFileStore,
    this._fileOpener,
  );

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
      partner = await _getPartnerUseCase();

      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      url = partner!.url ?? '';
      legalName = partner!.legalName;
      cnpj = partner!.cnpj;
    } catch (e) {
      error = 'Não foi possível carregar os dados do parceiro.';
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

      partner = await _updatePartnerUseCase(dados);

      tradeName = partner!.tradeName;
      email = partner!.email ?? '';
      phone = partner!.phone;
      url = partner!.url ?? '';
      legalName = partner!.legalName;
      cnpj = partner!.cnpj;

      return true;
    } catch (e) {
      error = 'Não foi possível salvar os dados. Tente novamente.';
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
      partner = await _uploadLogoUseCase(selectedLogo!.path);
      selectedLogo = null;

      return true;
    } catch (e) {
      error = 'Não foi possível enviar o logo. Tente novamente.';
      selectedLogo = null;
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<void> viewContract() async {
    if (partner == null) {
      return;
    }

    isViewingContract = true;
    error = null;
    try {
      final bytes = await _viewContractUseCase(partner!.id);

      final fileName = partner!.contractFileName ?? 'contrato.pdf';
      final filePath = await _tempFileStore.getTempFilePath(fileName);

      await _tempFileStore.writeBytes(filePath, bytes);

      final result = await _fileOpener.open(filePath);

      if (result.type != FileOpenResultType.done) {
        error =
            'Não foi possível abrir o contrato. Verifique se há um aplicativo de PDF instalado.';
      }
    } catch (e) {
      error = 'Não foi possível abrir o contrato. Tente novamente.';
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
