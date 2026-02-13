import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multimidiaapp/app/shared/utils/document_validators.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

import '../../../../../../theme/app_theme.dart';
import '../../../../../../widgets/index.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/registration_store.dart';

class CnpjSearchPage extends StatefulWidget {
  const CnpjSearchPage({super.key});

  @override
  State<CnpjSearchPage> createState() => _CnpjSearchPageState();
}

class _CnpjSearchPageState extends State<CnpjSearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();

  late final RegistrationStore store;

  @override
  void initState() {
    super.initState();
    store = Modular.get<RegistrationStore>();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  String _formatDocument(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.length > 14) {
      value = value.substring(0, 14);
    }

    if (value.length <= 11) {
      return _formatAsCPF(value);
    }
    return _formatAsCNPJ(value);
  }

  String _formatAsCPF(String value) {
    if (value.length > 3) {
      value = '${value.substring(0, 3)}.${value.substring(3)}';
    }
    if (value.length > 7) {
      value = '${value.substring(0, 7)}.${value.substring(7)}';
    }
    if (value.length > 11) {
      value = '${value.substring(0, 11)}-${value.substring(11)}';
    }
    return value;
  }

  String _formatAsCNPJ(String value) {
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

  void _searchDocument() async {
    if (_formKey.currentState?.validate() ?? false) {
      final digits = _documentController.text.replaceAll(RegExp(r'[^0-9]'), '');

      final error = DocumentValidators.getDocumentError(digits);
      if (error != null) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.warning,
          title: 'Documento inválido',
          message: error,
        );
        return;
      }

      await store.verifyDocument(_documentController.text);

      if (!mounted) return;

      if (store.hasFoundCompany) {
        _showConfirmationDialog();
      } else if (store.verifyError != null) {
        _showNotFoundDialog();
      }
    }
  }

  void _showConfirmationDialog() {
    final company = store.foundCompany!;

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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business,
                  size: 40.w,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                company.legalName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              Text(
                'A empresa ${company.tradeName.isNotEmpty ? company.tradeName : company.legalName} está correta?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _documentController.clear();
                          store.clearVerifyState();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(
                            color: Colors.red[700]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Não',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Modular.to.pushNamed('./user-registration');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Sim',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotFoundDialog() {
    showDialog(
      context: context,
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 40.w,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Documento não encontrado',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Text(
                'O documento informado não foi encontrado em nossa base de dados.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Tentar novamente',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Modular.to.pushNamed('./partner-request');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Ser parceiro',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    'assets/images/undraw_agreement_re_d4dv.svg',
                    width: 180.w,
                    height: 180.h,
                  ),
                ),
                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                      size: 28.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Pesquise a sua empresa',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                CustomTextField(
                  controller: _documentController,
                  label: 'CPF ou CNPJ:',
                  hintText: 'Informe seu CPF ou CNPJ',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final formatted = _formatDocument(value);
                    if (formatted != value) {
                      _documentController.value = TextEditingValue(
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

                Observer(
                  builder: (_) => PrimaryButton(
                    text: 'Próximo',
                    isLoading: store.isVerifyingDocument,
                    onPressed: _searchDocument,
                  ),
                ),
                SizedBox(height: 16.h),

                SecondaryButton(
                  text: 'Quero me tornar um parceiro',
                  onPressed: () {
                    Modular.to.pushNamed('./partner-request');
                  },
                ),

                Observer(
                  builder: (_) {
                    if (store.verifyError != null &&
                        !store.verifyError!.contains('não encontrad')) {
                      return Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Text(
                          store.verifyError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
