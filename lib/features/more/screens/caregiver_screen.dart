import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class CaregiverScreen extends StatelessWidget {
  const CaregiverScreen({super.key});

  static const _tips = [
    (
      icon: LucideIcons.calendar,
      title: 'Week 22 · What to expect',
      body: 'She may feel back aches and mild swelling. Offer to help with chores that involve standing long.',
    ),
    (
      icon: LucideIcons.messageCircleHeart,
      title: "Ask, don't assume",
      body: 'Check in about her energy and mood daily. Small conversations mean a lot.',
    ),
    (
      icon: LucideIcons.triangleAlert,
      title: 'Warning signs to know',
      body: 'Severe headaches, blurred vision, sudden swelling, heavy bleeding — call the doctor immediately.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Caregiver mode',
      subtitle: 'Supporting her, gently',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x3l),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.blush.withValues(alpha: 0.5), AppColors.peach.withValues(alpha: 0.6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.handHeart, size: 32, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text("You're part of her journey. Here's how you can help this week.", style: displayFont(fontSize: 20, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.x2l),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(AppRadius.lg)),
                          child: Icon(t.icon, size: 20, color: AppColors.sageForeground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(t.body, style: sansFont(fontSize: 12, color: AppColors.mutedForeground, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.x2l),
              onTap: () => context.go('/chat'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.x2l)),
                child: Text('Ask Aanya as a caregiver', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.primaryForeground)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
