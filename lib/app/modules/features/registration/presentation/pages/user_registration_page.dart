import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../widgets/index.dart';
import '../../../../../shared/utils/email_validator.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/entities/user_registration.dart';
import '../stores/registration_store.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final RegistrationStore store;

  @override
  void initState() {
    super.initState();
    store = Modular.get<RegistrationStore>();

    if (!store.hasFoundCompany) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Modular.to.pop();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final company = store.foundCompany!;

      final registration = UserRegistration(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        cargo: 'Vendedor',
        partnerId: company.id,
      );

      await store.registerUser(registration);

      if (!mounted) return;

      if (store.registerUserSuccess) {
        _showSuccessDialog();
      } else if (store.registerUserError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(store.registerUserError!),
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

              Text(
                'Cadastro realizado!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Text(
                'Seu cadastro foi realizado com sucesso. Aguarde a ativação pelo gestor da empresa para acessar o sistema.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

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
        title: 'Cadastro',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
      ),
      body: Observer(
        builder: (_) {
          if (!store.hasFoundCompany) {
            return const Center(
              child: Text('Nenhuma empresa selecionada'),
            );
          }

          final company = store.foundCompany!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReadOnlyField('Razão social', company.legalName),
                    SizedBox(height: 8.h),
                    _buildReadOnlyField('Nome fantasia', company.tradeName),
                    SizedBox(height: 8.h),
                    _buildReadOnlyField('CNPJ', company.cnpj),
                    SizedBox(height: 8.h),
                    _buildReadOnlyField('Email', company.email),
                    SizedBox(height: 8.h),
                    _buildReadOnlyField('Telefone', company.phone),
                    SizedBox(height: 24.h),

                    Text(
                      'Informações do usuário',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail:',
                      hintText: 'Informe seu email',
                      keyboardType: TextInputType.emailAddress,
                      validator: EmailValidator.getError,
                    ),
                    SizedBox(height: 16.h),

                    CustomTextField(
                      controller: _confirmEmailController,
                      label: 'Confirmar e-mail:',
                      hintText: 'Informe seu email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme seu e-mail';
                        }
                        if (value != _emailController.text) {
                          return 'Os e-mails não coincidem';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

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
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
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
                      controller: _passwordController,
                      label: 'Senha:',
                      hintText: 'Informe a senha',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar senha:',
                      hintText: 'Confirme a senha',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),

                    Observer(
                      builder: (_) => PrimaryButton(
                        text: 'Cadastrar',
                        isLoading: store.isRegisteringUser,
                        onPressed: _submitForm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
