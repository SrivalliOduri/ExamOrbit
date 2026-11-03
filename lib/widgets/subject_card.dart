import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subject.dart';
import 'app_card.dart';
import 'progress_ring.dart';

/// Shared hero tag so a subject's ring animates from the list into its detail page.
String subjectRingHeroTag(String subjectId) => 'subject-ring-$subjectId';

/// List card summarising one subject: progress ring, exam date and key details.
class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Hero(
            tag: subjectRingHeroTag(subject.id),
            child: ProgressRing(progress: subject.progress, size: 72, strokeWidth: 7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 16, color: muted),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat.yMMMd().format(subject.examDate),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(subject.difficulty.label),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text('Priority ${subject.priority}/5'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: muted),
        ],
      ),
    );
  }
}
