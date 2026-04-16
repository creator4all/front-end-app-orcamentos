import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/logo_crop_source_preparer.dart';

void main() {
  group('LogoCropSourcePreparer.calculateCanvasDimensions', () {
    test('pads wide images vertically to a 16:9 canvas', () {
      final dimensions = LogoCropSourcePreparer.calculateCanvasDimensions(
        width: 512,
        height: 250,
      );

      expect(dimensions.width, 512);
      expect(dimensions.height, 288);
    });

    test('pads tall images horizontally to a 16:9 canvas', () {
      final dimensions = LogoCropSourcePreparer.calculateCanvasDimensions(
        width: 1000,
        height: 800,
      );

      expect(dimensions.width, 1423);
      expect(dimensions.height, 800);
    });

    test('keeps 16:9 images unchanged', () {
      final dimensions = LogoCropSourcePreparer.calculateCanvasDimensions(
        width: 1600,
        height: 900,
      );

      expect(dimensions.width, 1600);
      expect(dimensions.height, 900);
    });
  });
}
