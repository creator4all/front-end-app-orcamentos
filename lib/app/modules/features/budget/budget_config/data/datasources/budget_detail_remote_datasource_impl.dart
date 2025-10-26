import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';
import 'budget_detail_remote_datasource.dart';

/// Implementação concreta do BudgetDetailRemoteDataSource usando Dio/ApiService
class BudgetDetailRemoteDataSourceImpl implements BudgetDetailRemoteDataSource {
  final ApiService apiService;

  BudgetDetailRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetDetailDto> getBudgetById(int id) async {
    try {
      print('🌐 [BudgetDetailDataSource] GET /api/orcamentos/$id');

      final response = await apiService.get('/api/orcamentos/$id');

      // Log do tamanho para verificar se não está truncado
      final responseStr = response.toString();
      print(
          '📡 [BudgetDetailDataSource] Response size: ${responseStr.length} chars');
      print(
          '📡 [BudgetDetailDataSource] Response tem categorias? ${response.toString().contains("categorias")}');

      // Extrair dados da resposta
      // response pode ser: {dados: {...}} ou {data: {...}} ou direto o objeto
      Map<String, dynamic> data;

      if (response.containsKey('dados')) {
        // Caso: {dados: {...}}
        data = response['dados'] as Map<String, dynamic>;
      } else if (response.containsKey('data')) {
        // Caso: {data: {...}}
        final dataField = response['data'];
        if (dataField is Map && dataField.containsKey('dados')) {
          // Caso: {data: {dados: {...}}}
          data = dataField['dados'] as Map<String, dynamic>;
        } else {
          // Caso: {data: {...}} direto
          data = dataField as Map<String, dynamic>;
        }
      } else {
        // Caso: já é o objeto direto
        data = response;
      }

      print(
          '📦 [BudgetDetailDataSource] Data extraído tem categorias? ${data.containsKey("categorias")}');
      if (data.containsKey('categorias') && data['categorias'] is List) {
        print(
            '✅ [BudgetDetailDataSource] Campo categorias encontrado: ${(data['categorias'] as List).length} itens');
      } else {
        print('⚠️ [BudgetDetailDataSource] Campo categorias NÃO encontrado!');
        print(
            '🔍 [BudgetDetailDataSource] Keys disponíveis: ${data.keys.toList()}');
      }

      print('✅ [BudgetDetailDataSource] Orçamento carregado ID: $id');

      return BudgetDetailDto.fromJson(data);
    } on DioException catch (e) {
      print('❌ [BudgetDetailDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDetailDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getAllProducts({
    required int budgetId,
  }) async {
    try {
      print(
          '🌐 [BudgetDetailDataSource] GET /api/orcamentos/$budgetId/produtos-completos (EAGER LOAD)');

      final response = await apiService.get(
        '/api/orcamentos/$budgetId/produtos-completos',
      );

      print(
          '📡 [BudgetDetailDataSource] Response size: ${response.toString().length} chars');

      // ApiService envolve a resposta em {success: true, data: {...}}
      // Verificar se API retornou erro
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg =
            response['error'] ?? response['message'] ?? 'Erro desconhecido';
        print('❌ [BudgetDetailDataSource] API retornou erro: $errorMsg');
        print('🔍 Response completo: $response');
        throw Exception('Erro ao buscar produtos: $errorMsg');
      }

      // Extrair 'data' do wrapper do ApiService: {success: true, data: {dados: {...}}}
      if (!response.containsKey('data')) {
        print('❌ [BudgetDetailDataSource] Response não contém chave "data"');
        print('🔍 Response keys: ${response.keys}');
        throw Exception('Resposta do ApiService em formato inválido');
      }

      final data = response['data'] as Map<String, dynamic>;

      // Agora extrair 'dados' da resposta da API: {dados: {produtos: [...], censo_cidades: {...}}}
      if (!data.containsKey('dados')) {
        print('❌ [BudgetDetailDataSource] data não contém chave "dados"');
        print('🔍 data keys: ${data.keys}');
        throw Exception('Resposta da API em formato inválido');
      }

      final dados = data['dados'] as Map<String, dynamic>;

      // Validar estrutura dos dados
      if (!dados.containsKey('produtos')) {
        print('❌ [BudgetDetailDataSource] "dados" não contém chave "produtos"');
        print('🔍 Dados keys: ${dados.keys}');
        throw Exception('Dados sem array de produtos');
      }

      // Extrair array de produtos com null-safety
      final produtosJson = dados['produtos'] as List<dynamic>?;

      if (produtosJson == null || produtosJson.isEmpty) {
        print('⚠️ [BudgetDetailDataSource] Array de produtos vazio ou null');
        return []; // Retornar lista vazia em vez de crashar
      }

      print(
          '✅ [BudgetDetailDataSource] ${produtosJson.length} produtos carregados (TODOS)');

      // Parsear cada produto
      final produtos = produtosJson
          .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      return produtos;
    } on DioException catch (e) {
      print('❌ [BudgetDetailDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDetailDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  }) async {
    try {
      print(
          '🌐 [BudgetDetailDataSource] GET /api/orcamentos/$budgetId/categorias/$categoryId/produtos');

      final response = await apiService.get(
        '/api/orcamentos/$budgetId/categorias/$categoryId/produtos',
      );

      print(
          '📡 [BudgetDetailDataSource] Response size: ${response.toString().length} chars');

      // Extrair dados da resposta
      Map<String, dynamic> data;

      if (response.containsKey('dados')) {
        data = response['dados'] as Map<String, dynamic>;
      } else if (response.containsKey('data')) {
        final dataField = response['data'];
        if (dataField is Map && dataField.containsKey('dados')) {
          data = dataField['dados'] as Map<String, dynamic>;
        } else {
          data = dataField as Map<String, dynamic>;
        }
      } else {
        data = response;
      }

      // Extrair array de produtos
      final produtosJson = data['produtos'] as List<dynamic>;
      print(
          '✅ [BudgetDetailDataSource] ${produtosJson.length} produtos carregados da categoria $categoryId');

      // Parsear cada produto
      final produtos = produtosJson
          .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      return produtos;
    } on DioException catch (e) {
      print('❌ [BudgetDetailDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDetailDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<BudgetDetailDto> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  }) async {
    try {
      print('🌐 [BudgetDetailDataSource] PUT /api/orcamentos/$id');

      // Montar body da requisição
      final Map<String, dynamic> body = {};

      if (name != null && name.isNotEmpty) {
        body['nome'] = name;
      }

      if (status != null && status.isNotEmpty) {
        body['orc_status'] = status;
      }

      if (validityDate != null) {
        body['orc_data_validade'] = validityDate.toIso8601String();
      }

      if (categoryStates != null) {
        // Enviar apenas categorias ativas
        body['categorias_ativas'] = categoryStates.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
      }

      if (selectedProductIds != null) {
        body['produtos_selecionados'] = selectedProductIds;
      }

      print('📋 [BudgetDetailDataSource] Body: $body');

      final response = await apiService.put('/api/orcamentos/$id', body);
      print('📡 [BudgetDetailDataSource] Response: $response');

      // Extrair dados da resposta - response já é Map<String, dynamic>
      final data = response['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetDetailDataSource] Orçamento atualizado ID: $id');

      return BudgetDetailDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [BudgetDetailDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDetailDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  /// Trata erros do Dio e lança exceções apropriadas
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout na conexão com o servidor');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Orçamento não encontrado');
        } else if (statusCode == 401 || statusCode == 403) {
          return Exception('Não autorizado');
        }
        return Exception('Erro no servidor: ${error.response?.data}');
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Sem conexão com a internet');
      default:
        return Exception('Erro desconhecido: ${error.message}');
    }
  }
}
