import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mobile_shell.dart';

class _Reminder {
  final String id;
  final String label;
  final String time;
  final IconData icon;
  bool on;
  final AppTone tone;

  _Reminder({required this.id, required this.label, required this.time, required this.icon, required this.on, required this.tone});
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminders = [
    _Reminder(id: '1', label: 'Prenatal vitamin', time: '8:00 AM', icon: LucideIcons.pill, on: true, tone: AppTone.blush),
    _Reminder(id: '2', label: 'Iron supplement', time: '1:00 PM', icon: LucideIcons.pill, on: true, tone: AppTone.peach),
    _Reminder(id: '3', label: 'Water break', time: 'Every 2h', icon: LucideIcons.droplet, on: true, tone: AppTone.sage),
    _Reminder(id: '4', label: 'Evening walk', time: '6:30 PM', icon: LucideIcons.footprints, on: false, tone: AppTone.peach),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Reminders',
      subtitle: 'Little nudges of care',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Row(
                      children: [
                        ToneIconTile(icon: r.icon, tone: r.tone, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                              Text(r.time, style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        _ReminderSwitch(
                          on: r.on,
                          onChanged: () => setState(() => r.on = !r.on),
                        ),
                      ],
                    ),
                  ),
                )),
            DottedButton(
              onTap: () {},
              icon: LucideIcons.bell,
              label: 'Add reminder',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ReminderSwitch extends StatelessWidget {
  final bool on;
  final VoidCallback onChanged;
  const _ReminderSwitch({required this.on, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

class DottedButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  const DottedButton({super.key, required this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.x2l),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.x2l),
          border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.mutedForeground),
            const SizedBox(width: 8),
            Text(label, style: sansFont(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}
