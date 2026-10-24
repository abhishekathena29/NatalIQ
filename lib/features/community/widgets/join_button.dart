import 'package:flutter/material.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/features/community/services/community_service.dart';

/// Small Join / Joined toggle button backed by
/// [CommunityService.watchIsMember]/[CommunityService.toggleMembership].
class JoinButton extends StatefulWidget {
  final String communityId;
  const JoinButton({super.key, required this.communityId});

  @override
  State<JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<JoinButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await CommunityService.toggleMembership(widget.communityId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: CommunityService.watchIsMember(widget.communityId),
      builder: (context, snapshot) {
        final joined = snapshot.data ?? false;
        return SizedBox(
          height: 32,
          child: joined
              ? OutlinedButton(
                  onPressed: _busy ? null : _toggle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Joined', style: sansFont(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                )
              : ElevatedButton(
                  onPressed: _busy ? null : _toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Join', style: sansFont(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
        );
      },
    );
  }
}
