import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../localization/app_language.dart';
import '../../models/global_state.dart';
import '../../services/in_app_purchase_service.dart';
import '../../theme/app_theme.dart';

class PatiPlusSheet {
  static void show(BuildContext context) {
    final appLang = AppLanguage.of(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: EdgeInsets.only(
                top: 16.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Top Badge & Title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(11.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE67E22).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PatiPlus',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFF39C12), Color(0xFFE67E22)]),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            appLang.translate('support_dev_subtitle'),
                            style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Transparent Ethical Declaration Box
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 22),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLang.translate('support_dev_transparency_title'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              appLang.translate('support_dev_transparency_desc'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade700,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  appLang.translate('support_dev_options_title'),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  appLang.translate('support_dev_options_sub'),
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                ),

                SizedBox(height: 14.h),

                if (GlobalState.isPatiPlus) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: Colors.amber, size: 28),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PatiPlus PRO Üyeliğiniz Aktif! ✨',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5.sp),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Reklamsız deneyim ve beklemesiz PDF pasaport desteği aktif.',
                                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Option 1: Bir Kahve Ismarla (Küçük Geliştirici Desteği)
                _buildOptionCard(
                  ctx: ctx,
                  icon: Icons.coffee_rounded,
                  iconColor: const Color(0xFFD35400),
                  bgColor: const Color(0xFFFFFDF9),
                  borderColor: const Color(0xFFEDBB99),
                  title: appLang.translate('support_dev_coffee'),
                  subtitle: appLang.translate('support_dev_coffee_sub'),
                  priceBadge: appLang.priceCoffee,
                  onTap: () {
                    InAppPurchaseService.buyCoffee(
                      context,
                      onSuccess: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF2E7D32),
                              content: Text(appLang.translate('support_coffee_thank_you')),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),

                SizedBox(height: 12.h),

                // Option 2: PatiPlus Destekçi Rozeti (Featured Luxury Card)
                _buildOptionCard(
                  ctx: ctx,
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFB78103),
                  bgColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFF59E0B),
                  title: appLang.translate('support_dev_plus'),
                  subtitle: appLang.translate('support_dev_plus_sub'),
                  priceBadge: appLang.pricePatiPlus,
                  isHighlighted: true,
                  badgeLabel: 'EN POPÜLER',
                  onTap: () {
                    InAppPurchaseService.buyPatiPlus(
                      context,
                      onSuccess: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF1B5E20),
                              content: Text(appLang.translate('support_plus_thank_you')),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Option 3: Ücretsiz Devam Et / Geri Yükle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: () => InAppPurchaseService.restorePurchases(context),
                        child: Text(
                          appLang.translateDynamic('Satın Alımları Geri Yükle'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          appLang.translate('support_dev_continue_free'),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  },
    );
  }

  static Widget _buildOptionCard({
    required BuildContext ctx,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String priceBadge,
    required VoidCallback onTap,
    bool isHighlighted = false,
    String? badgeLabel,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: borderColor,
            width: isHighlighted ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isHighlighted)
              BoxShadow(
                color: borderColor.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: isHighlighted ? const Color(0xFFFEF3C7) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (badgeLabel != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(color: Colors.white, fontSize: 8.5.sp, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight, height: 1.25),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                gradient: isHighlighted
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isHighlighted ? null : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isHighlighted ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: [
                  if (isHighlighted)
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                priceBadge,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : AppTheme.textDark,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
