import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/community/models/community.dart';
import 'package:natal_iq/features/community/services/community_service.dart';
import 'package:natal_iq/features/community/widgets/community_card.dart';

/// Communities hub — browse, join, or create a community. Tapping one opens
/// its own post feed.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    CommunityService.ensureGeneralCommunityExists();
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Community',
      subtitle: 'Find your people',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.4),
                border: Border.all(color: AppColors.sage),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.sageForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Join a community to follow it, or start your own — be kind, this is peer support, not medical advice.',
                      style: sansFont(fontSize: 12, color: AppColors.sageForeground),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Community>>(
              stream: CommunityService.watchCommunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final communities = snapshot.data ?? const <Community>[];
                if (communities.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No communities yet. Start the first one.',
                        textAlign: TextAlign.center,
                        style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                      ),
                    ),
                  );
                }
                return Column(
                  children: communities
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CommunityCard(
                              community: c,
                              onTap: () => context.push('/community/${c.id}'),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
