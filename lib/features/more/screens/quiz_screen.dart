import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class _Question {
  final String id;
  final String q;
  final bool risk;
  const _Question(this.id, this.q, {this.risk = false});
}

const _questions = [
  _Question('bleed', 'Any vaginal bleeding today?', risk: true),
  _Question('pain', 'Severe abdominal pain?', risk: true),
  _Question('swell', 'Sudden swelling in hands or face?', risk: true),
  _Question('vision', 'Any blurred vision or severe headaches?', risk: true),
  _Question('kicks', 'Reduced baby movements today?', risk: true),
  _Question('nausea', 'Mild morning nausea?'),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0;
  final Map<String, bool> _answers = {};
  bool _done = false;

  void _answer(bool yes) {
    setState(() {
      _answers[_questions[_i].id] = yes;
      if (_i + 1 >= _questions.length) {
        _done = true;
      } else {
        _i += 1;
      }
    });
  }

  void _restart() {
    setState(() {
      _answers.clear();
      _i = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      final flagged = _questions.where((q) => q.risk && (_answers[q.id] ?? false)).toList();
      final showAlert = flagged.isNotEmpty;
      return MobileShell(
        title: 'Your gentle summary',
        subtitle: 'Not a diagnosis',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: showAlert ? AppColors.destructive.withValues(alpha: 0.1) : AppColors.sage.withValues(alpha: 0.4),
                  border: Border.all(color: showAlert ? AppColors.destructive.withValues(alpha: 0.4) : AppColors.sage),
                  borderRadius: BorderRadius.circular(AppRadius.x3l),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          showAlert ? LucideIcons.circleAlert : LucideIcons.circleCheckBig,
                          size: 20,
                          color: showAlert ? AppColors.destructive : AppColors.sageForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            showAlert ? 'Please contact your doctor' : 'Nothing alarming',
                            style: displayFont(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showAlert
                          ? 'Some of your answers suggest you should speak to a healthcare provider today. This tool is not a diagnosis.'
                          : "Your answers don't show urgent signs today. Keep tracking gently and reach out if anything changes.",
                      style: sansFont(fontSize: 14, color: AppColors.foreground.withValues(alpha: 0.8), height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.x2l),
                      onTap: () => context.push('/doctors'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.x2l),
                        ),
                        child: Text('Talk to a doctor', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.primaryForeground)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.x2l),
                    onTap: _restart,
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.x2l),
                      ),
                      child: const Icon(LucideIcons.rotateCcw, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_i];
    return MobileShell(
      title: 'Symptom check',
      subtitle: 'Step ${_i + 1} of ${_questions.length}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 6,
                color: AppColors.muted,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_i + 1) / _questions.length,
                  child: Container(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x3l),
                boxShadow: const [BoxShadow(color: AppColors.shadowCard, blurRadius: 12, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUESTION ${_i + 1}',
                    style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 10),
                  Text(q.q, style: displayFont(fontSize: 22, height: 1.3)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.x2l),
                          onTap: () => _answer(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(AppRadius.x2l),
                            ),
                            child: Text('No', style: sansFont(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.x2l),
                          onTap: () => _answer(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.x2l),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Yes', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.primaryForeground)),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.primaryForeground),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "This tool doesn't diagnose. It only nudges you toward care.",
              textAlign: TextAlign.center,
              style: sansFont(fontSize: 11, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
