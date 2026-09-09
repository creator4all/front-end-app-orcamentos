import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_checkbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../widgets/custom_text_field.dart';
import '../../modules/features/auth/presentation/stores/auth_store.dart';
import '../../modules/features/budget/budget_edit/domain/repositories/budget_pdf_repository.dart';
import '../../modules/features/budget/budget_edit/domain/usecases/generate_pdf_usecase.dart';
import '../../modules/features/partner/data/services/partner_service.dart';
import '../utils/brazilian_phone_input_formatter.dart';
import '../utils/crop_aspect_ratio_presets.dart';
import '../utils/email_validator.dart';
import '../utils/logo_aspect_ratio_validator.dart';
import '../utils/logo_crop_source_preparer.dart';
import 'custom_info_dialog.dart';
import 'custom_modal.dart';

abstract class ExportPdfModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required int orcamentoId,
    GeneratePdfUseCase? generatePdfUseCase,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Exportar PDF',
      content: _ExportPdfContent(
        orcamentoId: orcamentoId,
        generatePdfUseCase: generatePdfUseCase,
      ),
    );
  }
}

class _ExportPdfContent extends StatefulWidget {
  final int orcamentoId;
  final GeneratePdfUseCase? generatePdfUseCase;

  const _ExportPdfContent({
    required this.orcamentoId,
    this.generatePdfUseCase,
  });

  @override
  State<_ExportPdfContent> createState() => _ExportPdfContentState();
}

class _ExportPdfContentState extends State<_ExportPdfContent> {
  static const Color _pdfActionColor = Color(0xFF117BBD);

  final TextEditingController _nomeVendedorController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  File? _logoImage;
  String? _partnerLogoBase64;
  final ImagePicker _picker = ImagePicker();

  bool _incluirLogoNoPdf = true;
  bool _incluirCensoNoPdf = false;
  bool _incluirUrlNoPdf = false;

  bool _isLoading = false;
  bool _isLoadingPartnerLogo = false;

  @override
  void initState() {
    super.initState();
    _preencherDadosUsuario();
    _carregarLogoParceiro();
  }

  Future<void> _carregarLogoParceiro() async {
    setState(() => _isLoadingPartnerLogo = true);

    try {
      final partnerService = Modular.get<PartnerService>();
      final partner = await partnerService.obterParceiro();

      if (!mounted) return;

      final partnerUrl = partner.url?.trim() ?? '';
      setState(() {
        _partnerLogoBase64 =
            partner.logoBase64?.isNotEmpty == true ? partner.logoBase64 : null;
        _urlController.text = partnerUrl;
        _incluirUrlNoPdf = partnerUrl.isNotEmpty;
      });
    } catch (_) {
      _partnerLogoBase64 = null;
    } finally {
      if (mounted) {
        setState(() => _isLoadingPartnerLogo = false);
      }
    }
  }

  void _preencherDadosUsuario() {
    final authStore = Modular.get<AuthStore>();
    final user = authStore.currentUser;
    if (user == null) return;

    _nomeVendedorController.text = user.name;
    if (user.cargo != null && user.cargo!.isNotEmpty) {
      _cargoController.text = user.cargo!;
    } else if (user.role != null) {
      _cargoController.text = user.role!.name;
    }

    if (user.phone != null && user.phone!.isNotEmpty) {
      _telefoneController.text = BrazilianPhoneInputFormatter.format(
        user.phone!,
      );
    }

    _emailController.text = user.email;

    // URL será preenchida em _carregarLogoParceiro com a URL do parceiro
  }

