import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/profile/domain/repositories/avatar_image_validator.dart';
import 'package:multimidiaapp/app/modules/features/profile/external/avatar_image_validator_impl.dart';

const fixtures = 'test/app/modules/features/profile/external/fixtures';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final validator = AvatarImageValidatorImpl();
  late Directory temp;

  setUp(
      () async => temp = await Directory.systemTemp.createTemp('avatar_test_'));
  tearDown(() async => temp.delete(recursive: true));

  for (final extension in ['png', 'jpg', 'gif', 'webp']) {
    test('decodifica fixture $extension sem depender da extensão declarada',
        () async {
      final file = await File('$fixtures/valid.$extension')
          .copy('${temp.path}/renamed.bin');
      expect(await validator.validate(file.path), AvatarImageValidation.valid);
    });
  }

  for (final bytes in [5242879, 5242880, 5242881]) {
    test('avalia arquivo real com $bytes bytes antes do recorte', () async {
      final png = await File('$fixtures/valid.png').readAsBytes();
      final padded = Uint8List(bytes)..setRange(0, png.length, png);
      final file = await File('${temp.path}/boundary.png').writeAsBytes(padded);
      expect(await file.length(), bytes);
      expect(
        await validator.validate(file.path),
        bytes <= 5242880
            ? AvatarImageValidation.valid
            : AvatarImageValidation.tooLarge,
      );
    });
  }

  test('arquivo grande inválido é rejeitado pelo tamanho antes do codec',
      () async {
    final file =
        await File('${temp.path}/large.jpg').writeAsBytes(Uint8List(5242881));
    expect(await validator.validate(file.path), AvatarImageValidation.tooLarge);
  });

  test('rejeita texto renomeado para jpg e png, vazio e PNG truncado',
      () async {
    for (final extension in ['jpg', 'png']) {
      final file = await File('${temp.path}/text.$extension')
          .writeAsString('Este arquivo não contém uma imagem.');
      expect(
          await validator.validate(file.path), AvatarImageValidation.invalid);
    }
    final empty = await File('${temp.path}/empty.jpg').create();
    expect(await validator.validate(empty.path), AvatarImageValidation.invalid);
    expect(await validator.validate('$fixtures/corrupted.png'),
        AvatarImageValidation.invalid);
  });

  test('JPEG final exige conteúdo JPEG decodificável', () async {
    expect(await validator.validate('$fixtures/valid.jpg', jpegOnly: true),
        AvatarImageValidation.valid);
    expect(await validator.validate('$fixtures/valid.png', jpegOnly: true),
        AvatarImageValidation.invalid);
    final fakeJpeg = await File('${temp.path}/fake.jpg')
        .writeAsBytes([0xff, 0xd8, 0xff, 0x00]);
    expect(await validator.validate(fakeJpeg.path, jpegOnly: true),
        AvatarImageValidation.invalid);
  });

  test('falha de leitura é distinguível da decodificação', () async {
    await expectLater(validator.validate('${temp.path}/missing.png'),
        throwsA(isA<FileSystemException>()));
  });
}
