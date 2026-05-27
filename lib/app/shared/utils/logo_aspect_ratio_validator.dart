import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class LogoAspectRatioValidator {
  static const double tolerance = 0.02;
  static const double squareRatio = 1.0;
  static const double widescreenRatio = 16 / 9;

  static const String invalidAspectRatioMessage =
      'A logo deve estar nos formatos 1:1 ou 16:9.';

  static bool isValidDimensions({
    required int width,
    required int height,
    double tolerance = LogoAspectRatioValidator.tolerance,
  }) {
    if (width <= 0 || height <= 0) {
      return false;
    }

    final aspectRatio = width / height;

    return _isWithinTolerance(aspectRatio, squareRatio, tolerance) ||
        _isWithinTolerance(aspectRatio, widescreenRatio, tolerance);
  }

  static Future<bool> isValidFile(File file) async {
    final dimensions = await getImageDimensions(file);
    return isValidDimensions(
        width: dimensions.width, height: dimensions.height);
  }

  static bool isValidDimensionsForAspectRatio({
    required int width,
    required int height,
    required LogoSupportedAspectRatio aspectRatio,
    double tolerance = LogoAspectRatioValidator.tolerance,
  }) {
    if (width <= 0 || height <= 0) {
      return false;
    }

    return _isWithinTolerance(width / height, aspectRatio.value, tolerance);
  }

  static Future<bool> isValidFileForAspectRatio({
    required File file,
    required LogoSupportedAspectRatio aspectRatio,
    double tolerance = LogoAspectRatioValidator.tolerance,
  }) async {
    final dimensions = await getImageDimensions(file);
    return isValidDimensionsForAspectRatio(
      width: dimensions.width,
      height: dimensions.height,
      aspectRatio: aspectRatio,
      tolerance: tolerance,
    );
  }

  static LogoSupportedAspectRatio closestSupportedAspectRatio({
    required int width,
    required int height,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('As dimensões da imagem devem ser maiores que zero.');
    }

    final aspectRatio = width / height;
    final squareDistance = (aspectRatio - squareRatio).abs();
    final widescreenDistance = (aspectRatio - widescreenRatio).abs();

    return squareDistance <= widescreenDistance
        ? LogoSupportedAspectRatio.square
        : LogoSupportedAspectRatio.widescreen;
  }

  static Future<LogoSupportedAspectRatio> closestSupportedAspectRatioForFile(
    File file,
  ) async {
    final dimensions = await getImageDimensions(file);
    return closestSupportedAspectRatio(
      width: dimensions.width,
      height: dimensions.height,
    );
  }

  static Future<LogoImageDimensions> getImageDimensions(File file) async {
    final bytes = await file.readAsBytes();
    return decodeDimensions(bytes);
  }

  static Future<LogoImageDimensions> decodeDimensions(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);

    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;

      try {
        return LogoImageDimensions(width: image.width, height: image.height);
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  static bool _isWithinTolerance(
    double value,
    double expected,
    double tolerance,
  ) {
    return (value - expected).abs() <= tolerance;
  }
}

class LogoImageDimensions {
  final int width;
  final int height;

  const LogoImageDimensions({
    required this.width,
    required this.height,
  });
}

enum LogoSupportedAspectRatio {
  square,
  widescreen;

  int get ratioX {
    switch (this) {
      case LogoSupportedAspectRatio.square:
        return 1;
      case LogoSupportedAspectRatio.widescreen:
        return 16;
    }
  }

  int get ratioY {
    switch (this) {
      case LogoSupportedAspectRatio.square:
        return 1;
      case LogoSupportedAspectRatio.widescreen:
        return 9;
    }
  }

  double get value => ratioX / ratioY;
}
