import 'package:dio/dio.dart';

import '../http_response.dart';
import 'dio_request_options_extension.dart';

/// Extension para converter Response do Dio em nossos modelos de resposta
extension DioResponseExtension on Response {
  /// Converte Response do Dio em HttpResponse
  HttpResponse toHttpResponse() {
    // Garante que o body seja um Map
    Map<String, dynamic> bodyData;

    if (data == null) {
      bodyData = {};
    } else if (data is Map<String, dynamic>) {
      bodyData = data;
    } else if (data is String) {
      // Se for String, encapsula
      bodyData = {'data': data};
    } else if (data is List) {
      // Se for List, encapsula
      bodyData = {'data': data};
    } else {
      // Outros tipos, tenta converter
      bodyData = {'data': data};
    }

    return HttpResponse(
      body: bodyData,
      headers: headers.map,
      statusCode: statusCode,
      statusMessage: statusMessage,
      requestInfo: requestOptions.toHttpRequestInfo(statusCode),
    );
  }

  /// Converte Response do Dio em DownloadHttpResponse
  DownloadHttpResponse toDownloadHttpResponse({String? filePath}) {
    List<int> bytes;

    if (data is List<int>) {
      bytes = data;
    } else if (data is String) {
      bytes = (data as String).codeUnits;
    } else {
      bytes = [];
    }

    return DownloadHttpResponse(
      bytes: bytes,
      filePath: filePath,
      headers: headers.map,
      statusCode: statusCode,
      statusMessage: statusMessage,
      requestInfo: requestOptions.toHttpRequestInfo(statusCode),
    );
  }
}
