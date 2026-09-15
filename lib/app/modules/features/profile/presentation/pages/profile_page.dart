import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../../../../../widgets/custom_text_field.dart';
import '../../../../../shared/utils/brazilian_phone_input_formatter.dart';
import '../../../../../shared/utils/crop_aspect_ratio_presets.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/profile_store.dart';

class ProfilePage extends StatefulWidget {
  final ImagePicker? imagePicker;
  final ImageCropper? imageCropper;

  const ProfilePage({super.key, this.imagePicker, this.imageCropper});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileStore _store;
  late final AuthStore _authStore;
  late final ImagePicker _imagePicker;
  late final ImageCropper _imageCropper;
  late final ReactionDisposer _profileReactionDisposer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _cargoError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ProfileStore>();
    _authStore = Modular.get<AuthStore>();
    _imagePicker = widget.imagePicker ?? ImagePicker();
    _imageCropper = widget.imageCropper ?? ImageCropper();

    _profileReactionDisposer = reaction(
      (_) => (
        _store.profile?.name,
        _store.profile?.email,
        _store.profile?.cargo,
        _store.profile?.phone,
      ),
      (_) {
        if (_store.profile != null) {
          _nameController.text = _store.name;
          _emailController.text = _store.email;
          _cargoController.text = _store.cargo;
          _phoneController.text = BrazilianPhoneInputFormatter.format(
            _store.phone,
          );
        }
      },
    );

    _store.fetch();
  }

  @override
  void dispose() {
    _profileReactionDisposer();
    _nameController.dispose();
    _emailController.dispose();
    _cargoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final success = await _store.uploadAvatar(
      selectOriginal: _selectOriginal,
      cropImage: _cropImage,
      isActive: () => mounted,
    );
    if (!mounted) return;

    if (success) {
      await _authStore.loadCurrentUser(forceRefresh: true);
      if (!mounted) return;
      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Sucesso',
        message: 'Avatar atualizado com sucesso!',
      );
    } else if (_store.error != null) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao atualizar avatar',
        message: _store.error!,
      );
    }
  }

  Future<String?> _selectOriginal() async {
    // image_picker_ios 0.8.13 reencoda mesmo sem limites de tamanho/qualidade.
    if (Platform.isIOS) {
      return const MethodChannel('multimidia/profile_avatar_picker')
          .invokeMethod<String>('pickOriginal');
    }
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<String?> _cropImage(String sourcePath) async {
    final croppedFile = await _imageCropper.cropImage(
      sourcePath: sourcePath,
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar Foto',
          toolbarColor: const Color(0xFF117BBD),
          statusBarLight: false,
          navBarLight: false,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: const CropPresetQuadrado(),
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recortar Foto',
          doneButtonTitle: 'Recortar',
          cancelButtonTitle: 'Cancelar',
          aspectRatioLockEnabled: true,
          aspectRatioLockDimensionSwapEnabled: false,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
          hidesNavigationBar: false,
        ),
      ],
    );
    return croppedFile?.path;
  }

  Future<void> _confirmRemoveAvatar() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Foto'),
        content: const Text('Deseja realmente remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _store.removeAvatar();
      if (success) {
        await _authStore.loadCurrentUser(forceRefresh: true);
        if (mounted) {
          CustomInfoDialog.show(
            context: context,
            type: DialogType.success,
            title: 'Sucesso',
            message: 'Foto removida com sucesso!',
          );
        }
      } else if (_store.error != null) {
        if (mounted) {
          CustomInfoDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Erro na Remoção',
            message: 'Erro: ${_store.error}',
          );
        }
      }
    }
  }

  bool _validateFields() {
    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Nome é obrigatório');
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'E-mail é obrigatório');
      isValid = false;
    } else if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = 'E-mail inválido');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    if (_cargoController.text.trim().isEmpty) {
      setState(() => _cargoError = 'Cargo é obrigatório');
      isValid = false;
    } else {
      setState(() => _cargoError = null);
    }

    final phoneDigits = BrazilianPhoneInputFormatter.digitsOnly(
      _phoneController.text,
    );

    if (phoneDigits.isEmpty) {
      setState(() => _phoneError = 'Telefone é obrigatório');
      isValid = false;
    } else if (!BrazilianPhoneInputFormatter.isValid(_phoneController.text)) {
      setState(() => _phoneError = 'Telefone inválido');
      isValid = false;
    } else {
      setState(() => _phoneError = null);
    }

    return isValid;
  }

  Future<void> _save() async {
    if (!_validateFields()) {
      return;
    }

    _store.setName(_nameController.text.trim());
    _store.setEmail(_emailController.text.trim());
    _store.setCargo(_cargoController.text.trim());
    _store.setPhone(BrazilianPhoneInputFormatter.digitsOnly(
      _phoneController.text,
    ));

    final success = await _store.save();

    if (!mounted) return;

    if (success) {
      await _authStore.loadCurrentUser(forceRefresh: true);

      if (!mounted) return;

      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Sucesso',
        message: 'Perfil atualizado com sucesso!',
      );
    } else {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro na Atualização',
        message: _store.error ?? 'Não foi possível atualizar o perfil.',
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Observer(
                        builder: (_) {
                          return UserAvatarWidget(
                            avatarBase64: _store.profile!.avatarBase64,
                            userName: _store.profile!.name,
                            radius: 60,
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
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _store.isUploadingAvatar ? null : _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF117BBD),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                        ),
                        icon: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                        label: Text(
                          _store.profile!.avatar == null ||
                                  _store.profile!.avatar!.isEmpty
                              ? 'Adicionar Foto'
                              : 'Trocar Foto',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      if (_store.profile!.avatar != null &&
                          _store.profile!.avatar!.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        TextButton.icon(
                          onPressed: _store.isUploadingAvatar
                              ? null
                              : _confirmRemoveAvatar,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                          ),
                          icon: const Icon(Icons.delete,
                              size: 18, color: Colors.red),
                          label: Text('Remover',
                              style: TextStyle(fontSize: 13.sp)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 32.h),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome',
                    hintText: '',
                    isRequired: true,
                    errorText: _nameError,
                    height: 50.h,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    hintText: '',
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    errorText: _emailError,
                    height: 50.h,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _cargoController,
                    label: 'Cargo',
                    hintText: '',
                    isRequired: true,
                    errorText: _cargoError,
                    height: 50.h,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    hintText: '(00) 00000-0000',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [BrazilianPhoneInputFormatter()],
                    isRequired: true,
                    errorText: _phoneError,
                    height: 50.h,
                  ),
                  SizedBox(height: 32.h),
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
                          : const Icon(Icons.save, color: Colors.white),
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
}
