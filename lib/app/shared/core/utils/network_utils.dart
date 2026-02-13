import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/app_error.dart';

class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<ConnectivityResult> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  static Future<bool> isWifi() async {
    try {
      final result = await checkConnectivity();
      return result == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isMobileData() async {
    try {
      final result = await checkConnectivity();
      return result == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }

  static Future<void> validateInternet() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw const AppInternetError(
        'Sem conexão com a internet. Conecte-se a uma rede WiFi ou ative os dados móveis.',
      );
    }
  }

  static StreamSubscription<bool> listenOnNetworkChanged(
    Function(bool hasInternet) onNetworkStatusChanged,
  ) {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result != ConnectivityResult.none) {
        return await hasInternetConnection();
      }
      return false;
    }).listen(onNetworkStatusChanged);
  }
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