import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/features/community/models/community.dart';
import 'package:natal_iq/features/community/widgets/join_button.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap;

  const CommunityCard({super.key, required this.community, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tone = toneForCommunity(community.id);
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToneIconTile(icon: LucideIcons.users, tone: tone),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sansFont(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                if (community.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    community.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: sansFont(fontSize: 12, color: AppColors.mutedForeground, height: 1.4),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${community.memberCount} ${community.memberCount == 1 ? 'member' : 'members'}',
                  style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          JoinButton(communityId: community.id),
        ],
      ),
    );
  }
}