  @override
  void dispose() {
    _nomeVendedorController.dispose();
    _cargoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nomeVendedorController,
          label: 'Nome vendedor',
          hintText: 'Digite o nome do vendedor',
          isRequired: true,
          height: 44.h,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _cargoController,
          label: 'Cargo',
          hintText: 'Digite o cargo',
          isRequired: true,
          height: 44.h,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _telefoneController,
          label: 'Telefone',
          hintText: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          inputFormatters: [BrazilianPhoneInputFormatter()],
          isRequired: true,
          height: 44.h,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _emailController,
          label: 'E-mail',
          hintText: 'Digite o e-mail do vendedor',
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          height: 44.h,
        ),
        SizedBox(height: 16.h),
        _buildUrlSection(),
        SizedBox(height: 20.h),
        _buildLogoSection(),
        SizedBox(height: 20.h),
        _buildCensoSection(),
        SizedBox(height: 32.h),
        _buildShareButton(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: _incluirUrlNoPdf ? 1 : 0.55,
          child: CustomTextField(
            controller: _urlController,
            label: 'URL',
            hintText: 'Digite a URL',
            keyboardType: TextInputType.url,
            enabled: _incluirUrlNoPdf,
            height: 44.h,
          ),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxRow(
          value: _incluirUrlNoPdf,
          label: 'Incluir URL no PDF',
          onChanged: (value) {
            setState(() => _incluirUrlNoPdf = value);
          },
        ),
      ],
    );
  }

  Widget _buildCensoSection() {
    return _buildCheckboxRow(
      value: _incluirCensoNoPdf,
      label: 'Incluir dados do censo escolar',
      onChanged: (value) {
        setState(() => _incluirCensoNoPdf = value);
      },
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      button: true,
      checked: value,
      label: label,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 44.h),
          child: Row(
            children: [
              CustomCheckbox(
                value: value,
                onChanged: null,
                checkedColor: _pdfActionColor,
                enabled: true,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final logoControlsEnabled = _incluirLogoNoPdf;
    final logoAccentColor =
        logoControlsEnabled ? _pdfActionColor : Colors.grey[400]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Opacity(
          opacity: logoControlsEnabled ? 1 : 0.55,
          child: IgnorePointer(
            ignoring: !logoControlsEnabled,
            child: Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: logoControlsEnabled
                      ? Colors.grey[300]!
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8.r),
                color: logoControlsEnabled ? Colors.grey[50] : Colors.grey[100],
              ),
              child: _isLoadingPartnerLogo
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _pdfActionColor,
                      ),
                    )
                  : _logoImage != null
                      ? _buildPreviewImage(file: _logoImage)
                      : _partnerLogoBase64 != null
                          ? _buildPreviewImage(base64: _partnerLogoBase64)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 40.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Nenhuma logo selecionada',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _buildCheckboxRow(
          value: _incluirLogoNoPdf,
          label: 'Incluir logo no PDF',
          onChanged: (value) {
            setState(() => _incluirLogoNoPdf = value);
          },
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 40.h,
          child: OutlinedButton.icon(
            onPressed: logoControlsEnabled ? _pickLogo : null,
            icon: Icon(
              Icons.upload_outlined,
              size: 18.sp,
              color: logoAccentColor,
            ),
            label: Text(
              'Enviar logo',
              style: TextStyle(
                fontSize: 14.sp,
                color: logoAccentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: logoAccentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewImage({File? file, String? base64}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: file != null
              ? Image.file(
                  file,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.memory(
                  base64Decode(_extractBase64Data(base64!)),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        if (file != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _removeLogo,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSharePdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Compartilhar PDF',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (pickedFile != null) {
        final sourceLogo = File(pickedFile.path);
        final targetAspectRatio = Platform.isAndroid || Platform.isIOS
            ? await LogoAspectRatioValidator.closestSupportedAspectRatioForFile(
                sourceLogo,
              )
            : null;
        final preparedSource = Platform.isAndroid || Platform.isIOS
            ? await LogoCropSourcePreparer.prepareForCrop(
                sourceLogo,
                targetAspectRatio: targetAspectRatio?.value ??
                    LogoCropSourcePreparer.widescreenRatio,
              )
            : PreparedLogoCropSource.original(sourceLogo);
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: preparedSource.file.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          aspectRatio: targetAspectRatio == null
              ? null
              : CropAspectRatio(
                  ratioX: targetAspectRatio.ratioX.toDouble(),
                  ratioY: targetAspectRatio.ratioY.toDouble(),
                ),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar Logo',
              toolbarColor: const Color(0xFF117BBD),
              statusBarLight: false,
              navBarLight: false,
              toolbarWidgetColor: Colors.white,
              initAspectRatio:
                  targetAspectRatio == LogoSupportedAspectRatio.square
                      ? const CropPresetQuadrado()
                      : const CropPreset16x9(),
              lockAspectRatio: true,
              hideBottomControls: false,
              aspectRatioPresets: [
                const CropPresetQuadrado(),
                const CropPreset16x9()
              ],
            ),
            IOSUiSettings(
              title: 'Recortar Logo',
              doneButtonTitle: 'Recortar',
              cancelButtonTitle: 'Cancelar',
              resetButtonHidden: true,
              aspectRatioLockEnabled: true,
              aspectRatioLockDimensionSwapEnabled: false,
              aspectRatioPickerButtonHidden: true,
              resetAspectRatioEnabled: false,
              hidesNavigationBar: false,
            ),
          ],
        );
        await preparedSource.dispose();

        if (croppedFile != null) {
          final selectedLogo = File(croppedFile.path);
          final isValidLogo = targetAspectRatio == null
              ? await LogoAspectRatioValidator.isValidFile(selectedLogo)
              : await LogoAspectRatioValidator.isValidFileForAspectRatio(
                  file: selectedLogo,
                  aspectRatio: targetAspectRatio,
                );

          if (!isValidLogo) {
            if (mounted) {
              _showInvalidLogoWarning();
            }
            return;
          }

          setState(() {
            _logoImage = selectedLogo;
          });

          if (mounted) {
            CustomInfoDialog.show(
              context: context,
              type: DialogType.success,
              title: 'Sucesso',
              message: 'Logo selecionada com sucesso!',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro',
          message: 'Erro ao selecionar imagem: $e',
        );
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoImage = null;
    });

    if (mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Logo removida',
        message: 'A logo temporária foi removida.',
      );
    }
  }

  void _showInvalidLogoWarning() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.warning,
      title: 'Formato de logo inválido',
      message: LogoAspectRatioValidator.invalidAspectRatioMessage,
    );
  }

  String _extractBase64Data(String dataUri) {
    if (dataUri.contains(',')) {
      return dataUri.split(',').last;
    }
    return dataUri;
  }

  Future<void> _handleSharePdf() async {
    final sharePositionOrigin = _getSharePositionOrigin(context);

    if (_nomeVendedorController.text.trim().isEmpty) {
      _showErrorMessage('Nome do vendedor é obrigatório');
      return;
    }

    if (_cargoController.text.trim().isEmpty) {
      _showErrorMessage('Cargo é obrigatório');
      return;
    }

    if (_telefoneController.text.trim().isEmpty) {
      _showErrorMessage('Telefone é obrigatório');
      return;
    }

    if (!BrazilianPhoneInputFormatter.isValid(_telefoneController.text)) {
      _showErrorMessage('Telefone inválido');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('E-mail do vendedor é obrigatório');
      return;
    }

    if (!EmailValidator.isValid(_emailController.text.trim())) {
      _showErrorMessage('E-mail do vendedor inválido');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final generatePdfUseCase =
          widget.generatePdfUseCase ?? Modular.get<GeneratePdfUseCase>();
      String? logoBase64;
      if (_incluirLogoNoPdf) {
        if (_logoImage != null) {
          final bytes = await _logoImage!.readAsBytes();
          logoBase64 = base64Encode(bytes);
        } else if (_partnerLogoBase64 != null) {
          logoBase64 = _extractBase64Data(_partnerLogoBase64!);
        }
      }

      final params = GeneratePdfParams(
        orcamentoId: widget.orcamentoId,
        nomeVendedor: _nomeVendedorController.text.trim(),
        cargo: _cargoController.text.trim(),
        telefone: BrazilianPhoneInputFormatter.format(
          _telefoneController.text.trim(),
        ),
        emailVendedor: _emailController.text.trim(),
        url: _incluirUrlNoPdf
            ? (_urlController.text.trim().isNotEmpty
                ? _urlController.text.trim()
                : null)
            : null,
        incluirLogo: _incluirLogoNoPdf,
        incluirCenso: _incluirCensoNoPdf,
        incluirUrl: _incluirUrlNoPdf,
        logoBase64: logoBase64,
      );

      final result = await generatePdfUseCase(params);

      final pdfResult = result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (success) => success,
      );

      final pdfBase64 = pdfResult.pdfBase64;
      final nomeArquivo = pdfResult.nomeArquivo ?? 'orcamento.pdf';
      final pdfBytes = base64Decode(pdfBase64);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$nomeArquivo');
      await file.writeAsBytes(pdfBytes);
      final fileExists = await file.exists();
      if (!fileExists) {
        throw Exception('Arquivo não foi salvo corretamente');
      }

      final shareResult = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Orçamento - ${_nomeVendedorController.text.trim()}',
        subject: 'Orçamento - ${_nomeVendedorController.text.trim()}',
        sharePositionOrigin: sharePositionOrigin,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      if (shareResult.status == ShareResultStatus.success) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Sucesso!',
          message: 'PDF gerado e compartilhado com sucesso!',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorMessage('Erro ao gerar PDF: $e');
      }
    }
  }

  Rect _getSharePositionOrigin(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  void _showErrorMessage(String message) {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.error,
      title: 'Atenção',
      message: message,
    );
  }
}
