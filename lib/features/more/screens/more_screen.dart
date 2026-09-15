import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/router/nav_helpers.dart';
import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _groups = [
    (
      label: 'Care',
      items: [
        (path: '/doctors', label: 'Doctors & experts', icon: LucideIcons.stethoscope),
        (path: '/quiz', label: 'Symptom checker', icon: LucideIcons.clipboardList),
        (path: '/reminders', label: 'Reminders', icon: LucideIcons.bell),
      ],
    ),
    (
      label: 'Support',
      items: [
        (path: '/journal', label: 'Journal', icon: LucideIcons.bookHeart),
        (path: '/community', label: 'Community', icon: LucideIcons.users),
        (path: '/caregiver', label: 'Caregiver mode', icon: LucideIcons.handHeart),
        (path: '/videos', label: 'Videos & yoga', icon: LucideIcons.video),
      ],
    ),
  ];

  Future<void> _confirmLogOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Log out?', style: displayFont(fontSize: 18)),
        content: Text("You'll need to log in again to access your account.", style: sansFont(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: sansFont(fontWeight: FontWeight.w700))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log out', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.destructive)),
          ),
        ],
      ),
    );
    if (confirmed == true) await AuthService.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final name = auth.onboarding?.name.trim().isNotEmpty == true ? auth.onboarding!.name.trim() : 'You';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'Y';

    return MobileShell(
      title: 'More',
      subtitle: 'Everything Aanya can do',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              withShadow: true,
              onTap: () => context.push('/profile'),
              child: Row(
                children: [
                  InitialAvatar(letter: initial, tone: AppTone.blush, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: sansFont(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(auth.email ?? '', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final g in _groups) ...[
              SectionLabel(g.label, padding: const EdgeInsets.only(bottom: 8)),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.x2l),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < g.items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: AppColors.border),
                      _MoreRow(
                        icon: g.items[i].icon,
                        label: g.items[i].label,
                        onTap: () => navigateTo(context, g.items[i].path),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            SectionLabel('Preferences', padding: const EdgeInsets.only(bottom: 8)),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              child: const Column(
                children: [
                  _PreferenceRow(icon: LucideIcons.globe, label: 'Language', hint: 'English'),
                  Divider(height: 1, color: AppColors.border),
                  _PreferenceRow(icon: LucideIcons.shieldCheck, label: 'Privacy', hint: 'Data stays on this device'),
                  Divider(height: 1, color: AppColors.border),
                  _PreferenceRow(icon: LucideIcons.info, label: 'About Aanya', hint: 'Guidance, not diagnosis'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionLabel('Account', padding: const EdgeInsets.only(bottom: 8)),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              child: InkWell(
                onTap: () => _confirmLogOut(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ToneIconTile(icon: LucideIcons.logOut, tone: AppTone.blush, size: 36, iconSize: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Log out', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.destructive)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aanya offers general information. For medical decisions, always consult your doctor or ASHA worker.',
                textAlign: TextAlign.center,
                style: sansFont(fontSize: 11, color: AppColors.mutedForeground, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MoreRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ToneIconTile(icon: icon, tone: AppTone.peach, size: 36, iconSize: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _PreferenceRow({required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ToneIconTile(icon: icon, tone: AppTone.sage, size: 36, iconSize: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700))),
          Text(hint, style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
