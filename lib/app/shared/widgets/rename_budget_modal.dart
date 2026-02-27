import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_modal.dart';

class RenameBudgetModal extends StatefulWidget {
  final String currentName;
  final Function(String newName) onRename;

  const RenameBudgetModal({
    super.key,
    required this.currentName,
    required this.onRename,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String currentName,
    required Function(String newName) onRename,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Renomear orçamento',
      content: _RenameBudgetContent(
        currentName: currentName,
        onRename: onRename,
      ),
    );
  }

  @override
  State<RenameBudgetModal> createState() => _RenameBudgetModalState();
}

class _RenameBudgetModalState extends State<RenameBudgetModal> {
  @override
  Widget build(BuildContext context) {
    return _RenameBudgetContent(
      currentName: widget.currentName,
      onRename: widget.onRename,
    );
  }
}

class _RenameBudgetContent extends StatefulWidget {
  final String currentName;
  final Function(String newName) onRename;

  const _RenameBudgetContent({
    required this.currentName,
    required this.onRename,
  });

  @override
  State<_RenameBudgetContent> createState() => _RenameBudgetContentState();
}

class _RenameBudgetContentState extends State<_RenameBudgetContent> {
  late final TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
        Text(
          'Nome atual:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          widget.currentName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20.h),

        Text(
          'Novo nome:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 60.h,
          child: TextFormField(
            controller: _nameController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Digite o novo nome do orçamento',
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              fillColor: _isLoading ? Colors.grey[50] : null,
              filled: _isLoading,
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: _isLoading ? Colors.grey[600] : Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        SizedBox(
          width: double.infinity,
          height: 40.h,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleRename,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF56B34A),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.save,
                    size: 18.sp,
                    color: Colors.white,
                  ),
            label: Text(
              _isLoading ? 'Renomeando...' : 'Renomear',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRename() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showErrorMessage('O nome não pode estar vazio');
      return;
    }

    if (newName == widget.currentName) {
      _showErrorMessage('O novo nome deve ser diferente do atual');
      return;
    }

    if (newName.length < 3) {
      _showErrorMessage('O nome deve ter pelo menos 3 caracteres');
      return;
    }

    if (newName.length > 100) {
      _showErrorMessage('O nome deve ter no máximo 100 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onRename(newName);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento renomeado com sucesso!'),
            backgroundColor: Color(0xFF56B34A),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro ao renomear orçamento: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}