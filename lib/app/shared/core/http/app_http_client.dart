import 'http_request_config.dart';
import 'http_response.dart';

abstract class AppHttpClient {
  Future<HttpResponse> get(
    String url, {
    HttpRequestConfig? config,
  });

  Future<HttpResponse> post(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  Future<HttpResponse> put(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  Future<HttpResponse> patch(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  Future<HttpResponse> delete(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  Future<HttpResponse> head(
    String url, {
    HttpRequestConfig? config,
  });

  Future<HttpResponse> options(
    String url, {
    HttpRequestConfig? config,
  });

  Future<DownloadHttpResponse> download(
    String url,
    String savePath, {
    CancelDownload? cancelToken,
    HttpRequestConfig? config,
  });

  Future<List<int>> getBytes(
    String url, {
    HttpRequestConfig? config,
  });

  Future<HttpResponse> uploadFile(
    String url, {
    required String filePath,
    required String fileField,
    HttpRequestConfig? config,
  });
}
