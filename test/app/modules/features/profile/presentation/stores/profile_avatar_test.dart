import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/profile/domain/entities/user_profile.dart';
import 'package:multimidiaapp/app/modules/features/profile/domain/repositories/avatar_image_validator.dart';
import 'package:multimidiaapp/app/modules/features/profile/domain/repositories/profile_repository.dart';
import 'package:multimidiaapp/app/modules/features/profile/external/avatar_image_validator_impl.dart';
import 'package:multimidiaapp/app/modules/features/profile/presentation/stores/profile_store.dart';
import 'package:multimidiaapp/app/shared/core/errors/failures.dart';

const fixtures = 'test/app/modules/features/profile/external/fixtures';
const oldProfile = UserProfile(
  id: 1,
  name: 'Pessoa',
  email: 'pessoa@example.com',
  avatar: 'old.jpg',
  status: true,
);
const newProfile = UserProfile(
  id: 1,
  name: 'Pessoa',
  email: 'pessoa@example.com',
  avatar: 'new.jpg',
  status: true,
);

class _Repository implements ProfileRepository {
  final List<String> events;
  final List<String> uploads = [];
  final uploadStarted = Completer<void>();
  bool rejectUpload = false;
  Completer<Either<Failure, UserProfile>>? pendingUpload;
  _Repository(this.events);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async =>
      const Right(oldProfile);

