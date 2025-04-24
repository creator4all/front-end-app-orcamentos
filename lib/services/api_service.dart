import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;
          
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(ApiConfig.requestTimeout);
      
      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
  
  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;
          
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.requestTimeout);
      
      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;
          
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.requestTimeout);
      
      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final headers = token != null 
          ? ApiConfig.headersWithToken(token)
          : ApiConfig.headers;
          
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(ApiConfig.requestTimeout);
      
      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
  
  // Process HTTP response
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Erro na requisição',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar resposta: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }
}
