import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'custom_modal.dart';
import '../../modules/budget/external/services/budget_service.dart';
import '../../../stores/auth_store.dart';

/// Modal para exportar PDF com informações do vendedor e logo personalizada
class ExportPdfModal extends StatefulWidget {
  final int orcamentoId;
  
  const ExportPdfModal({
    super.key,
    required this.orcamentoId,
  });

  /// Método estático para mostrar o modal
  static Future<T?> show<T>({
    required BuildContext context,
    required int orcamentoId,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Exportar PDF',
      content: _ExportPdfContent(orcamentoId: orcamentoId),
    );
  }

  @override
  State<ExportPdfModal> createState() => _ExportPdfModalState();
}

class _ExportPdfModalState extends State<ExportPdfModal> {
  @override
  Widget build(BuildContext context) {
    return _ExportPdfContent(orcamentoId: widget.orcamentoId);
  }
}

class _ExportPdfContent extends StatefulWidget {
  final int orcamentoId;
  
  const _ExportPdfContent({required this.orcamentoId});

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
  
  // Estado de loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherDadosUsuario();
  }

  void _preencherDadosUsuario() {
    try {
      final authStore = Modular.get<AuthStore>();
      final user = authStore.user;
      
      if (user != null) {
        // Preencher nome
        _nomeVendedorController.text = user.name;
        
        // Preencher cargo baseado no role
        _cargoController.text = user.normalizedRole;
        
        // URL padrão (pode ser configurada)
        _urlController.text = 'www.multimidiaeducacional.com.br';
        
        print('✅ Dados do usuário preenchidos automaticamente');
        print('   Nome: ${user.name}');
        print('   Cargo: ${user.normalizedRole}');
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
      print('🔧 [Modal] Buscando BudgetService...');
      // Buscar BudgetService via Modular
      final budgetService = Modular.get<BudgetService>();
      print('✅ [Modal] BudgetService obtido');

      // Converter logo para base64 se existir
      String? logoBase64;
      if (_logoImage != null) {
        print('📸 [Modal] Convertendo logo para base64...');
        final bytes = await _logoImage!.readAsBytes();
        logoBase64 = base64Encode(bytes);
        print('✅ [Modal] Logo convertida');
      }

      print('📡 [Modal] Chamando API para gerar PDF...');
      // Chamar API para gerar PDF
      final result = await budgetService.gerarPdf(
        orcamentoId: widget.orcamentoId,
        nomeVendedor: _nomeVendedorController.text.trim(),
        cargo: _cargoController.text.trim(),
        telefone: _telefoneController.text.trim(),
        url: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
        logoBase64: logoBase64,
      );

      print('✅ [Modal] API retornou dados');
      print('🔍 [Modal] Resposta da API: $result');
      print('🔍 [Modal] Tipo do result: ${result.runtimeType}');
      print('🔍 [Modal] Keys do result: ${result.keys.toList()}');

      // Extrair dados do envelope da API
      // A resposta vem como: {sucesso: true, dados: {pdf: "...", nome_arquivo: "..."}, statusCodeHttp: 200}
      final dados = result['dados'] as Map<String, dynamic>?;
      
      if (dados == null) {
        print('❌ [Modal] Campo dados é null!');
        throw Exception('Resposta da API não contém dados');
      }

      print('🔍 [Modal] Dados extraídos, keys: ${dados.keys.toList()}');

      // Extrair PDF em base64 com tratamento de erro
      print('🔍 [Modal] Verificando campo pdf...');
      if (dados['pdf'] == null) {
        print('❌ [Modal] Campo pdf é null!');
        throw Exception('PDF não foi gerado pela API');
      }
      
      print('✅ [Modal] Campo pdf existe, extraindo...');
      final pdfBase64 = dados['pdf'] as String;
      final nomeArquivo = dados['nome_arquivo'] as String? ?? 'orcamento.pdf';
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
      );
      
      print('✅ [Modal] Compartilhamento concluído');
      print('📤 [Modal] Status: ${shareResult.status}');

      // Fechar modal DEPOIS do compartilhamento
      print('🚪 [Modal] Fechando modal...');
      if (mounted) {
        Navigator.of(context).pop();
        print('✅ [Modal] Modal fechada');
        
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF gerado e compartilhado com sucesso!'),
            backgroundColor: Color(0xFF56B34A),
            duration: Duration(seconds: 3),
          ),
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
