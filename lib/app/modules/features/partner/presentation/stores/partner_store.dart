import 'dart:io';

import 'package:mobx/mobx.dart';

import '../../../../../shared/core/errors/api_error_message.dart';
import '../../../../../shared/utils/brazilian_phone_input_formatter.dart';
import '../../../../../shared/utils/document_validators.dart';
import '../../../../../shared/utils/email_validator.dart';
import '../../../../../shared/utils/website_url_validator.dart';
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
    url = WebsiteUrlValidator.normalize(value) ?? '';
  }

  String? validate() {
    if (tradeName.trim().isEmpty) {
      return 'Informe o nome fantasia da empresa.';
    }

    if (legalName.trim().isEmpty) {
      return 'Informe a razão social da empresa.';
    }

    final documentError = DocumentValidators.getDocumentError(cnpj);
    if (documentError != null) {
      return documentError;
    }

    if (!BrazilianPhoneInputFormatter.isValid(phone)) {
      return 'Informe um telefone completo, com DDD.';
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty && !EmailValidator.isValid(trimmedEmail)) {
      return 'Informe um e-mail válido.';
    }

    return WebsiteUrlValidator.getError(url);
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
      error = ApiErrorMessage.from(
        e,
        fallback: 'Não foi possível salvar os dados. Tente novamente.',
      );
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
      error = ApiErrorMessage.from(
        e,
        fallback: 'Não foi possível enviar o logo. Tente novamente.',
      );
      selectedLogo = null;
      return false;
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<void> viewContract() async {
    final currentPartner = partner;
    if (currentPartner == null) {
      return;
    }

    isViewingContract = true;
    error = null;
    try {
      final bytes = await _viewContractUseCase(currentPartner.id);
      if (!_hasPdfSignature(bytes)) {
        error = 'O contrato recebido não é um arquivo PDF válido.';
        return;
      }

      final fileName = currentPartner.contractFileName ?? 'contrato.pdf';
      final filePath = await _tempFileStore.getTempFilePath(fileName);

      await _tempFileStore.writeBytes(filePath, bytes);

      final result = await _fileOpener.open(
        filePath,
        mimeType: 'application/pdf',
        uti: 'com.adobe.pdf',
      );

      if (result.type != FileOpenResultType.done) {
        error =
            'Não foi possível abrir o contrato. Verifique se há um aplicativo de PDF instalado.';
      }
    } catch (_) {
      error = 'Não foi possível abrir o contrato. Tente novamente.';
    } finally {
      isViewingContract = false;
    }
  }

  bool _hasPdfSignature(List<int> bytes) {
    const signature = [0x25, 0x50, 0x44, 0x46, 0x2D];
    if (bytes.length < signature.length) return false;

    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
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
