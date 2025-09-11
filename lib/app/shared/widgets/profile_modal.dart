import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileModal extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userDocument; // CPF ou CNPJ
  final String? userImageUrl;
  final VoidCallback onClose;
  final VoidCallback? onEditProfile;
  final VoidCallback? onConfigureProducts;
  final VoidCallback? onPartnerProspecting;
  final VoidCallback? onAdministrativeManagement;
  final VoidCallback? onWiki;
  final VoidCallback? onDrive;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  const ProfileModal({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userDocument,
    this.userImageUrl,
    required this.onClose,
    this.onEditProfile,
    this.onConfigureProducts,
    this.onPartnerProspecting,
    this.onAdministrativeManagement,
    this.onWiki,
    this.onDrive,
    this.onLogout,
    this.onDeleteAccount,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeModal() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: GestureDetector(
            onTap: _closeModal,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Header com botão fechar
                            Container(
                              padding: EdgeInsets.only(
                                top: 16.h,
                                right: 16.w,
                              ),
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _closeModal,
                                child: Icon(
                                  Icons.close,
                                  size: 24.sp,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                            ),

                            SizedBox(height: 40.h),

                            // Foto do perfil
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF117BBD),
                                image: widget.userImageUrl != null
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(widget.userImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: widget.userImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 60.sp,
                                    )
                                  : null,
                            ),

                            SizedBox(height: 24.h),

                            // Nome do usuário
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                widget.userName,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // Email do usuário
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                widget.userEmail,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // CPF/CNPJ
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                widget.userDocument,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 40.h),

                            // Menu items
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                children: [
                                  _ProfileMenuItem(
                                    icon: Icons.edit,
                                    title: 'Editar perfil',
                                    onTap: widget.onEditProfile,
                                  ),
                                  SizedBox(height: 12.h),
                                  _ProfileMenuItem(
                                    icon: Icons.inventory,
                                    title: 'Configurar produtos',
                                    onTap: widget.onConfigureProducts,
                                  ),
                                  SizedBox(height: 12.h),
                                  _ProfileMenuItem(
                                    icon: Icons.people,
                                    title: 'Prospecção de parceiros',
                                    onTap: widget.onPartnerProspecting,
                                  ),
                                  SizedBox(height: 12.h),
                                  _ProfileMenuItem(
                                    icon: Icons.admin_panel_settings,
                                    title: 'Gestão administrativa',
                                    onTap: widget.onAdministrativeManagement,
                                  ),
                                  SizedBox(height: 12.h),
                                  _ProfileMenuItem(
                                    icon: Icons.menu_book,
                                    title: 'Wiki',
                                    onTap: widget.onWiki,
                                  ),
                                  SizedBox(height: 12.h),
                                  _ProfileMenuItem(
                                    icon: Icons.cloud,
                                    title: 'Drive',
                                    onTap: widget.onDrive,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 40.h),

                            // Botões de ação
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                children: [
                                  // Botão Sair
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: widget.onLogout,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE55353),
                                        foregroundColor:
                                            const Color(0xFFFFFFFF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.h),
                                      ),
                                      child: Text(
                                        'Sair',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  // Botão Deletar conta
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: widget.onDeleteAccount,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF8D8D8D),
                                        side: const BorderSide(
                                          color: Color(0xFF8D8D8D),
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.h),
                                      ),
                                      child: Text(
                                        'Deletar conta',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFBBBBBB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: const Color(0xFF000000),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
