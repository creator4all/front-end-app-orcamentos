import 'package:dio/dio.dart';

import '../http_response.dart';
import 'dio_request_options_extension.dart';

extension DioResponseExtension on Response {
  HttpResponse toHttpResponse() {
    Map<String, dynamic> bodyData;

    if (data == null) {
      bodyData = {};
    } else if (data is Map<String, dynamic>) {
      bodyData = data;
    } else if (data is String) {
      bodyData = {'data': data};
    } else if (data is List) {
      bodyData = {'data': data};
    } else {
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