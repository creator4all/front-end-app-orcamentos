import 'package:multimidiaapp/services/api_service.dart';

import '../../domain/models/budget_create.dart';
import '../../domain/models/budget_summary.dart';

class BudgetService {
  final ApiService _api;
  BudgetService(this._api);

  Future<List<BudgetSummaryDto>> listar({String? status}) async {
    final url = '/api/orcamentos${status != null ? '?orc_status=$status' : ''}';
    print('🌐 Chamando API: $url');

    final res = await _api.get(url);
    print('📡 Resposta da API: $res');

    final data = res is Map<String, dynamic>
        ? (res['dados'] ?? res['data'] ?? res)
        : res;
    final List list;
    if (data is Map && data['dados'] is List) {
      list = data['dados'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }

    print('📋 Lista processada: ${list.length} itens');
    return list
        .map((e) =>
            BudgetSummaryDto.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> criar(BudgetCreateDto dto, {String? status}) async {
    final dados = dto.toMap();
    
    // Adicionar status se fornecido
    if (status != null) {
      dados['orc_status'] = status;
    }
    
    final res = await _api.post('/api/orcamentos/', dados);
    
    print('🔍 Resposta bruta da API: $res');
    
    // Extrair dados corretamente - estrutura: {success, data: {dados: {...}}}
    Map<String, dynamic> data;
    if (res is Map<String, dynamic>) {
      // Primeiro nível: data
      final dataLevel1 = res['data'] as Map<String, dynamic>?;
      if (dataLevel1 != null) {
        // Segundo nível: dados
        data = dataLevel1['dados'] as Map<String, dynamic>? ?? dataLevel1;
      } else {
        // Fallback: tentar 'dados' direto
        data = res['dados'] as Map<String, dynamic>? ?? res;
      }
    } else {
      data = res as Map<String, dynamic>;
    }
    
    print('🔍 Dados extraídos finais: $data');
    print('🔍 ID encontrado: ${data['id']}');
    return data;
  }

  Future<Map<String, dynamic>> atualizar(int budgetId, Map<String, dynamic> updateData) async {
    print('🔄 Atualizando orçamento ID: $budgetId');
    print('📋 Dados de atualização: $updateData');
    
    final res = await _api.put('/api/orcamentos/$budgetId', updateData);
    final data = res is Map<String, dynamic>
        ? (res['dados'] ?? res['data'] ?? res)
        : res;
    
    print('✅ Orçamento atualizado com sucesso');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> buscarPorId(int budgetId) async {
    print('🔍 Buscando orçamento ID: $budgetId');
    
    final res = await _api.get('/api/orcamentos/$budgetId');
    final data = res is Map<String, dynamic>
        ? (res['dados'] ?? res['data'] ?? res)
        : res;
    
    print('✅ Orçamento carregado com sucesso');
    print('📋 Dados do orçamento: $data');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> renomear(int budgetId, String novoNome) async {
    print('✏️ Renomeando orçamento ID: $budgetId para: $novoNome');
    
    final updateData = {
      'nome': novoNome,
    };
    
    final res = await _api.put('/api/orcamentos/$budgetId', updateData);
    final data = res is Map<String, dynamic>
        ? (res['dados'] ?? res['data'] ?? res)
        : res;
    
    print('✅ Orçamento renomeado com sucesso');
    return Map<String, dynamic>.from(data as Map);
  }

  /// Salva indicadores de um produto em um orçamento
  Future<void> salvarIndicadoresProduto(
    int orcamentoId,
    int produtoId,
    List<Map<String, dynamic>> indicadores,
  ) async {
    print('💾 Salvando indicadores do produto $produtoId no orçamento $orcamentoId');
    print('📋 Indicadores: $indicadores');
    
    await _api.post(
      '/api/orcamentos/$orcamentoId/produtos/$produtoId/indicadores',
      {'indicadores': indicadores},
    );
    
    print('✅ Indicadores salvos com sucesso');
  }

  /// Excluir orçamento
  Future<void> excluir(int budgetId) async {
    print('🗑️ Excluindo orçamento ID: $budgetId');
    await _api.delete('/api/orcamentos/$budgetId');
    print('✅ Orçamento excluído com sucesso');
  }
}
