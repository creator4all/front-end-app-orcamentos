import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/prospect_entity.dart';

/// Widget de card para exibir informações de um prospect
class ProspectCardWidget extends StatelessWidget {
  final ProspectEntity prospect;
  final bool showContactButton;
  final bool isMarkingContacted;
  final VoidCallback? onMarkContacted;

  const ProspectCardWidget({
    super.key,
    required this.prospect,
    this.showContactButton = true,
    this.isMarkingContacted = false,
    this.onMarkContacted,
  });

  /// Abre o WhatsApp com o número do prospect
  Future<void> _openWhatsApp(BuildContext context) async {
    final cleanNumber = prospect.telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = Uri.parse('https://wa.me/55$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Abre o cliente de e-mail com o endereço do prospect
  Future<void> _openEmail(BuildContext context) async {
    final emailUrl = Uri.parse('mailto:${prospect.email}');

    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o cliente de e-mail'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir e-mail: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data de cadastro
            _buildDateHeader(),

            SizedBox(height: 12.h),

            // Nome do prospect
            Text(
              prospect.nome,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 12.h),

            // Informações do prospect
            _buildInfoRow('Nome Empresa:', prospect.empresa),
            SizedBox(height: 6.h),
            _buildInfoRow('Já atuou?:', prospect.experiencia.label),
            SizedBox(height: 6.h),
            _buildInfoRow('Telefone:', prospect.telefoneFormatado),
            SizedBox(height: 6.h),
            _buildInfoRow('Cnpj:', prospect.documentoFormatado),

            SizedBox(height: 16.h),

            // Botões de ação
            Row(
              children: [
                // Botão WhatsApp
                Expanded(
                  child: _buildActionButton(
                    label: 'Whatsapp',
                    icon: Icons.phone,
                    color: const Color(0xFF25D366),
                    onPressed: () => _openWhatsApp(context),
                  ),
                ),

                SizedBox(width: 12.w),

                // Botão E-mail
                Expanded(
                  child: _buildActionButton(
                    label: 'E-mail',
                    icon: Icons.mail_outline,
                    color: const Color(0xFF0E3562),
                    onPressed: () => _openEmail(context),
                  ),
                ),
              ],
            ),

            // Botão "Já entrei em contato" (apenas se showContactButton = true)
            if (showContactButton) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isMarkingContacted ? null : onMarkContacted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    disabledBackgroundColor:
                        const Color(0xFFD32F2F).withOpacity(0.6),
                  ),
                  child: isMarkingContacted
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Já entrei em contato',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14.sp,
            color: const Color(0xFF666666),
          ),
          SizedBox(width: 4.w),
          Text(
            'Data de cadastro: ${dateFormat.format(prospect.createdAt)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
