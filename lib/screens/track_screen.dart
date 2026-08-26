import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mobile_shell.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackState {
  int water;
  String? mood;
  int steps;
  int sleep;
  int kicks;

  _TrackState({required this.water, required this.mood, required this.steps, required this.sleep, required this.kicks});

  Map<String, dynamic> toJson() => {'water': water, 'mood': mood, 'steps': steps, 'sleep': sleep, 'kicks': kicks};

  factory _TrackState.fromJson(Map<String, dynamic> json) => _TrackState(
        water: json['water'] as int,
        mood: json['mood'] as String?,
        steps: json['steps'] as int,
        sleep: json['sleep'] as int,
        kicks: json['kicks'] as int,
      );
}

class _TrackScreenState extends State<TrackScreen> {
  static const _key = 'aanya.track.v1';
  var _s = _TrackState(water: 4, mood: 'Great', steps: 3200, sleep: 7, kicks: 8);

  static const _moods = [
    (label: 'Great', icon: LucideIcons.smile, tone: AppTone.sage),
    (label: 'Okay', icon: LucideIcons.meh, tone: AppTone.peach),
    (label: 'Low', icon: LucideIcons.frown, tone: AppTone.blush),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      setState(() => _s = _TrackState.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_s.toJson()));
  }

  void _update(void Function() mutate) {
    setState(mutate);
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Today',
      subtitle: 'A gentle check-in with yourself',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Water.
            AppCard(
              withShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const ToneIconTile(icon: LucideIcons.droplet, tone: AppTone.sage),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Water', style: sansFont(fontWeight: FontWeight.w700)),
                              Text('Goal: 8 glasses', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _RoundIconButton(
                            icon: LucideIcons.minus,
                            onTap: () => _update(() => _s.water = (_s.water - 1).clamp(0, 12)),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('${_s.water}', textAlign: TextAlign.center, style: displayFont(fontSize: 20)),
                          ),
                          _RoundIconButton(
                            icon: LucideIcons.plus,
                            filled: true,
                            onTap: () => _update(() => _s.water = (_s.water + 1).clamp(0, 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(8, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i == 7 ? 0 : 6),
                          height: 8,
                          decoration: BoxDecoration(
                            color: i < _s.water ? AppColors.sage : AppColors.muted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mood.
            AppCard(
              withShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you feeling?', style: sansFont(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: _moods.map((m) {
                      final active = _s.mood == m.label;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: m == _moods.last ? 0 : 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.x2l),
                            onTap: () => _update(() => _s.mood = m.label),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: active ? AppColors.blush : AppColors.background,
                                border: Border.all(color: active ? AppColors.blush : AppColors.border),
                                borderRadius: BorderRadius.circular(AppRadius.x2l),
                              ),
                              child: Column(
                                children: [
                                  Icon(m.icon, size: 20, color: active ? AppColors.blushForeground : AppColors.foreground),
                                  const SizedBox(height: 6),
                                  Text(m.label, style: sansFont(fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.blushForeground : AppColors.foreground)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppCard(
                    withShadow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(LucideIcons.footprints, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(child: SectionLabel('Steps')),
                        ]),
                        const SizedBox(height: 6),
                        Text(_formatNumber(_s.steps), style: displayFont(fontSize: 22)),
                        Text('Gentle walk today', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    withShadow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(LucideIcons.moon, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(child: SectionLabel('Sleep')),
                        ]),
                        const SizedBox(height: 6),
                        Text('${_s.sleep}h', style: displayFont(fontSize: 22)),
                        Text('Rest is medicine', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baby kicks.
            AppCard(
              withShadow: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const ToneIconTile(icon: LucideIcons.heart, tone: AppTone.blush),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Baby kicks', style: sansFont(fontWeight: FontWeight.w700)),
                          Text('Aim for 10 in 2 hours', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 40, child: Text('${_s.kicks}', textAlign: TextAlign.center, style: displayFont(fontSize: 22))),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: LucideIcons.plus,
                        filled: true,
                        tone: AppTone.blush,
                        size: 36,
                        onTap: () => _update(() => _s.kicks += 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final AppTone? tone;
  final double size;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.tone,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? (tone?.background ?? AppColors.primary) : Colors.transparent;
    final fg = filled ? (tone?.foreground ?? AppColors.primaryForeground) : AppColors.foreground;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: size * 0.44, color: fg),
      ),
    );
  }
}
