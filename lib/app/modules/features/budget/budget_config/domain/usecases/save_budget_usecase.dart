import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_detail_entity.dart';
import '../repositories/budget_detail_repository.dart';

/// Caso de uso para salvar orçamento configurado como "pendente"
///
/// Usado no fluxo de budget_config quando o usuário:
/// 1. Cria um orçamento (rascunho)
/// 2. Configura produtos e quantidades
/// 3. Clica em "Salvar Orçamento"
///
/// Este UseCase atualiza o status de "rascunho" → "pendente"
class SaveBudgetUseCase {
  final BudgetDetailRepository repository;

  SaveBudgetUseCase(this.repository);

  /// Executa o salvamento do orçamento
  ///
  /// [budgetId] ID do orçamento a salvar
  /// [updateData] DTO com dados de atualização (produtos, total, validade, etc)
  ///
  /// Retorna o orçamento atualizado ou falha
  Future<Either<BudgetFailure, BudgetDetailEntity>> call({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Validação: Status deve ser "pendente" no budget_config
      if (updateData.status != null && updateData.status != 'pendente') {
        return const Left(
          ValidationFailure(
            'Status deve ser "pendente" ao salvar da configuração',
          ),
        );
      }

      // Validação: Total deve ser maior que zero
      if (updateData.total != null && updateData.total! <= 0) {
        return const Left(
          ValidationFailure('O valor total deve ser maior que zero'),
        );
      }

      // Validação: Dias de validade obrigatório
      if (updateData.diasValidade == null || updateData.diasValidade! <= 0) {
        return const Left(
          ValidationFailure('Defina a data de validade do orçamento'),
        );
      }

      // Validação: Deve ter ao menos 1 produto no array
      if (updateData.produtos == null || updateData.produtos!.isEmpty) {
        return const Left(
          ValidationFailure('Nenhum produto encontrado para salvar'),
        );
      }

      // Validação: Deve ter ao menos 1 produto SELECIONADO
      final produtosSelecionados =
          updateData.produtos!.where((p) => p.selecionado).toList();

      if (produtosSelecionados.isEmpty) {
        return const Left(
          ValidationFailure('Selecione pelo menos um produto para o orçamento'),
        );
      }

      print(
          '💾 [SaveBudgetUseCase] Salvando orçamento $budgetId como PENDENTE');
      print('   📦 ${updateData.produtos!.length} produtos no total');
      print('   ✅ ${produtosSelecionados.length} produtos selecionados');
      print('   💰 Total: R\$ ${updateData.total}');
      print('   📅 Validade: ${updateData.diasValidade} dias');

      return await repository.updateBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );
    } catch (e) {
      print('❌ [SaveBudgetUseCase] Erro: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
