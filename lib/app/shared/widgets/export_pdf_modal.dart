import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../modules/features/auth/presentation/stores/auth_store.dart';
import '../../modules/features/budget/budget_edit/domain/repositories/budget_pdf_repository.dart';
import '../../modules/features/budget/budget_edit/domain/usecases/generate_pdf_usecase.dart';
import '../../modules/features/partner/data/services/partner_service.dart'; // ← NOVO
import 'custom_info_dialog.dart';
import 'custom_modal.dart';

/// Modal para exportar PDF com informações do vendedor e logo personalizada
class ExportPdfModal extends StatefulWidget {
  final int orcamentoId;
  final GeneratePdfUseCase? generatePdfUseCase;

  const ExportPdfModal({
    super.key,
    required this.orcamentoId,
    this.generatePdfUseCase,
  });

  /// Método estático para mostrar o modal
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

  @override
  State<ExportPdfModal> createState() => _ExportPdfModalState();
}

class _ExportPdfModalState extends State<ExportPdfModal> {
  @override
  Widget build(BuildContext context) {
    return _ExportPdfContent(
      orcamentoId: widget.orcamentoId,
      generatePdfUseCase: widget.generatePdfUseCase,
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
  // Controllers para os campos de texto
  final TextEditingController _nomeVendedorController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // Variáveis para gerenciar a logo
  File? _logoImage;
  String? _partnerLogoBase64; // ← NOVO: Logo do banco
  final ImagePicker _picker = ImagePicker();

  // Variáveis para as novas checkboxes ← NOVO
  bool _incluirLogoNoPdf = true;
  bool _incluirCensoNoPdf = false;

  // Estado de loading
  bool _isLoading = false;
  bool _isLoadingPartnerLogo = false; // ← NOVO

  @override
  void initState() {
    super.initState();
    _preencherDadosUsuario();
    _carregarLogoParceiro(); // ← NOVO
  }

  Future<void> _carregarLogoParceiro() async {
    setState(() => _isLoadingPartnerLogo = true);

    try {
      final partnerService = Modular.get<PartnerService>();
      final partner = await partnerService.obterParceiro();

      if (partner.logoBase64 != null && partner.logoBase64!.isNotEmpty) {
        setState(() {
          _partnerLogoBase64 = partner.logoBase64;
        });
        print('✅ [Modal] Logo do parceiro carregada');
      }
    } catch (e) {
      print('⚠️ [Modal] Erro ao carregar logo do parceiro: $e');
      // Não mostra erro para o usuário pois a logo é opcional
    } finally {
      if (mounted) {
        setState(() => _isLoadingPartnerLogo = false);
      }
    }
  }

  void _preencherDadosUsuario() {
    try {
      final authStore = Modular.get<AuthStore>();
      final user = authStore.currentUser;

      if (user != null) {
        print('✅ [Modal] Preenchendo dados do usuário do /me endpoint');

        // Preencher nome do vendedor
        _nomeVendedorController.text = user.name;
        print('   Nome: ${user.name}');

        // Preencher cargo (campo direto da API)
        if (user.cargo != null && user.cargo!.isNotEmpty) {
          _cargoController.text = user.cargo!;
          print('   Cargo: ${user.cargo}');
        } else if (user.role != null) {
          // Fallback: usar role se cargo não estiver disponível
          _cargoController.text = user.role!.name;
          print('   Cargo (fallback role): ${user.role!.name}');
        }

        // Preencher telefone (campo direto da API)
        if (user.phone != null && user.phone!.isNotEmpty) {
          _telefoneController.text = user.phone!;
          print('   Telefone: ${user.phone}');
        }

        // URL padrão
        _urlController.text = 'www.multimidiaeducacional.com.br';

        print('✅ Dados do usuário preenchidos automaticamente');
      } else {
        print('⚠️ [Modal] Usuário não está logado ou currentUser é null');
      }
    } catch (e) {
      print('⚠️ Erro ao carregar dados do usuário: $e');
    }
  }

  @override
  void dispose() {
    _nomeVendedorController.dispose();
    _cargoController.dispose();
    _telefoneController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Nome do Vendedor
        _buildTextField(
          controller: _nomeVendedorController,
          label: 'Nome vendedor',
          hintText: 'Digite o nome do vendedor',
          isRequired: true,
        ),
        SizedBox(height: 16.h),

        // Campo Cargo
        _buildTextField(
          controller: _cargoController,
          label: 'Cargo',
          hintText: 'Digite o cargo',
          isRequired: true,
        ),
        SizedBox(height: 16.h),

        // Campo Telefone
        _buildTextField(
          controller: _telefoneController,
          label: 'Telefone',
          hintText: 'Digite o telefone',
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        SizedBox(height: 16.h),

        // Campo URL
        _buildTextField(
          controller: _urlController,
          label: 'URL',
          hintText: 'Digite a URL',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 24.h),

        // Seção da Logo
        _buildLogoSection(),
        SizedBox(height: 24.h),

        // Checkboxes de opções ← NOVO
        _buildCheckboxSection(),
        SizedBox(height: 32.h),

        // Botão Compartilhar PDF
        _buildShareButton(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildCheckboxSection() {
    return Column(
      children: [
        // Checkbox: Incluir logo no PDF
        CheckboxListTile(
          title: Text(
            'Incluir logo no PDF',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
          value: _incluirLogoNoPdf,
          onChanged: (value) {
            setState(() => _incluirLogoNoPdf = value ?? true);
          },
          activeColor: const Color(0xFF117BBD),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        // Checkbox: Incluir dados do censo escolar
        CheckboxListTile(
          title: Text(
            'Incluir dados do censo escolar',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
          value: _incluirCensoNoPdf,
          onChanged: (value) {
            setState(() => _incluirCensoNoPdf = value ?? false);
          },
          activeColor: const Color(0xFF117BBD),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 44.h,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
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
                borderSide: const BorderSide(color: Color(0xFF117BBD)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
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

        // Preview da logo
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.grey[50],
          ),
          child: _isLoadingPartnerLogo
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF117BBD),
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
        SizedBox(height: 12.h),

        // Botão Enviar Logo
        SizedBox(
          width: double.infinity,
          height: 40.h,
          child: OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: Icon(
              Icons.upload_outlined,
              size: 18.sp,
              color: const Color(0xFF117BBD),
            ),
            label: Text(
              'Enviar logo',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF117BBD),
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF117BBD)),
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
        // Botão para remover a imagem (só se for a temporária)
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
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _logoImage = File(pickedFile.path);
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

  String _extractBase64Data(String dataUri) {
    if (dataUri.contains(',')) {
      return dataUri.split(',').last;
    }
    return dataUri;
  }

  Future<void> _handleSharePdf() async {
    // Validar campos obrigatórios
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

    print('🚀 [Modal] Iniciando geração de PDF...');

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔧 [Modal] Buscando GeneratePdfUseCase...');
      // Usar UseCase passado como parâmetro ou buscar via Modular
      final generatePdfUseCase =
          widget.generatePdfUseCase ?? Modular.get<GeneratePdfUseCase>();
      print('✅ [Modal] GeneratePdfUseCase obtido');

      // Decidir qual logo enviar baseado no checkbox e na seleção
      String? logoBase64;
      if (_incluirLogoNoPdf) {
        if (_logoImage != null) {
          print('📸 [Modal] Convertendo logo selecionada para base64...');
          final bytes = await _logoImage!.readAsBytes();
          logoBase64 = base64Encode(bytes);
        } else if (_partnerLogoBase64 != null) {
          print('📸 [Modal] Usando logo original do parceiro...');
          logoBase64 = _extractBase64Data(_partnerLogoBase64!);
        }
      }

      print('📡 [Modal] Chamando UseCase para gerar PDF...');
      // Chamar UseCase para gerar PDF
      final params = GeneratePdfParams(
        orcamentoId: widget.orcamentoId,
        nomeVendedor: _nomeVendedorController.text.trim(),
        cargo: _cargoController.text.trim(),
        telefone: _telefoneController.text.trim(),
        url: _urlController.text.trim().isNotEmpty
            ? _urlController.text.trim()
            : null,
        incluirLogo: _incluirLogoNoPdf,
        incluirCenso: _incluirCensoNoPdf,
        logoBase64: logoBase64,
      );

      final result = await generatePdfUseCase(params);

      // Processar resultado com Either (dartz)
      final pdfResult = result.fold(
        (failure) {
          print('❌ [Modal] Falha: ${failure.message}');
          throw Exception(failure.message);
        },
        (success) => success,
      );

      print('✅ [Modal] UseCase retornou dados');

      final pdfBase64 = pdfResult.pdfBase64;
      final nomeArquivo = pdfResult.nomeArquivo ?? 'orcamento.pdf';
      print('✅ [Modal] PDF extraído: ${pdfBase64.substring(0, 50)}...');

      print('📄 [Modal] PDF recebido, tamanho: ${pdfBase64.length} caracteres');

      // Decodificar e salvar PDF
      print('🔄 [Modal] Decodificando PDF...');
      final pdfBytes = base64Decode(pdfBase64);
      print('✅ [Modal] PDF decodificado, tamanho: ${pdfBytes.length} bytes');

      print('📁 [Modal] Obtendo diretório temporário...');
      final tempDir = await getTemporaryDirectory();
      print('✅ [Modal] Diretório temporário: ${tempDir.path}');

      final file = File('${tempDir.path}/$nomeArquivo');
      print('💾 [Modal] Salvando arquivo em: ${file.path}');
      await file.writeAsBytes(pdfBytes);
      print('✅ [Modal] Arquivo salvo');

      final fileExists = await file.exists();
      print('📄 [Modal] Arquivo existe: $fileExists');

      if (!fileExists) {
        throw Exception('Arquivo não foi salvo corretamente');
      }

      // Compartilhar PDF usando o share nativo (ANTES de fechar a modal)
      print('📤 [Modal] Iniciando compartilhamento...');
      print('📤 [Modal] Arquivo: ${file.path}');

      final shareResult = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Orçamento - ${_nomeVendedorController.text.trim()}',
        subject: 'Orçamento - ${_nomeVendedorController.text.trim()}',
        sharePositionOrigin: _getSharePositionOrigin(context),
      );

      print('✅ [Modal] Compartilhamento concluído');
      print('📤 [Modal] Status: ${shareResult.status}');

      // Fechar modal DEPOIS do compartilhamento
      print('🚪 [Modal] Fechando modal...');
      if (mounted) {
        Navigator.of(context).pop();
        print('✅ [Modal] Modal fechada');

        // Mostrar mensagem de sucesso
        CustomInfoDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Sucesso!',
          message: 'PDF gerado e compartilhado com sucesso!',
        );
      }
    } catch (e, stackTrace) {
      // Mostrar erro
      print('❌ [Modal] ERRO: $e');
      print('❌ [Modal] Stack trace: $stackTrace');

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
