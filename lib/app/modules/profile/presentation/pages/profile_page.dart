import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../../features/auth/presentation/stores/auth_store.dart';
import '../stores/profile_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileStore _store;
  late final AuthStore _authStore;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<ProfileStore>();
    _authStore = Modular.get<AuthStore>();

    // Observar mudanças no perfil e atualizar controllers
    reaction(
      (_) => _store.profile,
      (profile) {
        if (profile != null) {
          _nameController.text = _store.name;
          _emailController.text = _store.email;
          _cargoController.text = _store.cargo;
          _phoneController.text = _store.phone;
          print('🔄 Controllers atualizados via reaction');
        }
      },
    );

    _store.fetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cargoController.dispose();
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
        _store.setSelectedAvatar(File(image.path));

        // Fazer upload automaticamente
        final success = await _store.uploadAvatar();
        if (success && mounted) {
          // ✅ Recarregar dados do usuário na AuthStore
          await _authStore.loadCurrentUser();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar atualizado com sucesso!'),
              backgroundColor: Colors.green,
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
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    // Atualizar store com valores dos controllers
    _store.setName(_nameController.text);
    _store.setEmail(_emailController.text);
    _store.setCargo(_cargoController.text);
    _store.setPhone(_phoneController.text);

    final success = await _store.save();

    if (!mounted) return;

    if (success) {
      // ✅ Recarregar dados do usuário na AuthStore
      await _authStore.loadCurrentUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar perfil: ${_store.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Meu Perfil',
        showBackButton: true,
        authStore: _authStore,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            if (_store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_store.profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_store.error ?? 'Erro ao carregar perfil'),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _store.fetch(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Informações adicionais (read-only) - MOVIDO PARA CIMA
                  if (_store.profile!.roleName != null)
                    _buildInfoCard(
                      'Função',
                      _store.profile!.roleName!,
                      Icons.admin_panel_settings_outlined,
                    ),

                  if (_store.profile!.partnerName != null) ...[
                    SizedBox(height: 8.h),
                    _buildInfoCard(
                      'Parceiro',
                      _store.profile!.partnerName!,
                      Icons.business_outlined,
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Avatar
                  Stack(
                    children: [
                      Observer(
                        builder: (_) {
                          final avatarUrl = _store.profile!.avatar;
                          const baseUrl =
                              'http://192.168.3.2:8080'; // TODO: Pegar do ApiConfig
                          return CircleAvatar(
                            radius: 60.r,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage('$baseUrl$avatarUrl')
                                    : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Icon(Icons.person,
                                    size: 60.sp, color: Colors.grey)
                                : null,
                          );
                        },
                      ),
                      if (_store.isUploadingAvatar)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Botão de trocar foto
                  ElevatedButton.icon(
                    onPressed: _store.isUploadingAvatar ? null : _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF117BBD),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _store.profile!.avatar == null ||
                              _store.profile!.avatar!.isEmpty
                          ? 'Adicionar Foto'
                          : 'Trocar Foto',
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Nome
                  _buildTextFieldWithLabel(
                    controller: _nameController,
                    label: 'Nome',
                  ),

                  SizedBox(height: 16.h),

                  // Email
                  _buildTextFieldWithLabel(
                    controller: _emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 16.h),

                  // Cargo
                  _buildTextFieldWithLabel(
                    controller: _cargoController,
                    label: 'Cargo',
                  ),

                  SizedBox(height: 16.h),

                  // Telefone
                  _buildTextFieldWithLabel(
                    controller: _phoneController,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
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
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: _store.isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _store.isSaving ? 'Salvando...' : 'Salvar Alterações',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
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
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF484848),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 50.h,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide:
                    const BorderSide(color: Color(0xFF117BBD), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF117BBD)),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
