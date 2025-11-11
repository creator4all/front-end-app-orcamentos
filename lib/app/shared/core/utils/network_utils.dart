import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/app_error.dart';

/// Utilitário para verificação de conectividade e internet
class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Verifica se há conexão com a internet (ping real)
  ///
  /// Não basta verificar se está conectado ao WiFi/dados móveis,
  /// é necessário fazer um ping para garantir que há internet real.
  static Future<bool> hasInternetConnection() async {
    try {
      // Tenta fazer lookup DNS do Google
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica o tipo de conectividade (WiFi, Mobile, None)
  static Future<ConnectivityResult> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Verifica se está conectado via WiFi
  static Future<bool> isWifi() async {
    try {
      final result = await checkConnectivity();
      return result == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se está conectado via dados móveis
  static Future<bool> isMobileData() async {
    try {
      final result = await checkConnectivity();
      return result == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }

  /// Valida se há internet antes de fazer uma requisição
  ///
  /// Lança [AppInternetError] se não houver internet
  static Future<void> validateInternet() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw const AppInternetError(
        'Sem conexão com a internet. Conecte-se a uma rede WiFi ou ative os dados móveis.',
      );
    }
  }

  /// Escuta mudanças na conectividade
  ///
  /// Útil para mostrar banners ou atualizar UI quando internet cair/voltar
  ///
  /// Exemplo:
  /// ```dart
  /// StreamSubscription? subscription;
  ///
  /// subscription = NetworkUtils.listenOnNetworkChanged((hasInternet) {
  ///   if (hasInternet) {
  ///     print('Internet voltou!');
  ///   } else {
  ///     print('Sem internet!');
  ///   }
  /// });
  ///
  /// // Para cancelar:
  /// subscription?.cancel();
  /// ```
  static StreamSubscription<bool> listenOnNetworkChanged(
    Function(bool hasInternet) onNetworkStatusChanged,
  ) {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result != ConnectivityResult.none) {
        // Tem conectividade, mas vamos verificar se há internet real
        return await hasInternetConnection();
      }
      return false;
    }).listen(onNetworkStatusChanged);
  }

  /// Aguarda até que haja conexão com internet
  ///
  /// Útil para retry automático de operações que falharam por falta de internet
  ///
  /// [timeout] - Tempo máximo de espera (padrão: 30 segundos)
  /// [checkInterval] - Intervalo entre checagens (padrão: 2 segundos)
  static Future<bool> waitForInternet({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await hasInternetConnection()) {
        return true;
      }
      await Future.delayed(checkInterval);
    }

    return false;
  }
}
