import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multimidiaapp/app/shared/utils/document_validators.dart';
import 'package:multimidiaapp/app/shared/utils/email_validator.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../theme/app_theme.dart';
import '../../../../../../widgets/index.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/entities/partner_request.dart';
import '../stores/registration_store.dart';

class PartnerRequestPage extends StatefulWidget {
  const PartnerRequestPage({super.key});

  @override
  State<PartnerRequestPage> createState() => _PartnerRequestPageState();
}

class _PartnerRequestPageState extends State<PartnerRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _cnpjController = TextEditingController();

  PublicSectorExperience _publicSectorExperience = PublicSectorExperience.never;

  late final RegistrationStore store;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    store = Modular.get<RegistrationStore>();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/vendas.mp4',
      );

      await _videoController!.initialize();

      if (!mounted) return;

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          aspectRatio: _videoController!.value.aspectRatio,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF117BBD),
            handleColor: const Color(0xFF0C498E),
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade400,
          ),
        );
        _isVideoInitialized = true;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar vídeo: $e');
    }
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF117BBD),
          ),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  String _formatPhone(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.isNotEmpty) {
      value = '($value';
    }
    if (value.length > 3) {
      value = '${value.substring(0, 3)}) ${value.substring(3)}';
    }
    if (value.length > 10) {
      value = '${value.substring(0, 10)}-${value.substring(10)}';
    }

    return value;
  }

  String _formatCpfCnpj(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.length > 14) {
      value = value.substring(0, 14);
    }

    if (value.length <= 11) {
      if (value.length > 3) {
        value = '${value.substring(0, 3)}.${value.substring(3)}';
      }
      if (value.length > 7) {
        value = '${value.substring(0, 7)}.${value.substring(7)}';
      }
      if (value.length > 11) {
        value = '${value.substring(0, 11)}-${value.substring(11)}';
      }
    } else {
      if (value.length > 2) {
        value = '${value.substring(0, 2)}.${value.substring(2)}';
      }
      if (value.length > 6) {
        value = '${value.substring(0, 6)}.${value.substring(6)}';
      }
      if (value.length > 10) {
        value = '${value.substring(0, 10)}/${value.substring(10)}';
      }
      if (value.length > 15) {
        value = '${value.substring(0, 15)}-${value.substring(15)}';
      }
    }

    return value;
  }

  bool _validateRequiredFields() {
    final List<String> missingFields = [];

    if (_nameController.text.trim().isEmpty) {
      missingFields.add('Nome');
    }

    if (_emailController.text.trim().isEmpty) {
      missingFields.add('E-mail');
    } else if (!EmailValidator.isValid(_emailController.text.trim())) {
      missingFields.add('E-mail (formato inválido)');
    }

    if (_phoneController.text.trim().isEmpty) {
      missingFields.add('Telefone');
    } else {
      final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.length < 10 || phone.length > 11) {
        missingFields.add('Telefone (formato inválido)');
      }
    }

    if (_companyController.text.trim().isEmpty) {
      missingFields.add('Empresa');
    }

    if (_cnpjController.text.trim().isEmpty) {
      missingFields.add('CPF/CNPJ');
    } else {
      final document = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final validationError = DocumentValidators.getDocumentError(document);
      if (validationError != null) {
        missingFields.add('CPF/CNPJ (documento inválido)');
      }
    }

    if (missingFields.isNotEmpty) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Campos obrigatórios',
        message:
            'Por favor, preencha os seguintes campos:\n\n• ${missingFields.join('\n• ')}',
      );
      return false;
    }

    return true;
  }

  void _submitForm() async {
    if (!_validateRequiredFields()) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final request = PartnerRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      company: _companyController.text.trim(),
      cnpj: _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      publicSectorExperience: _publicSectorExperience,
    );

    await store.requestPartner(request);

    if (!mounted) return;

    if (store.requestPartnerSuccess) {
      _showSuccessDialog();
    } else if (store.requestPartnerError != null) {
      final errorMessage = store.requestPartnerError!;
      final isAlreadyRegistered = errorMessage.contains('409') ||
          errorMessage.toLowerCase().contains('já cadastrado') ||
          errorMessage.toLowerCase().contains('already');

      if (isAlreadyRegistered) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.warning,
          title: 'Cadastro já realizado',
          message:
              'Opa, você já fez o cadastro!\n\nA nossa equipe logo entrará em contato com você, não se preocupe.',
        );
      } else {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro ao enviar',
          message:
              'Ocorreu um erro ao enviar sua solicitação. Por favor, tente novamente.',
        );
      }
    }
  }

  void _showSuccessDialog() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.success,
      title: 'Solicitação enviada!',
      message:
          'Sua solicitação foi recebida com sucesso.\n\nAgora é só aguardar! Entraremos em contato o mais rápido possível.',
      buttonText: 'Entendi',
      barrierDismissible: false,
      onButtonPressed: () {
        store.resetAllState();
        Modular.to.navigate('/auth/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Seja parceiro',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/images/logo-multimidia-simple.svg',
                    width: 80.w,
                    height: 80.h,
                    semanticsLabel: 'Logo Multimídia',
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'Seja nosso parceiro!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  '1- Assista ao vídeo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildVideoPlayer(),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  '2- Caso você tenha interesse em ser parceiro, preencha os dados abaixo e entraremos em contato.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome:',
                  isRequired: true,
                  hintText: 'Informe seu nome',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu nome';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _emailController,
                  label: 'E-mail:',
                  isRequired: true,
                  hintText: 'Informe seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: EmailValidator.getError,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Telefone:',
                  isRequired: true,
                  hintText: 'Informe seu telefone',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    final formatted = _formatPhone(value);
                    if (formatted != value) {
                      _phoneController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu telefone';
                    }
                    final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (phone.length < 10 || phone.length > 11) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _companyController,
                  label: 'Empresa:',
                  isRequired: true,
                  hintText: 'Informe sua empresa',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua empresa';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _cnpjController,
                  label: 'CPF/CNPJ:',
                  isRequired: true,
                  hintText: 'Informe seu CPF ou CNPJ',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final formatted = _formatCpfCnpj(value);
                    if (formatted != value) {
                      _cnpjController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (value) =>
                      DocumentValidators.getDocumentError(value ?? ''),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Você atua ou já atuou com vendas na área pública?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                RadioListTile<PublicSectorExperience>(
                  title: const Text('Não, nunca atuei'),
                  value: PublicSectorExperience.never,
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                RadioListTile<PublicSectorExperience>(
                  title: const Text('Sim, atuei no passado'),
                  value: PublicSectorExperience.past,
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                RadioListTile<PublicSectorExperience>(
                  title: const Text('Sim, estou atuando'),
                  value: PublicSectorExperience.current,
                  groupValue: _publicSectorExperience,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _publicSectorExperience = value!;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                Observer(
                  builder: (_) => PrimaryButton(
                    text: 'Quero ser parceiro',
                    isLoading: store.isRequestingPartner,
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
