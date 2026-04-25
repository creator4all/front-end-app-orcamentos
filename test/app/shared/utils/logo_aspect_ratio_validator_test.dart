import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/logo_aspect_ratio_validator.dart';

void main() {
  group('LogoAspectRatioValidator', () {
    test('accepts square images', () {
      expect(
        LogoAspectRatioValidator.isValidDimensions(width: 1000, height: 1000),
        isTrue,
      );
    });

    test('accepts 16:9 images', () {
      expect(
        LogoAspectRatioValidator.isValidDimensions(width: 1600, height: 900),
        isTrue,
      );
    });

    test('rejects unsupported aspect ratios', () {
      expect(
        LogoAspectRatioValidator.isValidDimensions(width: 1500, height: 1000),
        isFalse,
      );
      expect(
        LogoAspectRatioValidator.isValidDimensions(width: 1024, height: 768),
        isFalse,
      );
    });
  });
}
