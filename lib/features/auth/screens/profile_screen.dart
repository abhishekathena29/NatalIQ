import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final onboarding = auth.onboarding;
    final name = onboarding?.name ?? 'You';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'Y';

    return MobileShell(
      title: 'Profile',
      subtitle: 'Your account details',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              withShadow: true,
              child: Row(
                children: [
                  InitialAvatar(letter: initial, tone: AppTone.blush, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: displayFont(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(auth.email ?? '', style: sansFont(fontSize: 13, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionLabel('Pregnancy', padding: const EdgeInsets.only(bottom: 8)),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              child: Column(
                children: [
                  _InfoRow(icon: LucideIcons.calendarHeart, label: 'Current week', value: onboarding != null ? 'Week ${onboarding.pregnancyWeek}' : '—'),
                  const Divider(height: 1, color: AppColors.border),
                  _InfoRow(
                    icon: LucideIcons.sparkles,
                    label: 'First pregnancy',
                    value: onboarding == null ? '—' : (onboarding.firstPregnancy ? 'Yes' : 'No'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ToneIconTile(icon: icon, tone: AppTone.sage, size: 36, iconSize: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700))),
          Text(value, style: sansFont(fontSize: 13, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