  @override
  Future<Either<Failure, UserProfile>> uploadAvatar(File file) async {
    events.add('upload');
    uploads.add(file.path);
    if (!uploadStarted.isCompleted) uploadStarted.complete();
    if (pendingUpload != null) return pendingUpload!.future;
    return rejectUpload
        ? const Left(ServerFailure('Falha no envio'))
        : const Right(newProfile);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Validator implements AvatarImageValidator {
  final List<String> events;
  final delegate = AvatarImageValidatorImpl();
  _Validator(this.events);

  @override
  Future<AvatarImageValidation> validate(String path,
      {bool jpegOnly = false}) async {
    events.add(jpegOnly ? 'validar final' : 'validar original');
    final result = await delegate.validate(path, jpegOnly: jpegOnly);
    events.add(result.name);
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<String> events;
  late _Repository repository;
  late ProfileStore store;
  late Directory temp;

  setUp(() async {
    events = [];
    repository = _Repository(events);
    store = ProfileStore(repository, _Validator(events));
    await store.fetch();
    temp = await Directory.systemTemp.createTemp('avatar_flow_');
  });
  tearDown(() async => temp.delete(recursive: true));

  Future<bool> select({
    String? original = '$fixtures/valid.png',
    String? cropped = '$fixtures/valid.jpg',
    bool Function()? isActive,
  }) =>
      store.uploadAvatar(
        selectOriginal: () async {
          events.add('selecionar original');
          return original;
        },
        cropImage: (path) async {
          expect(path, original);
          expect(store.isUploadingAvatar, isTrue);
          events.add('recortar');
          return cropped;
        },
        isActive: isActive ?? () => true,
      );

  test('ordem real: original, tamanho/conteúdo, recorte, JPEG final e upload',
      () async {
    expect(await select(), isTrue);
    expect(events, [
      'selecionar original',
      'validar original',
      'valid',
      'recortar',
      'validar final',
      'valid',
      'upload',
    ]);
    expect(store.profile, newProfile);
    expect(store.isUploadingAvatar, isFalse);
    expect(store.error, isNull);
  });

  for (final bytes in [5242880, 5242881]) {
    test('original $bytes bytes decide recorte mesmo com JPEG final pequeno',
        () async {
      final png = await File('$fixtures/valid.png').readAsBytes();
      final file = await File('${temp.path}/original.png')
          .writeAsBytes(Uint8List(bytes)..setRange(0, png.length, png));
      expect(await select(original: file.path), bytes == 5242880);
      expect(events.contains('recortar'), bytes == 5242880);
      expect(repository.uploads.length, bytes == 5242880 ? 1 : 0);
      if (bytes > 5242880) {
        expect(store.error, 'A imagem excede o tamanho máximo de 5 MB.');
        expect(store.profile, oldProfile);
      }
    });
  }

  test('PNG truncado não abre recorte nem inicia upload', () async {
    expect(await select(original: '$fixtures/corrupted.png'), isFalse);
    expect(events, ['selecionar original', 'validar original', 'invalid']);
    expect(repository.uploads, isEmpty);
    expect(store.error, contains('não é uma imagem válida'));
    expect(store.profile, oldProfile);
    expect(store.isUploadingAvatar, isFalse);
  });

  test('cancelar seleção ou recorte mantém perfil e não envia', () async {
    expect(await select(original: null), isFalse);
    expect(events, ['selecionar original']);
    expect(store.error, isNull);
    events.clear();
    expect(await select(cropped: null), isFalse);
    expect(events.last, 'recortar');
    expect(repository.uploads, isEmpty);
    expect(store.profile, oldProfile);
    expect(store.isUploadingAvatar, isFalse);
  });

  test('rejeita saída do cropper inválida ou grande antes do upload', () async {
    final large =
        await File('${temp.path}/large.jpg').writeAsBytes(Uint8List(5242881));
    for (final cropped in ['$fixtures/valid.png', large.path]) {
      expect(await select(cropped: cropped), isFalse);
      expect(repository.uploads, isEmpty);
      expect(store.profile, oldProfile);
      expect(store.isUploadingAvatar, isFalse);
    }
  });

  test('leitura e plugins falham com mensagem controlada e liberam ocupado',
      () async {
    expect(await select(original: '${temp.path}/missing.png'), isFalse);
    expect(store.error, isNot(contains('FileSystemException')));
    for (final failSelection in [true, false]) {
      expect(
          await store.uploadAvatar(
            selectOriginal: () async {
              if (failSelection) {
                throw PlatformException(code: 'permission_denied');
              }
              return '$fixtures/valid.png';
            },
            cropImage: (_) async =>
                throw PlatformException(code: 'crop_failed'),
            isActive: () => true,
          ),
          isFalse);
      expect(store.error,
          'Não foi possível abrir ou atualizar a imagem. Tente novamente.');
      expect(store.isUploadingAvatar, isFalse);
      expect(store.profile, oldProfile);
    }
    expect(repository.uploads, isEmpty);
  });

  test('upload falho não altera avatar nem reutiliza imagem após cancelamento',
      () async {
    repository.rejectUpload = true;
    expect(await select(), isFalse);
    expect(store.profile, oldProfile);
    expect(store.error, 'Falha no envio');
    expect(store.isUploadingAvatar, isFalse);
    expect(await select(original: null), isFalse);
    expect(repository.uploads, hasLength(1));
    expect(store.error, isNull);
    repository.rejectUpload = false;
    expect(await select(), isTrue);
    expect(repository.uploads, hasLength(2));
  });

  test('bloqueia seleção duplicada enquanto o seletor está aberto', () async {
    final selection = Completer<String?>();
    final first = store.uploadAvatar(
      selectOriginal: () => selection.future,
      cropImage: (_) async => '$fixtures/valid.jpg',
      isActive: () => true,
    );
    expect(store.isUploadingAvatar, isTrue);
    expect(await select(), isFalse);
    expect(events, isEmpty);
    selection.complete(null);
    expect(await first, isFalse);
    expect(store.isUploadingAvatar, isFalse);
  });

  for (final stopAfter in ['selection', 'crop', 'upload']) {
    test('saída da tela durante $stopAfter ignora retorno tardio', () async {
      var active = true;
      if (stopAfter == 'upload') repository.pendingUpload = Completer();
      final operation = store.uploadAvatar(
        selectOriginal: () async {
          if (stopAfter == 'selection') active = false;
          return '$fixtures/valid.png';
        },
        cropImage: (_) async {
          if (stopAfter == 'crop') active = false;
          return '$fixtures/valid.jpg';
        },
        isActive: () => active,
      );
      if (stopAfter == 'upload') {
        // Aguarda o ponto de upload antes de simular o dispose.
        await repository.uploadStarted.future;
        active = false;
        repository.pendingUpload!.complete(const Right(newProfile));
      }
      expect(await operation, isFalse);
      expect(store.profile, oldProfile);
      expect(store.error, isNull);
      expect(store.isUploadingAvatar, isFalse);
      expect(repository.uploads.length, stopAfter == 'upload' ? 1 : 0);
    });
  }
}
