import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_modal.dart';

/// Modal para exportar PDF com informações do vendedor e logo personalizada
class ExportPdfModal extends StatefulWidget {
  const ExportPdfModal({super.key});

  /// Método estático para mostrar o modal
  static Future<T?> show<T>({
    required BuildContext context,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Exportar PDF',
      content: const _ExportPdfContent(),
    );
  }

  @override
  State<ExportPdfModal> createState() => _ExportPdfModalState();
}

class _ExportPdfModalState extends State<ExportPdfModal> {
  @override
  Widget build(BuildContext context) {
    return const _ExportPdfContent();
  }
}

class _ExportPdfContent extends StatefulWidget {
  const _ExportPdfContent();

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
  final ImagePicker _picker = ImagePicker();

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
          label: 'Nome vendedor:',
          hintText: 'Digite o nome do vendedor',
        ),
        SizedBox(height: 16.h),

        // Campo Cargo
        _buildTextField(
          controller: _cargoController,
          label: 'Cargo:',
          hintText: 'Digite o cargo',
        ),
        SizedBox(height: 16.h),

        // Campo Telefone
        _buildTextField(
          controller: _telefoneController,
          label: 'Telefone:',
          hintText: 'Digite o telefone',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),

        // Campo URL
        _buildTextField(
          controller: _urlController,
          label: 'URL:',
          hintText: 'Digite a URL',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 24.h),

        // Seção da Logo
        _buildLogoSection(),
        SizedBox(height: 32.h),

        // Botão Compartilhar PDF
        _buildShareButton(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
          child: _logoImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _logoImage!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Botão para remover a imagem
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
                )
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

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _handleSharePdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo selecionada com sucesso!'),
              backgroundColor: Color(0xFF56B34A),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoImage = null;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo removida'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSharePdf() {
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

    // TODO: Implementar a lógica de geração e compartilhamento do PDF
    // Por enquanto, apenas mostrar uma mensagem de sucesso
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF gerado e compartilhado com sucesso!'),
        backgroundColor: Color(0xFF56B34A),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
