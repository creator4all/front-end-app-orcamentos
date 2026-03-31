import 'package:mobx/mobx.dart';

import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/partner_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../../domain/usecases/create_draft_budget_usecase.dart';
import '../../domain/usecases/get_standard_partners_usecase.dart';

part 'budget_create_store.g.dart';

class BudgetCreateStore = _BudgetCreateStoreBase with _$BudgetCreateStore;

abstract class _BudgetCreateStoreBase with Store {
  final GetStandardPartnersUseCase getStandardPartnersUseCase;
  final CreateDraftBudgetUseCase createDraftBudgetUseCase;

  _BudgetCreateStoreBase({
    required this.getStandardPartnersUseCase,
    required this.createDraftBudgetUseCase,
  });

  String? _normalizeInput(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingPartners = false;

  @observable
  bool isCreatingDraft = false;

  @observable
  bool hasAttemptedLoadPartners = false;

  @observable
  String? error;

  @observable
  String? partnerError;

  @observable
  String? validationError;

  @observable
  ObservableList<PartnerEntity> partners = ObservableList<PartnerEntity>();

  @observable
  PartnerEntity? selectedPartner;

  @observable
  String? selectedStateCode;

  @observable
  String? selectedStateName;

  @observable
  String? selectedStateUf;

  @observable
  String? selectedCityCode;

  @observable
  String? selectedCityName;

  @observable
  int? selectedCityId;

  @observable
  String? responsibleName;

  @observable
  String? responsibleEmail;

  @observable
  String? responsiblePhone;

  @observable
  DateTime? validityDate;

  @observable
  BudgetDraftEntity? createdDraft;

  @computed
  bool get isFormValid {
    return selectedStateCode != null &&
        selectedStateCode!.isNotEmpty &&
        selectedCityCode != null &&
        selectedCityCode!.isNotEmpty;
  }

  @computed
  bool get isEmailValid {
    if (responsibleEmail == null || responsibleEmail!.isEmpty) return true;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(responsibleEmail!);
  }

  @computed
  String? get locationDisplay {
    if (selectedCityName != null && selectedStateCode != null) {
      return '$selectedCityName - $selectedStateCode';
    }
    return null;
  }

  @computed
  bool get hasPartners => partners.isNotEmpty;

  @computed
  bool get isLocationComplete {
    return selectedStateCode != null &&
        selectedCityCode != null &&
        selectedStateName != null &&
        selectedCityName != null;
  }

  @action
  Future<void> loadPartners({int? excludePartnerId}) async {
    if (hasAttemptedLoadPartners) {
      return;
    }

    hasAttemptedLoadPartners = true;
    isLoadingPartners = true;
    partnerError = null;

    try {
      final result =
          await getStandardPartnersUseCase(excludePartnerId: excludePartnerId);

      result.fold(
        (failure) {
          partnerError = failure.message;
          partners.clear();
        },
        (partnerList) {
          partners.clear();
          partners.addAll(partnerList);
        },
      );
    } catch (e) {
      partnerError = 'Erro ao carregar parceiros: $e';
    } finally {
      isLoadingPartners = false;
    }
  }

  @action
  void selectPartner(PartnerEntity partner) {
    selectedPartner = partner;
  }

  @action
  void clearPartner() {
    selectedPartner = null;
  }

  @action
  void setSelectedState(String code, String name, String uf) {
    selectedStateCode = code;
    selectedStateName = name;
    selectedStateUf = uf;
    selectedCityCode = null;
    selectedCityName = null;
  }

  @action
  void setSelectedCity(String code, String name, {int? cityId}) {
    selectedCityCode = code;
    selectedCityName = name;
    selectedCityId = cityId ?? int.tryParse(code);
  }

  @action
  void clearLocation() {
    selectedStateCode = null;
    selectedStateName = null;
    selectedStateUf = null;
    selectedCityCode = null;
    selectedCityName = null;
  }

  @action
  void setResponsibleName(String? name) {
    responsibleName = _normalizeInput(name);
  }

  @action
  void setResponsibleEmail(String? email) {
    responsibleEmail = _normalizeInput(email);
  }

  @action
  void setResponsiblePhone(String? phone) {
    responsiblePhone = _normalizeInput(phone);
  }

  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
  }

  @action
  bool validateForm(int partnerId, int userId) {
    validationError = null;

    if (!isFormValid) {
      validationError = 'Preencha todos os campos obrigatórios';
      return false;
    }

    if (!isEmailValid) {
      validationError = 'Email inválido';
      return false;
    }

    if (userId <= 0) {
      validationError = 'Usuário não autenticado';
      return false;
    }

    if (validityDate != null && validityDate!.isBefore(DateTime.now())) {
      validationError = 'Data de validade deve ser futura';
      return false;
    }

    return true;
  }

  @action
  Future<bool> createDraft(int partnerId, int userId) async {
    if (!isFormValid) {
      error = 'Preencha todos os campos obrigatórios';
      return false;
    }

    if (userId <= 0) {
      error = 'Usuário não autenticado';
      return false;
    }

    isCreatingDraft = true;
    error = null;

    try {
      final params = CreateBudgetDraftParams(
        partnerId: partnerId,
        userId: userId,
        stateCode: selectedStateCode!,
        cityCode: selectedCityCode!,
        cityId: selectedCityId ?? int.parse(selectedCityCode!),
        cityName: selectedCityName!,
        stateUf: selectedStateUf ?? '',
        responsibleName: responsibleName,
        responsibleEmail: responsibleEmail,
        validityDate: validityDate,
        total: 0.0,
      );

      final result = await createDraftBudgetUseCase(params);

      return result.fold(
        (failure) {
          error = failure.message;
          return false;
        },
        (draft) {
          createdDraft = draft;
          return true;
        },
      );
    } catch (e) {
      error = 'Erro ao criar orçamento: $e';
      return false;
    } finally {
      isCreatingDraft = false;
    }
  }

  @action
  void clearForm() {
    selectedPartner = null;
    selectedStateCode = null;
    selectedStateName = null;
    selectedStateUf = null;
    selectedCityCode = null;
    selectedCityName = null;
    selectedCityId = null;
    responsibleName = null;
    responsibleEmail = null;
    validityDate = null;
    createdDraft = null;
    error = null;
    validationError = null;
  }

  @action
  void clearErrors() {
    error = null;
    partnerError = null;
    validationError = null;
  }

  @action
  void reset() {
    clearForm();
    clearErrors();
    partners.clear();
    hasAttemptedLoadPartners = false;
    isLoadingPartners = false;
  }
}
