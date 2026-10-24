import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/community/services/community_service.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final id = await CommunityService.createCommunity(
        name: name,
        description: _descController.text.trim(),
      );
      if (!mounted) return;
      context.pushReplacement('/community/$id');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't create this community right now. Please try again.";
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'New community',
      subtitle: 'Start a space for your people',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel('Name', padding: const EdgeInsets.only(bottom: 6)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 40,
                style: sansFont(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  hintText: 'e.g. First-Time Moms, Twin Pregnancies…',
                  hintStyle: sansFont(fontSize: 14, color: AppColors.mutedForeground),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionLabel('Description', padding: const EdgeInsets.only(bottom: 6)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _descController,
                minLines: 3,
                maxLines: 6,
                maxLength: 160,
                style: sansFont(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'What is this community about?',
                  hintStyle: sansFont(fontSize: 14, color: AppColors.mutedForeground),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: sansFont(fontSize: 12, color: AppColors.destructive)),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.x2l)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground),
                      )
                    : Text('Create community', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
