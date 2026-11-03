import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/study_unit.dart';
import '../models/subject.dart';
import '../routes/app_routes.dart';
import '../state/app_state.dart';
import '../widgets/add_topic_dialog.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/subject_card.dart';

/// Shows a subject's overall progress and its units as expandable topic checklists.
class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final subject = context.watch<AppState>().subjectById(subjectId);
    if (subject == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This subject no longer exists.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit subject',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.subjectForm,
              arguments: subject.id,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SubjectSummary(subject: subject),
              const SizedBox(height: 24),
              Text(
                'Units',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              for (final unit in subject.units)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UnitCard(key: ValueKey(unit.id), subjectId: subject.id, unit: unit),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectSummary extends StatelessWidget {
  const _SubjectSummary({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return AppCard(
      child: Row(
        children: [
          Hero(
            tag: subjectRingHeroTag(subject.id),
            child: ProgressRing(progress: subject.progress, size: 104, strokeWidth: 10),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam on ${DateFormat.yMMMMd().format(subject.examDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  '${subject.completedTopics} of ${subject.totalTopics} topics done',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: 8),
                Text(
                  '${subject.difficulty.label} difficulty - priority ${subject.priority}/5',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({super.key, required this.subjectId, required this.unit});

  final String subjectId;
  final StudyUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<AppState>();
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: unit.completedCount < unit.topics.length,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(unit.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${unit.completedCount} of ${unit.topics.length} topics done',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: unit.progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 6),
              ),
            ],
          ),
        ),
        children: [
          if (unit.topics.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'No topics yet. Add the first one below.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          for (final topic in unit.topics)
            CheckboxListTile(
              key: ValueKey(topic.id),
              value: topic.isCompleted,
              onChanged: (_) => state.toggleTopic(topic.id),
              controlAffinity: ListTileControlAffinity.leading,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
                  decoration: topic.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: topic.isCompleted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                ),
                child: Text(topic.name),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextButton.icon(
                onPressed: () => _addTopic(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add topic'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTopic(BuildContext context) async {
    final name = await showAddTopicDialog(context);
    if (name == null || !context.mounted) return;
    context.read<AppState>().addTopic(subjectId: subjectId, unitId: unit.id, name: name);
  }
}
