import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../theme/app_theme.dart';
import '../../../../../../widgets/index.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/entities/partner_request.dart';
import '../stores/registration_store.dart';

/// Página de solicitação de parceria - Adaptada do layout legado
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
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    store = Modular.get<RegistrationStore>();

    // Inicializar player de vídeo
    _videoController = VideoPlayerController.asset(
      'assets/videos/oportunidade_de_vendas.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoInitialized = true);
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  // Formatar telefone (XX) XXXXX-XXXX
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

  // Formatar CNPJ XX.XXX.XXX/XXXX-XX
  String _formatCNPJ(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

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

    return value;
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = PartnerRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        cnpj: _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '').isEmpty
            ? null
            : _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        publicSectorExperience: _publicSectorExperience,
      );

      await store.requestPartner(request);

      if (!mounted) return;

      if (store.requestPartnerSuccess) {
        _showSuccessDialog();
      } else if (store.requestPartnerError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(store.requestPartnerError!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de sucesso em círculo verde
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48.w,
                  color: Colors.green[600],
                ),
              ),
              SizedBox(height: 20.h),

              // Título
              Text(
                'Solicitação enviada!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Mensagem
              Text(
                'Sua solicitação para se tornar parceiro foi enviada com sucesso. Entraremos em contato em breve.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Botão Ir para Login
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    store.resetAllState();
                    Modular.to.navigate('/auth/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Ir para Login',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                // Logo
                Center(
                  child: SvgPicture.asset(
                    'assets/images/logo-multimidia-simple.svg',
                    width: 80.w,
                    height: 80.h,
                    semanticsLabel: 'Logo Multimídia',
                  ),
                ),
                SizedBox(height: 24.h),

                // Título
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

                // Passo 1 - Vídeo
                Text(
                  '1- Assista ao vídeo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),

                // Player de Vídeo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _isVideoInitialized
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController.value.isPlaying
                                    ? _videoController.pause()
                                    : _videoController.play();
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_videoController),
                                if (!_videoController.value.isPlaying)
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(12.w),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 48.sp,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Passo 2 - Formulário
                Text(
                  '2- Caso você tenha interesse em ser parceiro, preencha os dados abaixo. Não é obrigatório ter empresa. Entraremos em contato.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),

                // Campo Nome
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome:',
                  hintText: 'Informe seu nome',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu nome';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Campo E-mail
                CustomTextField(
                  controller: _emailController,
                  label: 'E-mail:',
                  hintText: 'Informe seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Campo Telefone
                CustomTextField(
                  controller: _phoneController,
                  label: 'Telefone:',
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

                // Campo Empresa (opcional)
                CustomTextField(
                  controller: _companyController,
                  label: 'Empresa:',
                  hintText: 'Informe sua empresa',
                ),
                SizedBox(height: 16.h),

                // Campo CNPJ (opcional)
                CustomTextField(
                  controller: _cnpjController,
                  label: 'Cnpj:',
                  hintText: 'Informe seu Cnpj',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final formatted = _formatCNPJ(value);
                    if (formatted != value) {
                      _cnpjController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Pergunta experiência
                Text(
                  'Você atua ou já atuou com vendas na área pública?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),

                // Radio buttons
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

                // Botão Enviar
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
