import 'package:flutter/material.dart';
import '../../core/security/security_engine.dart';
import '../../core/theme/app_colors.dart';

class SecurityBadgeWidget extends StatelessWidget {
  final SecurityAuditResult? audit;
  final VoidCallback onTap;

  const SecurityBadgeWidget({
    super.key,
    required this.audit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final verdict = audit?.verdict ?? SecurityVerdict.clean;
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (verdict) {
      case SecurityVerdict.clean:
        badgeColor = AppColors.uberGreen;
        badgeText = 'SE Secure';
        badgeIcon = Icons.shield;
        break;
      case SecurityVerdict.warning:
        badgeColor = AppColors.uberGold;
        badgeText = 'SE Warning';
        badgeIcon = Icons.shield_outlined;
        break;
      case SecurityVerdict.compromised:
        badgeColor = AppColors.uberRed;
        badgeText = 'SE Alert';
        badgeIcon = Icons.warning_amber_rounded;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badgeIcon, color: badgeColor, size: 14),
            const SizedBox(width: 5),
            Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
