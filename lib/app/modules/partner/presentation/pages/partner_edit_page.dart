import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import '../stores/partner_store.dart';
import '../../../../shared/widgets/custom_top_bar.dart';

class PartnerEditPage extends StatefulWidget {
  const PartnerEditPage({super.key});

  @override
  State<PartnerEditPage> createState() => _PartnerEditPageState();
}

class _PartnerEditPageState extends State<PartnerEditPage> {
  late final PartnerStore _store;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _tradeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<PartnerStore>();
    
    // Observar mudanças no partner e atualizar controllers
    reaction(
      (_) => _store.partner,
      (partner) {
        if (partner != null) {
          _tradeNameController.text = partner.tradeName;
          _emailController.text = partner.email ?? '';
          _phoneController.text = partner.phone;
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _store.setSelectedLogo(File(image.path));
        
        // Upload automático
        final success = await _store.uploadLogo();
        
        if (!mounted) return;
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar logo: ${_store.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar empresa: ${_store.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Editar Empresa',
        showBackButton: true,
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
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16.h),
                        Text(
                          'Erro ao carregar empresa',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // Logo da empresa
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: _store.partner?.logo != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      'https://your-api-url.com/storage/logos/${_store.partner!.logo}',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _store.partner?.logo == null
                              ? Icon(
                                  Icons.business,
                                  size: 60.r,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Botão trocar logo
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Trocar Logo'),
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

                      // Cards read-only
                      _buildReadOnlyCard('Razão Social', _store.partner?.legalName ?? ''),
                      SizedBox(height: 12.h),
                      _buildReadOnlyCard('CNPJ', _formatCnpj(_store.partner?.cnpj ?? '')),

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
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCnpj(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
}
