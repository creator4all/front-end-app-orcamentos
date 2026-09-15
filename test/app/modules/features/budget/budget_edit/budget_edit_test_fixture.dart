import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/censo_escolar_mapper.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_calculation_service.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_census_data_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/entities/budget_edit_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/repositories/budget_edit_repository.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/update_budget_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/presentation/stores/budget_edit_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_update_dto.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

class FakeAuthStore implements AuthStore {
  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedCensusUseCase implements GetCensusDataUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class BudgetEditTestRepository implements BudgetEditRepository {
  BudgetEditEntity budget;
  int reads = 0;
  int writes = 0;
  int censusWrites = 0;
  BudgetFailure? saveFailure;
  Completer<void>? saveGate;
  BudgetEditEntity Function()? savedState;

  BudgetEditTestRepository(this.budget);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(
      int id) async {
    reads++;
    return Right(budget);
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    writes++;
    await saveGate?.future;
    if (saveFailure != null) return Left(saveFailure!);
    budget = savedState?.call() ?? budget;
    return Right(budget);
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) =>
      updateBudgetWithDto(budgetId: budgetId, updateData: updateData);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>>
      versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) =>
          updateBudgetWithDto(budgetId: budgetId, updateData: updateData);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class BudgetEditTestStore extends BudgetEditStore {
  int resets = 0;

  BudgetEditTestStore(BudgetEditTestRepository repository)
      : super(
          getBudgetForEditUseCase: GetBudgetForEditUseCase(repository),
          updateBudgetUseCase: UpdateBudgetUseCase(repository),
          getCensusDataUseCase: _UnusedCensusUseCase(),
          authStore: FakeAuthStore(),
          calculationService: const ProductCalculationService(),
          censoEscolarMapper: const CensoEscolarMapper(),
        );

  @override
  void reset() {
    resets++;
    super.reset();
  }

  ProductEntity product(int id) => categories
      .expand((c) => c.subcategorias)
      .expand((s) => s.produtos)
      .firstWhere((p) => p.id == id);
}

CensoEscolarEntity changedCensus() => const CensoEscolarEntity(
      cidadeId: 10,
      cidadeNome: 'Cidade teste',
      grupos: [
        CensoGroupEntity(
          id: 1,
          nome: 'Etapas',
          titulos: [
            CensoTitleEntity(
              id: 1,
              nomeEtapa: 'ef1ano',
              tituloExibicao: 'ef1ano',
              valor: 20,
              isProfessores: false,
              grupoId: 1,
            ),
          ],
        ),
      ],
      valoresPorEtapa: {'ef1ano': 20},
    );

BudgetEditEntity editableBudget({
  String status = 'pendente',
  bool archived = false,
  bool multiCity = false,
}) {
  ProductEntity product(int id, {required bool manual}) => ProductEntity(
        id: id,
        codigo: 'P$id',
        solucao: 'Produto $id',
        tipo: 'tecnologia',
        ativo: true,
        valor: 10,
        indicacao: '',
        tipoProduto: 'tecnologia',
        ordem: FractionalOrder.zero,
        subcategoriaId: 1,
        selecionado: true,
        quantidade: 10,
        quantidadeManual: manual,
        temOverride: false,
        valorOriginal: 10,
        ativoOriginal: true,
        indicadoresEtapa: const [
          IndicadorEtapaEntity(
            produtoIndicadorId: 1,
            indicadorId: 1,
            indicadorNome: 'ef1ano',
            nomeEtapa: 'ef1ano',
            grupoId: 1,
            grupoNome: 'Etapas',
            selecionado: true,
          ),
        ],
      );

  return BudgetEditEntity(
    id: 1,
    name: 'Orçamento teste',
    validityDays: 30,
    validityDate: DateTime.now().add(const Duration(days: 30)),
    status: status,
    isArchived: archived,
    total: 200,
    userId: 1,
    cityIds: const [10],
    multiCity: multiCity,
    products: const [],
    censoAgregado: const {'ef1ano': 10},
    citiesDataRaw: const [
      {
        'id': 10,
        'nome': 'Cidade teste',
        'indices': [
          {
            'id': 1,
            'nome_etapa': 'ef1ano',
            'titulo': 'ef1ano',
            'valor': 10,
            'grupo': {'id': 1, 'nome': 'Etapas'},
          },
        ],
      },
    ],
    categoriesData: [
      CategoryEntity(
        id: 1,
        nome: 'Tecnologias',
        ordem: FractionalOrder.zero,
        expandido: false,
        subcategorias: [
          SubcategoryEntity(
            id: 1,
            nome: 'Subcategoria',
            ordem: FractionalOrder.zero,
            produtos: [product(1, manual: true), product(2, manual: false)],
          ),
        ],
      ),
    ],
  );
}
