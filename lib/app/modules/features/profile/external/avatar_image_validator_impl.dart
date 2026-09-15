import 'dart:io';
import 'dart:ui' as ui;

import '../domain/repositories/avatar_image_validator.dart';

class AvatarImageValidatorImpl implements AvatarImageValidator {
  @override
  Future<AvatarImageValidation> validate(String path,
      {bool jpegOnly = false}) async {
    final file = File(path);
    final sizeValidation =
        AvatarImageValidator.validateSize(await file.length());
    if (sizeValidation != AvatarImageValidation.valid) return sizeValidation;

    final bytes = await file.readAsBytes();
    // O recorte deve continuar enviando JPEG, conforme o contrato de avatar.
    if (jpegOnly &&
        (bytes.length < 3 ||
            bytes[0] != 0xff ||
            bytes[1] != 0xd8 ||
            bytes[2] != 0xff)) {
      return AvatarImageValidation.invalid;
    }

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      return AvatarImageValidation.valid;
    } catch (_) {
      return AvatarImageValidation.invalid;
    }
  }
}
