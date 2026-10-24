import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/learn/models/learn_module.dart';
import 'package:natal_iq/features/learn/services/learn_content_service.dart';

/// Lists the lessons inside one Learn module (e.g. Nutrition & Diet).
class LearnModuleScreen extends StatelessWidget {
  final String moduleId;
  const LearnModuleScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearnModule?>(
      future: LearnContentService.loadModule(moduleId),
      builder: (context, snapshot) {
        final module = snapshot.data;
        return MobileShell(
          title: module?.title ?? 'Learn',
          subtitle: module != null ? '${module.lessons.length} lessons' : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: module == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: module.lessons
                        .map((lesson) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                onTap: () => context.push('/learn/$moduleId/${lesson.id}'),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.blush,
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                      ),
                                      child: Text(
                                        '${lesson.number}',
                                        style: sansFont(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blushForeground),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        lesson.title,
                                        style: sansFont(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        );
      },
    );
  }
}
