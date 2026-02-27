import 'package:mobx/mobx.dart';

import '../../domain/entities/company.dart';
import '../../domain/entities/partner_request.dart';
import '../../domain/entities/user_registration.dart';
import '../../domain/repositories/registration_repository.dart';
import '../../domain/usecases/verify_document_usecase.dart';

part 'registration_store.g.dart';

/// Store MobX para gerenciar o fluxo de cadastro
class RegistrationStore = _RegistrationStoreBase with _$RegistrationStore;

abstract class _RegistrationStoreBase with Store {
  final VerifyDocumentUseCase verifyDocumentUseCase;
  final RegistrationRepository registrationRepository;

  _RegistrationStoreBase({
    required this.verifyDocumentUseCase,
    required this.registrationRepository,
  });


  @observable
  bool isVerifyingDocument = false;

  @observable
  Company? foundCompany;

  @observable
  String? verifyError;


  @observable
  bool isRegisteringUser = false;

  @observable
  String? registerUserError;

  @observable
  bool registerUserSuccess = false;


  @observable
  bool isRequestingPartner = false;

  @observable
  String? requestPartnerError;

  @observable
  bool requestPartnerSuccess = false;


  @computed
  bool get hasFoundCompany => foundCompany != null;

  @computed
  bool get canProceedToRegistration =>
      hasFoundCompany && foundCompany!.status == true;


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

  @action
  Future<void> registerUser(UserRegistration registration) async {
    isRegisteringUser = true;
    registerUserError = null;
    registerUserSuccess = false;

    final result = await registrationRepository.registerUser(registration);

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

  @action
  Future<void> requestPartner(PartnerRequest request) async {
    isRequestingPartner = true;
    requestPartnerError = null;
    requestPartnerSuccess = false;

    final result = await registrationRepository.requestPartner(request);

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

  @action
  void clearVerifyState() {
    isVerifyingDocument = false;
    foundCompany = null;
    verifyError = null;
  }

  @action
  void clearRegisterUserState() {
    isRegisteringUser = false;
    registerUserError = null;
    registerUserSuccess = false;
  }

  @action
  void clearRequestPartnerState() {
    isRequestingPartner = false;
    requestPartnerError = null;
    requestPartnerSuccess = false;
  }

  @action
  void resetAllState() {
    clearVerifyState();
    clearRegisterUserState();
    clearRequestPartnerState();
  }
}
