import 'package:mobx/mobx.dart';

import '../../domain/entities/company.dart';
import '../../domain/entities/partner_request.dart';
import '../../domain/entities/user_registration.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/request_partner_usecase.dart';
import '../../domain/usecases/verify_document_usecase.dart';

part 'registration_store.g.dart';

/// Store MobX para gerenciar o fluxo de cadastro
class RegistrationStore = _RegistrationStoreBase with _$RegistrationStore;

abstract class _RegistrationStoreBase with Store {
  final VerifyDocumentUseCase verifyDocumentUseCase;
  final RegisterUserUseCase registerUserUseCase;
  final RequestPartnerUseCase requestPartnerUseCase;

  _RegistrationStoreBase({
    required this.verifyDocumentUseCase,
    required this.registerUserUseCase,
    required this.requestPartnerUseCase,
  });

  // ============================================
  // OBSERVABLES - Estado de Verificação de Documento
  // ============================================

  @observable
  bool isVerifyingDocument = false;

  @observable
  Company? foundCompany;

  @observable
  String? verifyError;

  // ============================================
  // OBSERVABLES - Estado de Cadastro de Usuário
  // ============================================

  @observable
  bool isRegisteringUser = false;

  @observable
  String? registerUserError;

  @observable
  bool registerUserSuccess = false;

  // ============================================
  // OBSERVABLES - Estado de Solicitação de Parceria
  // ============================================

  @observable
  bool isRequestingPartner = false;

  @observable
  String? requestPartnerError;

  @observable
  bool requestPartnerSuccess = false;

  // ============================================
  // COMPUTED
  // ============================================

  @computed
  bool get hasFoundCompany => foundCompany != null;

  @computed
  bool get canProceedToRegistration =>
      hasFoundCompany && foundCompany!.status == true;

  // ============================================
  // ACTIONS
  // ============================================

  /// Verifica documento (CNPJ) e busca empresa
  @action
  Future<void> verifyDocument(String documento) async {
    isVerifyingDocument = true;
    verifyError = null;
    foundCompany = null;

    final result = await verifyDocumentUseCase(documento);

    result.fold(
      (failure) {
        verifyError = failure.message;
        foundCompany = null;
      },
      (company) {
        foundCompany = company;
        verifyError = null;
      },
    );

    isVerifyingDocument = false;
  }

  /// Cadastra novo usuário
  @action
  Future<void> registerUser(UserRegistration registration) async {
    isRegisteringUser = true;
    registerUserError = null;
    registerUserSuccess = false;

    final result = await registerUserUseCase(registration);

    result.fold(
      (failure) {
        registerUserError = failure.message;
        registerUserSuccess = false;
      },
      (_) {
        registerUserSuccess = true;
        registerUserError = null;
      },
    );

    isRegisteringUser = false;
  }

  /// Envia solicitação de parceria
  @action
  Future<void> requestPartner(PartnerRequest request) async {
    isRequestingPartner = true;
    requestPartnerError = null;
    requestPartnerSuccess = false;

    final result = await requestPartnerUseCase(request);

    result.fold(
      (failure) {
        requestPartnerError = failure.message;
        requestPartnerSuccess = false;
      },
      (_) {
        requestPartnerSuccess = true;
        requestPartnerError = null;
      },
    );

    isRequestingPartner = false;
  }

  /// Limpa estado de verificação de documento
  @action
  void clearVerifyState() {
    isVerifyingDocument = false;
    foundCompany = null;
    verifyError = null;
  }

  /// Limpa estado de cadastro de usuário
  @action
  void clearRegisterUserState() {
    isRegisteringUser = false;
    registerUserError = null;
    registerUserSuccess = false;
  }

  /// Limpa estado de solicitação de parceria
  @action
  void clearRequestPartnerState() {
    isRequestingPartner = false;
    requestPartnerError = null;
    requestPartnerSuccess = false;
  }

  /// Reseta todo o estado
  @action
  void resetAllState() {
    clearVerifyState();
    clearRegisterUserState();
    clearRequestPartnerState();
  }
}
