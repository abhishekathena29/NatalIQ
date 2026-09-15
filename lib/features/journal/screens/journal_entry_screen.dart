import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/journal/models/journal_entry.dart';
import 'package:natal_iq/features/journal/models/journal_insight.dart';
import 'package:natal_iq/features/journal/services/journal_insights.dart';
import 'package:natal_iq/features/journal/services/journal_storage.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';

/// Compose/edit screen for a single journal entry. When [entryId] is null
/// this creates a new entry; otherwise it loads and edits the existing one.
class JournalEntryScreen extends StatefulWidget {
  final String? entryId;
  const JournalEntryScreen({super.key, this.entryId});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  JournalMood? _mood;
  bool _loaded = false;
  bool _saving = false;
  JournalEntry? _existing;
  JournalInsight? _insight;

  bool get _isEditing => widget.entryId != null;
  bool get _canSave => _bodyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
    _bodyController.addListener(() => setState(() => _insight = null));
  }

  Future<void> _load() async {
    if (widget.entryId != null) {
      final entry = await JournalStorage.getEntry(widget.entryId!);
      if (entry != null) {
        _existing = entry;
        _titleController.text = entry.title;
        _bodyController.text = entry.body;
        _mood = entry.mood;
      }
    }
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = JournalEntry(
      id: _existing?.id ?? JournalStorage.newEntryId(),
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      mood: _mood,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );
    await JournalStorage.upsertEntry(entry);
    _existing = entry;
    if (!mounted) return;
    setState(() {
      _saving = false;
      _insight = JournalInsightsEngine.forEntry(entry);
    });
  }

  Future<void> _delete() async {
    if (_existing == null) return;
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
    if (confirmed != true || !mounted) return;
    await JournalStorage.deleteEntry(_existing!.id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradientWarm),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.6),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: !_loaded
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : _buildBody(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withValues(alpha: 0.95), AppColors.background.withValues(alpha: 0.7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.pop(),
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_isEditing ? 'Edit entry' : 'New entry', style: displayFont(fontSize: 18)),
            ),
            if (_isEditing)
              IconButton(
                onPressed: _delete,
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _insight != null ? () => context.pop() : (_canSave && !_saving ? _save : null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _insight != null || (_canSave && !_saving) ? AppColors.primary : AppColors.muted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _insight != null ? 'Done' : 'Save',
                  style: sansFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _insight != null || (_canSave && !_saving) ? AppColors.primaryForeground : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_insight != null) ...[
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToneIconTile(icon: _insight!.icon, tone: _insight!.tone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_insight!.headline, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_insight!.body, style: sansFont(fontSize: 13, color: AppColors.mutedForeground, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text('HOW ARE YOU FEELING?', style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Row(
            children: JournalMood.values.map((m) {
              final selected = _mood == m;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => _mood = selected ? null : m),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.blush : AppColors.card,
                      border: Border.all(color: selected ? AppColors.blush : AppColors.border),
                      shape: BoxShape.circle,
                    ),
                    child: Text(m.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _titleController,
            style: displayFont(fontSize: 22),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'Title (optional)',
              hintStyle: displayFont(fontSize: 22, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1.5, color: AppColors.border),
          const SizedBox(height: 20),
          TextField(
            controller: _bodyController,
            minLines: 10,
            maxLines: null,
            style: sansFont(fontSize: 15, height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: "What's on your mind today?",
              hintStyle: sansFont(fontSize: 15, color: AppColors.mutedForeground.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
