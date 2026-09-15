import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';

class _NavTab {
  final String path;
  final String label;
  final IconData icon;
  const _NavTab(this.path, this.label, this.icon);
}

const _tabs = [
  _NavTab('/', 'Home', LucideIcons.house),
  _NavTab('/chat', 'Chat', LucideIcons.messageCircleHeart),
  _NavTab('/track', 'Track', LucideIcons.heartPulse),
  _NavTab('/community', 'Community', LucideIcons.users),
  _NavTab('/more', 'More', LucideIcons.menu),
];

/// Port of `src/components/MobileShell.tsx` — the phone-width app frame with
/// an optional header and the floating pill bottom-navigation bar.
class MobileShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool hideNav;
  final Widget? floatingActionButton;

  const MobileShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.hideNav = false,
    this.floatingActionButton,
  });

  bool _isActive(String location, String path) {
    if (path == '/') return location == '/';
    return location == path || location.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradientWarm),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.6),
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (title != null) _Header(title: title!, subtitle: subtitle),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: hideNav ? 0 : 96),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                  if (!hideNav)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _BottomNav(
                        location: location,
                        isActive: _isActive,
                      ),
                    ),
                  if (floatingActionButton != null)
                    Positioned(
                      right: 20,
                      // Clears the floating bottom-nav pill (height ~56px + its
                      // own 12px offset) when the nav is visible.
                      bottom: hideNav ? 20 : 88,
                      child: floatingActionButton!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _Header({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canPop) ...[
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(top: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.arrowLeft, size: 16),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: displayFont(fontSize: 24, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: sansFont(fontSize: 13, color: AppColors.mutedForeground)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String location;
  final bool Function(String location, String path) isActive;
  const _BottomNav({required this.location, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.95),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _tabs.map((t) {
              final active = isActive(location, t.path);
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (!active) context.go(t.path);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          t.icon,
                          size: 16,
                          color: active ? AppColors.primaryForeground : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.label,
                          style: sansFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: active ? AppColors.primaryForeground : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
