import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_controller.g.dart';

class AuthController = _AuthControllerBase with _$AuthController;

abstract class _AuthControllerBase with Store {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;

  _AuthControllerBase({
    required this.loginUsecase,
    required this.logoutUsecase,
  });

  @observable
  bool isLoading = false;

  @observable
  UserEntity? currentUser;

  @observable
  String? errorMessage;

  @observable
  bool isLoggedIn = false;

  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;

    final result = await loginUsecase(email: email, password: password);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoggedIn = false;
      },
      (user) {
        currentUser = user;
        isLoggedIn = true;
        // Navigate to home
        Modular.to.pushReplacementNamed('/budget/');
      },
    );

    isLoading = false;
  }

  @action
  Future<void> logout() async {
    isLoading = true;

    final result = await logoutUsecase();

    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (_) {
        currentUser = null;
        isLoggedIn = false;
        // Navigate to login
        Modular.to.pushReplacementNamed('/auth/login');
      },
    );

    isLoading = false;
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
