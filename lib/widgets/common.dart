import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// `rounded-2xl border border-border bg-card p-4` card shell reused across
/// most screens (Track, Community, Doctors, Reminders, Caregiver…).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool withShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.withShadow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        border: Border.all(color: AppColors.border),
        boxShadow: withShadow
            ? const [BoxShadow(color: AppColors.shadowCard, blurRadius: 12, offset: Offset(0, 2))]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// `text-xs uppercase tracking-widest text-muted-foreground font-semibold`
/// section eyebrow label.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  const SectionLabel(this.text, {super.key, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: sansFont(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedForeground,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// A tinted rounded-xl icon tile, e.g. the tone-colored icon squares used on
/// Home, Learn, Track and Reminders.
class ToneIconTile extends StatelessWidget {
  final IconData icon;
  final AppTone tone;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;

  const ToneIconTile({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, size: iconSize, color: tone.foreground),
    );
  }
}

/// Circular avatar with an initial letter, used for people (author/doctor
/// initials, the greeting avatar on Home).
class InitialAvatar extends StatelessWidget {
  final String letter;
  final AppTone tone;
  final double size;

  const InitialAvatar({super.key, required this.letter, required this.tone, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tone.background, shape: BoxShape.circle),
      child: Text(
        letter,
        style: sansFont(fontWeight: FontWeight.w700, color: tone.foreground, fontSize: size * 0.4),
      ),
    );
  }
}
