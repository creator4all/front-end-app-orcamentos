enum AvatarImageValidation { valid, tooLarge, invalid }

abstract class AvatarImageValidator {
  static const maxBytes = 5 * 1024 * 1024;

  static AvatarImageValidation validateSize(int bytes) {
    if (bytes > maxBytes) return AvatarImageValidation.tooLarge;
    if (bytes <= 0) return AvatarImageValidation.invalid;
    return AvatarImageValidation.valid;
  }

  Future<AvatarImageValidation> validate(String path, {bool jpegOnly = false});
}
