import 'package:mobx/mobx.dart';

import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/partner_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../../domain/usecases/create_draft_budget_usecase.dart';
import '../../domain/usecases/get_standard_partners_usecase.dart';
import '../../domain/usecases/validate_budget_data_usecase.dart';

part 'budget_create_store.g.dart';

class BudgetCreateStore = _BudgetCreateStoreBase with _$BudgetCreateStore;

abstract class _BudgetCreateStoreBase with Store {
  final GetStandardPartnersUseCase getStandardPartnersUseCase;
  final CreateDraftBudgetUseCase createDraftBudgetUseCase;
  final ValidateBudgetDataUseCase validateBudgetDataUseCase;

  _BudgetCreateStoreBase({
    required this.getStandardPartnersUseCase,
    required this.createDraftBudgetUseCase,
    required this.validateBudgetDataUseCase,
  });

  // ========== LOADING STATES ==========

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingPartners = false;

  @observable
  bool isCreatingDraft = false;

  /// Flag para controlar se já tentou carregar parceiros
  /// Evita loop infinito quando a API retorna lista vazia
  @observable
  bool hasAttemptedLoadPartners = false;

  // ========== ERROR HANDLING ==========

  @observable
  String? error;

  @observable
  String? partnerError;

  @observable
  String? validationError;

  // ========== PARTNERS ==========

  @observable
  ObservableList<PartnerEntity> partners = ObservableList<PartnerEntity>();

  @observable
  PartnerEntity? selectedPartner;

  // ========== LOCATION ==========

  @observable
  String? selectedStateCode;

  @observable
  String? selectedStateName;

  @observable
  String? selectedCityCode;

  @observable
  String? selectedCityName;

  @observable
  int? selectedCityId; // ID numérico da cidade (OBRIGATÓRIO para novo payload)

  // ========== FORM FIELDS ==========

  @observable
  String? responsibleName;

  @observable
  String? responsibleEmail;

  @observable
  String? responsiblePhone;

  @observable
  DateTime? validityDate;

  // ========== RESULT ==========

  @observable
  BudgetDraftEntity? createdDraft;

  // ========== COMPUTED PROPERTIES ==========

  /// Verifica se todos os campos obrigatórios estão preenchidos
  @computed
  bool get isFormValid {
    // Parceiro é obrigatório apenas para admins (verificado externamente)
    // Estado e cidade sempre obrigatórios
    return selectedStateCode != null &&
        selectedStateCode!.isNotEmpty &&
        selectedCityCode != null &&
        selectedCityCode!.isNotEmpty;
  }

  /// Verifica se o email está em formato válido
  @computed
  bool get isEmailValid {
    if (responsibleEmail == null || responsibleEmail!.isEmpty) return true;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(responsibleEmail!);
  }

  /// Retorna a localização completa formatada
  @computed
  String? get locationDisplay {
    if (selectedCityName != null && selectedStateCode != null) {
      return '$selectedCityName - $selectedStateCode';
    }
    return null;
  }

  /// Verifica se tem parceiros carregados
  @computed
  bool get hasPartners => partners.isNotEmpty;

  /// Verifica se a localização está completa
  @computed
  bool get isLocationComplete {
    return selectedStateCode != null &&
        selectedCityCode != null &&
        selectedStateName != null &&
        selectedCityName != null;
  }

  // ========== ACTIONS ==========

  /// Carrega a lista de parceiros padrão
  /// Só executa uma vez para evitar loop infinito
  /// [excludePartnerId] - ID do parceiro a ser excluído da lista (parceiro do usuário logado)
  @action
  Future<void> loadPartners({int? excludePartnerId}) async {
    // ✅ Evita múltiplas tentativas
    if (hasAttemptedLoadPartners) {
      print(
          '⚠️ [BudgetCreateStore] Já tentou carregar parceiros anteriormente');
      return;
    }

    hasAttemptedLoadPartners = true;
    isLoadingPartners = true;
    partnerError = null;

    try {
      print('🔄 [BudgetCreateStore] Carregando parceiros...');

      final result =
          await getStandardPartnersUseCase(excludePartnerId: excludePartnerId);

      result.fold(
        (failure) {
          print(
              '❌ [BudgetCreateStore] Erro ao carregar parceiros: ${failure.message}');
          partnerError = failure.message;
          partners.clear();
        },
        (partnerList) {
          print(
              '✅ [BudgetCreateStore] Parceiros carregados: ${partnerList.length}');

          // Debug detalhado
          for (var partner in partnerList) {
            print('   📌 Parceiro ID ${partner.id}: ${partner.displayName}');
          }

          partners.clear();
          partners.addAll(partnerList);

          print('   📊 hasPartners após adicionar: $hasPartners');
          print('   📊 partners.length: ${partners.length}');
        },
      );
    } catch (e) {
      print('❌ [BudgetCreateStore] Erro inesperado: $e');
      partnerError = 'Erro ao carregar parceiros: $e';
    } finally {
      isLoadingPartners = false;
    }
  }

  /// Seleciona um parceiro
  @action
  void selectPartner(PartnerEntity partner) {
    selectedPartner = partner;
    print('✅ [BudgetCreateStore] Parceiro selecionado: ${partner.name}');
  }

