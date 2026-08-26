import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mobile_shell.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  static const _doctors = [
    (name: 'Dr. Ananya Rao', role: 'OB-GYN · 12 yrs', rating: 4.9, fee: '₹500'),
    (name: 'Dr. Meera Iyer', role: 'Nutritionist · 8 yrs', rating: 4.8, fee: '₹300'),
    (name: 'Dr. Sarita Deshmukh', role: 'Fetal medicine · 15 yrs', rating: 5.0, fee: '₹800'),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Doctors',
      subtitle: 'Verified & available today',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _doctors.map((d) {
            final initial = d.name.split(' ')[1][0];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InitialAvatar(letter: initial, tone: AppTone.blush, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(d.name, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.badgeCheck, size: 16, color: AppColors.primary),
                                ],
                              ),
                              Text(d.role, style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(LucideIcons.star, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text('${d.rating}', style: sansFont(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Text('${d.fee} / consult', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: LucideIcons.video,
                            label: 'Video',
                            filled: true,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon: LucideIcons.messageCircle,
                            label: 'Chat',
                            filled: false,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.background,
          border: filled ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? AppColors.primaryForeground : AppColors.foreground),
            const SizedBox(width: 6),
            Text(label, style: sansFont(fontSize: 13, fontWeight: FontWeight.w700, color: filled ? AppColors.primaryForeground : AppColors.foreground)),
          ],
        ),
      ),
    );
  }
}
