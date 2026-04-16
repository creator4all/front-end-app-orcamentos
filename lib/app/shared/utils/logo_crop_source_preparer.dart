import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class PreparedLogoCropSource {
  final File file;
  final bool shouldDelete;

  const PreparedLogoCropSource({
    required this.file,
    required this.shouldDelete,
  });

  factory PreparedLogoCropSource.original(File file) {
    return PreparedLogoCropSource(file: file, shouldDelete: false);
  }

  Future<void> dispose() async {
    if (!shouldDelete) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }
}

class LogoCropSourcePreparer {
  static const double widescreenRatio = 16 / 9;
  static const double tolerance = 0.01;

  static Future<PreparedLogoCropSource> prepareForCrop(
    File sourceFile, {
    double targetAspectRatio = widescreenRatio,
  }) async {
    final bytes = await sourceFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);

    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;

      try {
        final width = image.width;
        final height = image.height;
        final sourceAspectRatio = width / height;

        if ((sourceAspectRatio - targetAspectRatio).abs() <= tolerance) {
          return PreparedLogoCropSource.original(sourceFile);
        }

        final canvasSize = calculateCanvasDimensions(
          width: width,
          height: height,
          targetAspectRatio: targetAspectRatio,
        );

        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final backgroundPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);

        canvas.drawRect(
          ui.Rect.fromLTWH(
            0,
            0,
            canvasSize.width.toDouble(),
            canvasSize.height.toDouble(),
          ),
          backgroundPaint,
        );

        canvas.drawImage(
          image,
          ui.Offset(
            (canvasSize.width - width) / 2,
            (canvasSize.height - height) / 2,
          ),
          ui.Paint(),
        );

        final picture = recorder.endRecording();
        final renderedImage =
            await picture.toImage(canvasSize.width, canvasSize.height);

        try {
          final byteData =
              await renderedImage.toByteData(format: ui.ImageByteFormat.png);

          if (byteData == null) {
            throw Exception('Não foi possível preparar a imagem para recorte.');
          }

          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/logo_crop_source_${DateTime.now().microsecondsSinceEpoch}.png',
          );

          await tempFile.writeAsBytes(
            byteData.buffer.asUint8List(),
            flush: true,
          );

          return PreparedLogoCropSource(file: tempFile, shouldDelete: true);
        } finally {
          renderedImage.dispose();
        }
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  static CropCanvasDimensions calculateCanvasDimensions({
    required int width,
    required int height,
    double targetAspectRatio = widescreenRatio,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('As dimensões da imagem devem ser maiores que zero.');
    }

    final sourceAspectRatio = width / height;

    if ((sourceAspectRatio - targetAspectRatio).abs() <= tolerance) {
      return CropCanvasDimensions(width: width, height: height);
    }

    if (sourceAspectRatio > targetAspectRatio) {
      return CropCanvasDimensions(
        width: width,
        height: math.max(height, (width / targetAspectRatio).ceil()),
      );
    }

    return CropCanvasDimensions(
      width: math.max(width, (height * targetAspectRatio).ceil()),
      height: height,
    );
  }
}

class CropCanvasDimensions {
  final int width;
  final int height;

  const CropCanvasDimensions({
    required this.width,
    required this.height,
  });
}
