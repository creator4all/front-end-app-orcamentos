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

  Future<Map<String, dynamic>> criar(BudgetCreateDto dto) async {
    final res = await _api.post('/api/orcamentos/', dto.toMap());
    final data = res is Map<String, dynamic>
        ? (res['dados'] ?? res['data'] ?? res)
        : res;
    return Map<String, dynamic>.from(data as Map);
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
}
