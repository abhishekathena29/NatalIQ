import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/nap/models/nap_session.dart';
import 'package:natal_iq/features/nap/services/nap_storage.dart';
import 'package:natal_iq/features/nap/services/nap_timer_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class NapScreen extends StatefulWidget {
  const NapScreen({super.key});

  @override
  State<NapScreen> createState() => _NapScreenState();
}

class _NapScreenState extends State<NapScreen> {
  final _timer = NapTimerService.instance;
  Timer? _ticker;
  List<NapSession>? _history;

  @override
  void initState() {
    super.initState();
    _timer.addListener(_onTimerChanged);
    _loadHistory();
    _syncTicker();
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerChanged);
    _ticker?.cancel();
    super.dispose();
  }

  void _onTimerChanged() {
    if (!mounted) return;
    setState(() {});
    _syncTicker();
    _loadHistory();
  }

  void _syncTicker() {
    final shouldTick = _timer.isRunning;
    if (shouldTick && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!shouldTick && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  Future<void> _loadHistory() async {
    final sessions = await NapStorage.loadSessions();
    if (!mounted) return;
    setState(() => _history = sessions);
  }

  Future<void> _delete(NapSession session) async {
    await NapStorage.deleteSession(session.id);
    _loadHistory();
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _timer.isRunning;

    return MobileShell(
      title: 'Nap timer',
      subtitle: isRunning ? 'Currently napping' : 'Track a nap, start to finish',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              withShadow: true,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isRunning ? AppColors.sage : AppColors.blush,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.moon,
                      size: 32,
                      color: isRunning ? AppColors.sageForeground : AppColors.blushForeground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formatDuration(isRunning ? _timer.elapsed : Duration.zero),
                    style: displayFont(fontSize: 44, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRunning ? 'Since ${DateFormat('h:mm a').format(_timer.running!.startTime)}' : 'Not napping right now',
                    style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.x2l),
                      onTap: isRunning ? _timer.stop : _timer.start,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isRunning ? AppColors.destructive : AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.x2l),
                          boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
                        ),
                        child: Text(
                          isRunning ? 'Stop nap' : 'Start nap',
                          style: sansFont(fontWeight: FontWeight.w700, color: AppColors.primaryForeground),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionLabel('Nap history', padding: const EdgeInsets.only(bottom: 12)),
            if (_history == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_history!.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Text(
                  'No naps logged yet — start the timer above.',
                  textAlign: TextAlign.center,
                  style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                ),
              )
            else ...[
              ..._history!.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _delete(s);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.x2l),
                        ),
                        child: const Icon(LucideIcons.trash2, color: AppColors.destructive, size: 18),
                      ),
                      child: AppCard(
                        child: Row(
                          children: [
                            const ToneIconTile(icon: LucideIcons.moon, tone: AppTone.sage),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('MMM d, h:mm a').format(s.startTime), style: sansFont(fontSize: 13, fontWeight: FontWeight.w700)),
                                  Text('Duration: ${_formatDuration(s.duration)}', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
