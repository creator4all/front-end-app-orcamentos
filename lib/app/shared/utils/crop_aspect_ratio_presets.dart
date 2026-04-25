import 'package:image_cropper/image_cropper.dart';

/// Preset 1:1 com label em português.
///
/// O [name] é enviado diretamente ao plugin nativo como título do item de menu,
/// por isso não é possível usar [CropAspectRatioPreset.square] para traduzir.
class CropPresetQuadrado implements CropAspectRatioPresetData {
  const CropPresetQuadrado();

  @override
  String get name => 'Quadrado';

  @override
  (int, int)? get data => (1, 1);
}

/// Preset 16:9 com label em português.
class CropPreset16x9 implements CropAspectRatioPresetData {
  const CropPreset16x9();

  @override
  String get name => '16:9';

  @override
  (int, int)? get data => (16, 9);
}
