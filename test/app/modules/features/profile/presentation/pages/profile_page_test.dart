import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/profile/data/datasources/profile_api_datasource.dart';
import 'package:multimidiaapp/app/modules/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:multimidiaapp/app/modules/features/profile/domain/repositories/avatar_image_validator.dart';
import 'package:multimidiaapp/app/modules/features/profile/presentation/pages/profile_page.dart';
import 'package:multimidiaapp/app/modules/features/profile/presentation/stores/profile_store.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

class _ProfileClient implements AppHttpClient {
  final int? partnerId;
  final bool rejectUpdate;
  final List<Map<String, dynamic>> updates = [];
  final String? avatar;
  final bool rejectAvatar;
  final List<String> uploads = [];

  _ProfileClient(
      {this.partnerId = 27,
      this.rejectUpdate = false,
      this.avatar,
      this.rejectAvatar = false});

  Map<String, dynamic> get profile => {
        'usr_userId': 1,
        'usr_name': 'Pessoa de Teste',
        'usr_email': 'pessoa@example.com',
        'usr_cargo': 'Administradora',
        'usr_phone': '11987654321',
        'usr_status': true,
        'usr_avatar': avatar,
        'partners_par_partnerId': partnerId,
        'role': {'rol_name': 'Administrador'},
      };

  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) async {
    expect(url, '/api/perfil/me');
    return HttpResponse(body: {'dados': profile}, headers: {}, statusCode: 200);
  }

  @override
  Future<HttpResponse> put(String url,
      {dynamic data, HttpRequestConfig? config}) async {
    expect(url, '/api/perfil/me');
    updates.add(Map<String, dynamic>.from(data as Map));
    if (rejectUpdate) {
      throw const UnprocessableEntityException(message: 'E-mail já cadastrado');
    }
    return HttpResponse(body: {
      'dados': {...profile, ...updates.last}
    }, headers: {}, statusCode: 200);
  }

  @override
  Future<HttpResponse> uploadFile(
    String url, {
    required String filePath,
    required String fileField,
    HttpRequestConfig? config,
  }) async {
    expect(url, '/api/perfil/me/avatar');
    expect(fileField, 'avatar');
    uploads.add(filePath);
    if (rejectAvatar) throw StateError('plugin-internal-details');
    return HttpResponse(body: {
      'dados': {...profile, 'usr_avatar': 'new.jpg'}
    }, headers: {}, statusCode: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AvatarValidator implements AvatarImageValidator {
  final AvatarImageValidation result;
  final List<String> paths = [];
  _AvatarValidator([this.result = AvatarImageValidation.valid]);

  @override
  Future<AvatarImageValidation> validate(String path,
      {bool jpegOnly = false}) async {
    paths.add(path);
    return result;
  }
}

class _Picker extends ImagePicker {
  String? path = '/original.png';
  Completer<XFile?>? pending;
  int calls = 0;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    expect(source, ImageSource.gallery);
    // A cópia reduzida não pode ser a entrada da validação.
    expect(maxWidth, isNull);
    expect(maxHeight, isNull);
    expect(imageQuality, isNull);
    if (pending != null) return pending!.future;
    return path == null ? null : XFile(path!);
  }
}

class _Cropper extends ImageCropper {
  String? path = '/cropped.jpg';
  Completer<CroppedFile?>? pending;
  int calls = 0;

  @override
  Future<CroppedFile?> cropImage({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    List<PlatformUiSettings>? uiSettings,
  }) async {
    calls++;
    expect(sourcePath, '/original.png');
    expect(maxWidth, 1024);
    expect(maxHeight, 1024);
    expect(aspectRatio!.ratioX, 1);
    expect(aspectRatio.ratioY, 1);
    expect(compressFormat, ImageCompressFormat.jpg);
    expect(compressQuality, 85);
    if (pending != null) return pending!.future;
    return path == null ? null : CroppedFile(path!);
  }
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileAuthStore extends AuthStore {
  int refreshes = 0;

  _ProfileAuthStore()
      : super(
          loginUsecase: LoginUsecase(_UnusedAuthRepository()),
          authRepository: _UnusedAuthRepository(),
          secureStorage: const FlutterSecureStorage(),
        );

  @override
  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    expect(forceRefresh, isTrue);
    refreshes++;
  }
}

class _ProfileTestModule extends Module {
  final ProfileStore profile;
  final AuthStore auth;
  _ProfileTestModule(this.profile, this.auth);

  @override
  List<Bind> get binds => [
        Bind.instance<ProfileStore>(profile),
        Bind.instance<AuthStore>(auth),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProfileStore store;
  late _ProfileAuthStore auth;
  final screenshotKey = GlobalKey();

  setUpAll(() async {
    const fontPath = String.fromEnvironment('PROFILE_AVATAR_FONT');
    const iconsPath = String.fromEnvironment('PROFILE_AVATAR_ICONS');
    for (final entry
        in {'Roboto': fontPath, 'MaterialIcons': iconsPath}.entries) {
      if (entry.value.isNotEmpty) {
        final loader = FontLoader(entry.key)
          ..addFont(File(entry.value).readAsBytes().then(ByteData.sublistView));
        await loader.load();
      }
    }
  });

  Future<void> openProfile(
    WidgetTester tester,
    _ProfileClient client, {
    _Picker? picker,
    _Cropper? cropper,
    AvatarImageValidator? validator,
  }) async {
    FlutterSecureStorage.setMockInitialValues({});
    store = ProfileStore(ProfileRepositoryImpl(ProfileApiDatasource(client)),
        validator ?? _AvatarValidator());
    auth = _ProfileAuthStore();
    Modular.init(_ProfileTestModule(store, auth));
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => RepaintBoundary(
        key: screenshotKey,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ProfilePage(imagePicker: picker, imageCropper: cropper)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.text('Salvar Alterações');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  tearDown(() => Modular.destroy());

  Future<void> changeAvatar(WidgetTester tester) async {
    await tester.tap(find.text('Trocar Foto'));
    await tester.pumpAndSettle();
  }

  for (final validation in [
    AvatarImageValidation.tooLarge,
    AvatarImageValidation.invalid
  ]) {
    testWidgets('avatar $validation mostra motivo e preserva foto e formulário',
        (tester) async {
      const screenshotPath =
          String.fromEnvironment('PROFILE_AVATAR_SCREENSHOT');
      if (screenshotPath.isNotEmpty) {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }
      final client = _ProfileClient(avatar: 'old.jpg');
      final cropper = _Cropper();
      await openProfile(tester, client,
          picker: _Picker(),
          cropper: cropper,
          validator: _AvatarValidator(validation));
      await tester.enterText(find.byType(TextField).at(0), 'Nome em edição');
      await changeAvatar(tester);
      expect(
          find.text(validation == AvatarImageValidation.tooLarge
              ? 'A imagem excede o tamanho máximo de 5 MB.'
              : 'O arquivo não é uma imagem válida ou não pode ser aberto.'),
          findsOneWidget);
      expect(cropper.calls, 0);
      expect(client.uploads, isEmpty);
      expect(store.profile!.avatar, 'old.jpg');
      expect(find.text('Nome em edição'), findsOneWidget);
      expect(store.isUploadingAvatar, isFalse);
      expect(auth.refreshes, 0);

      if (screenshotPath.isNotEmpty &&
          validation == AvatarImageValidation.tooLarge) {
        await tester.runAsync(() async {
          final boundary = screenshotKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await File(screenshotPath)
                .writeAsBytes(bytes!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }
    });
  }

  testWidgets(
      'avatar válido recorta quadrado, envia multipart e recarrega usuário sem apagar campos',
      (tester) async {
    final client = _ProfileClient(avatar: 'old.jpg');
    final validator = _AvatarValidator();
    final cropper = _Cropper();
    await openProfile(tester, client,
        picker: _Picker(), cropper: cropper, validator: validator);
    await tester.enterText(find.byType(TextField).at(0), 'Nome em edição');
    await tester.enterText(find.byType(TextField).at(2), 'Cargo em edição');
    await changeAvatar(tester);
    expect(validator.paths, ['/original.png', '/cropped.jpg']);
    expect(cropper.calls, 1);
    expect(client.uploads, ['/cropped.jpg']);
    expect(store.profile!.avatar, 'new.jpg');
    expect(find.text('Nome em edição'), findsOneWidget);
    expect(find.text('Cargo em edição'), findsOneWidget);
    expect(find.text('Avatar atualizado com sucesso!'), findsOneWidget);
    expect(auth.refreshes, 1);
    expect(store.isUploadingAvatar, isFalse);
  });

  for (final cancelPicker in [true, false]) {
    testWidgets(
        'cancelar ${cancelPicker ? 'seletor' : 'recorte'} não mostra erro nem altera avatar',
        (tester) async {
      final client = _ProfileClient(avatar: 'old.jpg');
      final picker = _Picker()..path = cancelPicker ? null : '/original.png';
      final cropper = _Cropper()..path = null;
      await openProfile(tester, client, picker: picker, cropper: cropper);
      await changeAvatar(tester);
      expect(client.uploads, isEmpty);
      expect(store.profile!.avatar, 'old.jpg');
      expect(store.error, isNull);
      expect(store.isUploadingAvatar, isFalse);
      expect(auth.refreshes, 0);
      expect(cropper.calls, cancelPicker ? 0 : 1);
    });
  }

  testWidgets('falha de upload mostra erro controlado sem foto nova ou sucesso',
      (tester) async {
    final client = _ProfileClient(avatar: 'old.jpg', rejectAvatar: true);
    await openProfile(tester, client, picker: _Picker(), cropper: _Cropper());
    await changeAvatar(tester);
    expect(find.text('Não foi possível atualizar o avatar. Tente novamente.'),
        findsOneWidget);
    expect(find.textContaining('plugin-internal-details'), findsNothing);
    expect(find.text('Avatar atualizado com sucesso!'), findsNothing);
    expect(store.profile!.avatar, 'old.jpg');
    expect(auth.refreshes, 0);
    expect(store.isUploadingAvatar, isFalse);
  });

  for (final waitPicker in [true, false]) {
    testWidgets(
        'sair durante ${waitPicker ? 'seleção' : 'recorte'} não usa contexto descartado',
        (tester) async {
      final client = _ProfileClient(avatar: 'old.jpg');
      final picker = _Picker();
      final cropper = _Cropper();
      if (waitPicker) {
        picker.pending = Completer<XFile?>();
      } else {
        cropper.pending = Completer<CroppedFile?>();
      }
      await openProfile(tester, client, picker: picker, cropper: cropper);
      await tester.tap(find.text('Trocar Foto'));
      await tester.pump();
      expect(store.isUploadingAvatar, isTrue);
      final button = tester.widget<ElevatedButton>(find.ancestor(
        of: find.text('Trocar Foto'),
        matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
      ));
      expect(button.onPressed, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      if (waitPicker) {
        picker.pending!.complete(XFile('/original.png'));
      } else {
        cropper.pending!.complete(CroppedFile('/cropped.jpg'));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(client.uploads, isEmpty);
      expect(auth.refreshes, 0);
      expect(store.profile!.avatar, 'old.jpg');
      expect(store.isUploadingAvatar, isFalse);
    });
  }

  for (final entry
      in {2: 'Cargo é obrigatório', 3: 'Telefone é obrigatório'}.entries) {
    testWidgets('${entry.value}: bloqueia PUT', (tester) async {
      final client = _ProfileClient();
      await openProfile(tester, client);
      await tester.enterText(find.byType(TextField).at(entry.key), '');
      await save(tester);
      expect(find.text(entry.value), findsOneWidget);
      expect(client.updates, isEmpty);
      expect(auth.refreshes, 0);
    });
  }

  testWidgets('telefone incompleto não chama a API', (tester) async {
    final client = _ProfileClient();
    await openProfile(tester, client);
    await tester.enterText(find.byType(TextField).at(3), '11987');
    await save(tester);
    expect(find.text('Telefone inválido'), findsOneWidget);
    expect(client.updates, isEmpty);
  });

  for (final partnerId in <int?>[27, null]) {
    testWidgets('perfil válido preserva vínculo $partnerId no PUT',
        (tester) async {
      final client = _ProfileClient(partnerId: partnerId);
      await openProfile(tester, client);
      await tester.enterText(find.byType(TextField).at(0), 'Nome atualizado');
      await save(tester);
      expect(client.updates, hasLength(1));
      expect(client.updates.single, {
        'usr_name': 'Nome atualizado',
        'usr_email': 'pessoa@example.com',
        'usr_cargo': 'Administradora',
        'usr_phone': '11987654321',
        'partners_par_partnerId': partnerId,
      });
      expect(store.profile!.partnerId, partnerId);
      expect(store.isSaving, isFalse);
      expect(auth.refreshes, 1);
      expect(find.text('Perfil atualizado com sucesso!'), findsOneWidget);
    });
  }

  testWidgets('422 aparece como erro sem confirmar salvamento', (tester) async {
    final client = _ProfileClient(rejectUpdate: true);
    await openProfile(tester, client);
    await save(tester);
    expect(client.updates, hasLength(1));
    expect(find.text('E-mail já cadastrado'), findsOneWidget);
    expect(find.text('Perfil atualizado com sucesso!'), findsNothing);
    expect(store.isSaving, isFalse);
    expect(store.profile!.partnerId, 27);
    expect(auth.refreshes, 0);
  });
}