  /// Remove seleção de parceiro
  @action
  void clearPartner() {
    selectedPartner = null;
    print('🔄 [BudgetCreateStore] Seleção de parceiro removida');
  }

  /// Define o estado selecionado
  @action
  void setSelectedState(String code, String name) {
    selectedStateCode = code;
    selectedStateName = name;
    // Limpa cidade ao trocar estado
    selectedCityCode = null;
    selectedCityName = null;
    print('✅ [BudgetCreateStore] Estado selecionado: $name ($code)');
  }

  /// Define a cidade selecionada
  @action
  void setSelectedCity(String code, String name, {int? cityId}) {
    selectedCityCode = code;
    selectedCityName = name;
    selectedCityId =
        cityId ?? int.tryParse(code); // Usa cityId ou tenta parsear code
    print(
        '✅ [BudgetCreateStore] Cidade selecionada: $name ($code) - ID: $selectedCityId');
  }

  /// Limpa seleção de localização
  @action
  void clearLocation() {
    selectedStateCode = null;
    selectedStateName = null;
    selectedCityCode = null;
    selectedCityName = null;
    print('🔄 [BudgetCreateStore] Localização limpa');
  }

  /// Define o nome do responsável
  @action
  void setResponsibleName(String? name) {
    responsibleName = name;
  }

  /// Define o email do responsável
  @action
  void setResponsibleEmail(String? email) {
    responsibleEmail = email;
  }

  /// Define o telefone do responsável
  @action
  void setResponsiblePhone(String? phone) {
    responsiblePhone = phone;
  }

  /// Define a data de validade
  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
    print('✅ [BudgetCreateStore] Data de validade: ${date?.toString()}');
  }

  /// Valida os dados antes de criar
  ///
  /// Requer partnerId e userId para validação completa
  @action
  Future<bool> validateForm(int partnerId, int userId) async {
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

    try {
      print('🔍 [BudgetCreateStore] Validando dados...');

      final params = CreateBudgetDraftParams(
        partnerId: partnerId,
        userId: userId, // ✅ Adiciona userId
        stateCode: selectedStateCode!,
        cityCode: selectedCityCode!,
        cityId: selectedCityId ?? int.parse(selectedCityCode!),
        cityName: selectedCityName!,
        responsibleName: responsibleName,
        responsibleEmail: responsibleEmail,
        validityDate: validityDate,
        total: 0.0,
      );

      final result = await validateBudgetDataUseCase(params);

      return result.fold(
        (failure) {
          print('❌ [BudgetCreateStore] Validação falhou: ${failure.message}');
          validationError = failure.message;
          return false;
        },
        (isValid) {
          print('✅ [BudgetCreateStore] Validação passou');
          return isValid;
        },
      );
    } catch (e) {
      print('❌ [BudgetCreateStore] Erro na validação: $e');
      validationError = 'Erro ao validar dados';
      return false;
    }
  }

  /// Cria um novo orçamento em rascunho
  ///
  /// Requer partnerId do parceiro selecionado e userId do usuário autenticado
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
      print('🔄 [BudgetCreateStore] Criando orçamento em rascunho...');

      final params = CreateBudgetDraftParams(
        partnerId: partnerId,
        userId: userId, // ✅ Adiciona ID do usuário
        stateCode: selectedStateCode!,
        cityCode: selectedCityCode!,
        cityId: selectedCityId ?? int.parse(selectedCityCode!),
        cityName: selectedCityName!,
        responsibleName: responsibleName,
        responsibleEmail: responsibleEmail,
        validityDate: validityDate,
        total: 0.0, // Rascunho começa com total 0
      );

      final result = await createDraftBudgetUseCase(params);

      return result.fold(
        (failure) {
          print(
              '❌ [BudgetCreateStore] Erro ao criar orçamento: ${failure.message}');
          error = failure.message;
          return false;
        },
        (draft) {
          print('✅ [BudgetCreateStore] Orçamento criado: ID ${draft.id}');
          createdDraft = draft;
          return true;
        },
      );
    } catch (e) {
      print('❌ [BudgetCreateStore] Erro inesperado: $e');
      error = 'Erro ao criar orçamento: $e';
      return false;
    } finally {
      isCreatingDraft = false;
    }
  }

  /// Limpa todos os dados do formulário
  @action
  void clearForm() {
    selectedPartner = null;
    selectedStateCode = null;
    selectedStateName = null;
    selectedCityCode = null;
    selectedCityName = null;
    selectedCityId = null;
    responsibleName = null;
    responsibleEmail = null;
    validityDate = null;
    createdDraft = null;
    error = null;
    validationError = null;
    // Não resetar hasAttemptedLoadPartners - mantém cache da tentativa
    print('🔄 [BudgetCreateStore] Formulário limpo');
  }

  /// Limpa apenas os erros
  @action
  void clearErrors() {
    error = null;
    partnerError = null;
    validationError = null;
  }

  /// Reseta completamente a store (incluindo flag de tentativa de parceiros)
  @action
  void reset() {
    clearForm();
    clearErrors();
    partners.clear();
    hasAttemptedLoadPartners = false;
    isLoadingPartners = false;
    print('🔄 [BudgetCreateStore] Store resetada completamente');
  }
}
