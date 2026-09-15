import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/auth/models/onboarding_info.dart';
import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/line_text_field.dart';

/// A short, three-step "get to know you" flow shown once right after sign up.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _totalSteps = 3;
  int _step = 0;
  final _nameController = TextEditingController();
  int _week = 12;
  bool? _firstPregnancy;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _nameController.text.trim().isNotEmpty,
        1 => true,
        2 => _firstPregnancy != null,
        _ => false,
      };

  Future<void> _next() async {
    if (!_canContinue) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step += 1);
      return;
    }
    setState(() => _submitting = true);
    await AuthService.instance.completeOnboarding(OnboardingInfo(
      name: _nameController.text.trim(),
      pregnancyWeek: _week,
      firstPregnancy: _firstPregnancy!,
    ));
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradientWarm),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_step > 0)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _back,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                border: Border.all(color: AppColors.border),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.arrowLeft, size: 16),
                            ),
                          )
                        else
                          const SizedBox(width: 36, height: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 6,
                              color: AppColors.muted,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (_step + 1) / _totalSteps,
                                child: Container(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Expanded(child: _buildStep()),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.x2l),
                        onTap: (_canContinue && !_submitting) ? _next : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (_canContinue && !_submitting) ? AppColors.primary : AppColors.muted,
                            borderRadius: BorderRadius.circular(AppRadius.x2l),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground),
                                )
                              : Text(
                                  _step == _totalSteps - 1 ? "Let's begin" : 'Continue',
                                  style: sansFont(
                                    fontWeight: FontWeight.w700,
                                    color: (_canContinue && !_submitting) ? AppColors.primaryForeground : AppColors.mutedForeground,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepScaffold(
          key: const ValueKey('name'),
          eyebrow: 'Step 1 of $_totalSteps',
          title: "What's your name?",
          subtitle: "We'll use this to greet you warmly.",
          child: LineTextField(
            label: 'Your name',
            controller: _nameController,
            hintText: 'e.g. Priya',
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (_) => _next(),
            onChanged: (_) => setState(() {}),
          ),
        );
      case 1:
        return _StepScaffold(
          key: const ValueKey('week'),
          eyebrow: 'Step 2 of $_totalSteps',
          title: 'How many weeks pregnant are you?',
          subtitle: 'A rough estimate is perfectly fine.',
          child: Column(
            children: [
              Text('Week $_week', style: displayFont(fontSize: 40)),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.muted,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: _week.toDouble(),
                  min: 1,
                  max: 40,
                  divisions: 39,
                  onChanged: (v) => setState(() => _week = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Week 1', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                  Text('Week 40', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
            ],
          ),
        );
      default:
        return _StepScaffold(
          key: const ValueKey('first'),
          eyebrow: 'Step 3 of $_totalSteps',
          title: 'Is this your first pregnancy?',
          subtitle: 'This helps Aanya tailor guidance for you.',
          child: Row(
            children: [
              Expanded(
                child: _ChoiceButton(
                  label: 'Yes',
                  selected: _firstPregnancy == true,
                  onTap: () => setState(() => _firstPregnancy = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceButton(
                  label: 'No',
                  selected: _firstPregnancy == false,
                  onTap: () => setState(() => _firstPregnancy = false),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _StepScaffold extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(title, style: displayFont(fontSize: 26, height: 1.25)),
          const SizedBox(height: 6),
          Text(subtitle, style: sansFont(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.x2l),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.x2l),
        ),
        child: Text(
          label,
          style: sansFont(fontWeight: FontWeight.w700, color: selected ? AppColors.primaryForeground : AppColors.foreground),
        ),
      ),
    );
  }
}
