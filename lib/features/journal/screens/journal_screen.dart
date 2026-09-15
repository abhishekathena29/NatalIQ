import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/journal/models/journal_entry.dart';
import 'package:natal_iq/features/journal/services/journal_insights.dart';
import 'package:natal_iq/features/journal/services/journal_storage.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await JournalStorage.loadEntries();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  Future<void> _openNew() async {
    await context.push('/journal/new');
    _load();
  }

  Future<void> _openEntry(String id) async {
    await context.push('/journal/$id');
    _load();
  }

  Future<void> _delete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete entry?', style: displayFont(fontSize: 18)),
        content: Text('This journal entry will be permanently removed.', style: sansFont(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: sansFont(fontWeight: FontWeight.w700))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.destructive)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await JournalStorage.deleteEntry(entry.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Journal',
      subtitle: 'Your private space to reflect',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.x2l),
              onTap: _openNew,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.x2l),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.sage.withValues(alpha: 0.5), AppColors.peach.withValues(alpha: 0.5)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.penLine, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Write today\'s entry', style: displayFont(fontSize: 17)),
                          const SizedBox(height: 2),
                          Text('A few lines are enough', style: sansFont(fontSize: 12, color: AppColors.foreground.withValues(alpha: 0.65))),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.arrowRight, size: 18, color: AppColors.foreground),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_entries != null && _entries!.isNotEmpty) ...[
              Builder(builder: (context) {
                final insight = JournalInsightsEngine.weeklyReflection(_entries!);
                if (insight == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ToneIconTile(icon: insight.icon, tone: insight.tone),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel("This week's reflection"),
                              const SizedBox(height: 4),
                              Text(insight.headline, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(insight.body, style: sansFont(fontSize: 13, color: AppColors.mutedForeground, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (_entries == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_entries!.isEmpty)
              _EmptyState(onTap: _openNew)
            else ...[
              SectionLabel('Past entries', padding: const EdgeInsets.only(bottom: 12)),
              ..._entries!.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _delete(e);
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
                        onTap: () => _openEntry(e.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (e.mood != null) ...[
                                  Text(e.mood!.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    e.title.isNotEmpty ? e.title : 'Untitled entry',
                                    style: sansFont(fontSize: 14, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(_formatDate(e.updatedAt), style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                            if (e.body.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                e.body.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: sansFont(fontSize: 13, color: AppColors.mutedForeground, height: 1.4),
                              ),
                            ],
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

  static String _formatDate(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('MMM d').format(date);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(AppRadius.x2l)),
            child: const Icon(LucideIcons.bookHeart, size: 28, color: AppColors.blushForeground),
          ),
          const SizedBox(height: 16),
          Text('No entries yet', style: displayFont(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            'Jot down how you feel today — it only takes a minute.',
            textAlign: TextAlign.center,
            style: sansFont(fontSize: 13, color: AppColors.mutedForeground, height: 1.5),
          ),
        ],
      ),
    );
  }
}
