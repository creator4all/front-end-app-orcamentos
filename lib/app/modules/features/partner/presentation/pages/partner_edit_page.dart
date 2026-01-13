import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/partner_store.dart';

class PartnerEditPage extends StatefulWidget {
  const PartnerEditPage({super.key});

  @override
  State<PartnerEditPage> createState() => _PartnerEditPageState();
}

class _PartnerEditPageState extends State<PartnerEditPage> {
  late final PartnerStore _store;
  late final AuthStore _authStore;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _tradeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<PartnerStore>();
    _authStore = Modular.get<AuthStore>();

    // Observar mudanças no partner e atualizar controllers
    reaction(
      (_) => _store.partner,
      (partner) {
        if (partner != null) {
          _tradeNameController.text = partner.tradeName;
          _emailController.text = partner.email ?? '';
          _phoneController.text = partner.phone;
          _legalNameController.text = partner.legalName;
          _cnpjController.text = _formatCnpj(partner.cnpj);
        }
      },
    );

    _store.fetch();
  }

  @override
  void dispose() {
    _tradeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _legalNameController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image != null) {
        // Abrir editor de recorte com suporte a múltiplos formatos
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar Logo',
              toolbarColor: const Color(0xFF117BBD),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square, // 1:1
                CropAspectRatioPreset.ratio16x9, // 16:9
                CropAspectRatioPreset.original, // Livre
              ],
            ),
            IOSUiSettings(
              title: 'Recortar Logo',
              aspectRatioLockEnabled: false,
              resetAspectRatioEnabled: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.square, // 1:1
                CropAspectRatioPreset.ratio16x9, // 16:9
                CropAspectRatioPreset.original, // Livre
              ],
            ),
          ],
        );

        if (croppedFile != null) {
          _store.setSelectedLogo(File(croppedFile.path));

          // Log do arquivo antes de fazer upload
          print('🖼️ Arquivo croppado: ${croppedFile.path}');

          // Upload automático
          final success = await _store.uploadLogo();

          if (!mounted) return;

          if (success) {
            // Recarregar dados do usuário na AuthStore
            await _authStore.loadCurrentUser();

            if (!mounted) return;

            CustomInfoDialog.show(
              context: context,
              type: DialogType.success,
              title: 'Logo atualizado!',
              message: 'A logo da sua empresa foi atualizada com sucesso.',
            );
          } else {
            // Detectar tipo de erro e exibir mensagem apropriada
            String errorTitle = 'Erro ao atualizar logo';
            String errorMessage =
                _store.error ?? 'Ocorreu um erro desconhecido.';
            DialogType dialogType = DialogType.error;

            // Se o erro contém informação sobre formato/tamanho, usar warning
            if (errorMessage.toLowerCase().contains('formato') ||
                errorMessage.toLowerCase().contains('tamanho') ||
                errorMessage.toLowerCase().contains('inválida')) {
              dialogType = DialogType.warning;
              errorTitle = 'Formato de imagem inválido';

              // Mensagem amigável para o usuário
              if (errorMessage.contains('Formatos aceitos')) {
                errorMessage =
                    'A imagem selecionada não está em um formato válido.\n\n'
                    'Por favor, escolha uma imagem nos formatos: JPG, PNG, GIF, WebP, BMP, TIFF ou SVG.\n\n'
                    'Tamanho máximo: 5MB';
              }
            }

            CustomInfoDialog.show(
              context: context,
              type: dialogType,
              title: errorTitle,
              message: errorMessage,
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao selecionar imagem',
        message:
            'Não foi possível abrir a imagem selecionada. Tente novamente.',
      );
    }
  }

  Future<void> _save() async {
    // Atualizar store com valores dos controllers
    _store.setTradeName(_tradeNameController.text);
    _store.setEmail(_emailController.text);
    _store.setPhone(_phoneController.text);

    final success = await _store.save();

    if (!mounted) return;

    if (success) {
      // Recarregar dados do usuário na AuthStore
      await _authStore.loadCurrentUser();

      if (!mounted) return;

      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Empresa atualizada!',
        message: 'As informações da sua empresa foram atualizadas com sucesso.',
      );
    } else {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao atualizar empresa',
        message: _store.error ??
            'Ocorreu um erro ao salvar as alterações. Tente novamente.',
      );
    }
  }

  String _extractBase64Data(String dataUri) {
    if (dataUri.contains(',')) {
      return dataUri.split(',').last;
    }
    return dataUri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Editar Empresa',
        showBackButton: true,
        authStore: _authStore,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            if (_store.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF117BBD),
                ),
              );
            }

            if (_store.error != null && _store.partner == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Erro ao carregar empresa',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _store.error!,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _store.fetch(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }

            final hasLogo = _store.partner?.logoBase64 != null ||
                _store.selectedLogo != null;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Container de Logo com borda dashed
                  _buildLogoContainer(hasLogo),

                  SizedBox(height: 12.h),

                  // Botão trocar/adicionar logo
                  TextButton.icon(
                    onPressed: _store.isSaving ? null : _pickImage,
                    icon: Icon(
                      hasLogo ? Icons.edit : Icons.add_photo_alternate,
                      size: 20.sp,
                    ),
                    label: Text(
                      hasLogo ? 'Trocar Logo' : 'Adicionar Logo',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF117BBD),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Nome Fantasia
                  _buildTextFieldWithLabel(
                    controller: _tradeNameController,
                    label: 'Nome Fantasia',
                  ),

                  SizedBox(height: 16.h),

                  // Email
                  _buildTextFieldWithLabel(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 16.h),

                  // Telefone
                  _buildTextFieldWithLabel(
                    controller: _phoneController,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
                  ),

                  SizedBox(height: 24.h),

                  // Razão Social (não editável)
                  _buildReadOnlyTextField(
                    controller: _legalNameController,
                    label: 'Razão Social',
                  ),

                  SizedBox(height: 16.h),

                  // CNPJ (não editável)
                  _buildReadOnlyTextField(
                    controller: _cnpjController,
                    label: 'CNPJ',
                  ),

                  SizedBox(height: 32.h),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: _store.isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: _store.isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _store.isSaving ? 'Salvando...' : 'Salvar Alterações',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoContainer(bool hasLogo) {
    return GestureDetector(
      onTap: _store.isSaving ? null : _pickImage,
      child: CustomPaint(
        painter: hasLogo
            ? null
            : DashedBorderPainter(
                color: Colors.grey[400]!,
                strokeWidth: 2,
                dashWidth: 8,
                dashSpace: 4,
                radius: 12,
              ),
        child: Container(
          width: double.infinity,
          height: 160.h,
          decoration: BoxDecoration(
            color: hasLogo ? Colors.grey[100] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildLogoContent(hasLogo),
        ),
      ),
    );
  }

  Widget _buildLogoContent(bool hasLogo) {
    // Mostra indicador de loading durante upload
    if (_store.isSaving && _store.selectedLogo != null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF117BBD)),
      );
    }

    // Mostra imagem selecionada localmente (ainda não enviada)
    if (_store.selectedLogo != null) {
      return Image.file(
        _store.selectedLogo!,
        fit: BoxFit.contain,
      );
    }

    // Mostra logo do servidor em base64
    if (_store.partner?.logoBase64 != null) {
      try {
        final base64Data = _extractBase64Data(_store.partner!.logoBase64!);
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.contain,
        );
      } catch (e) {
        // Se falhar ao decodificar, mostra placeholder
        return _buildLogoPlaceholder();
      }
    }

    // Placeholder quando não há logo
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48.r,
          color: Colors.grey[400],
        ),
        SizedBox(height: 8.h),
        Text(
          'Toque para adicionar',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF117BBD), width: 2),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  String _formatCnpj(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
}

/// CustomPainter para desenhar borda tracejada (dashed)
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 4,
    this.radius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
