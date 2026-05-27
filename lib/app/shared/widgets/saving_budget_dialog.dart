import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

class SavingBudgetDialog extends StatefulWidget {
  final Future<String?> Function() onSave;
  final void Function(String error)? onError;

  const SavingBudgetDialog._({
    required this.onSave,
    this.onError,
  });

  static Future<bool> show({
    required BuildContext context,
    required Future<String?> Function() onSave,
  }) async {
    String? capturedError;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SavingBudgetDialog._(
        onSave: onSave,
        onError: (error) => capturedError = error,
      ),
    );

    if (result != true) {
      if (capturedError != null && context.mounted) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro ao salvar',
          message: capturedError!,
        );
      }
      return false;
    }
    return true;
  }

  @override
  State<SavingBudgetDialog> createState() => _SavingBudgetDialogState();
}

class _SavingBudgetDialogState extends State<SavingBudgetDialog> {
  bool _isLoading = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _executeSave();
  }

  Future<void> _executeSave() async {
    final error = await widget.onSave();

    if (!mounted) return;

    if (error != null) {
      widget.onError?.call(error);
      Navigator.of(context).pop(false);
    } else {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();

    return _buildSuccess();
  }

  Widget _buildLoading() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF117BBD),
              strokeWidth: 3,
            ),
            SizedBox(height: 20.h),
            Text(
              'Salvando orçamento...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Aguarde enquanto salvamos suas alterações',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFF56B34A),
                size: 36.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Orçamento salvo!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Orçamento salvo com sucesso!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56B34A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Entendi',
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
    );
  }
}
