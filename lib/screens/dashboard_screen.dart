import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../models/subject.dart';
import '../services/quote_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/quote_card.dart';
import '../widgets/stat_tile.dart';

/// Home tab: countdown to the next exam, today's plan and overall progress.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final QuoteService _quoteService = QuoteService();
  Quote? _quote;
  bool _quoteLoading = true;
  String? _quoteError;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  @override
  void dispose() {
    _quoteService.dispose();
    super.dispose();
  }

  
Future<void> _loadQuote() async {
  setState(() {
    _quoteLoading = true;
    _quoteError = null;
  });

  try {
    final quote = await _quoteService.fetchRandomQuote();

    if (!mounted) return;

    setState(() {
      _quote = quote;
      _quoteLoading = false;
      _quoteError = null;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _quoteError = null;
      _quoteLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final todayTasks = state.todayPlan.tasksOn(now);
    final topicsLeft = state.totalTopics - state.completedTopics;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _Header(greeting: _greeting(now), date: DateFormat('EEEE, d MMMM').format(now)),
                const SizedBox(height: 20),
                _CountdownCard(nextExam: state.nextExam),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.menu_book_rounded,
                        value: '${state.subjects.length}',
                        label: 'Subjects',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.checklist_rounded,
                        value: '$topicsLeft',
                        label: 'Topics left',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.today_rounded,
                        value: '${todayTasks.length}',
                        label: 'Tasks today',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _OverallProgressCard(
                  completed: state.completedTopics,
                  total: state.totalTopics,
                  progress: state.overallProgress,
                ),
                const SizedBox(height: 16),
                QuoteCard(
                  quote: _quote,
                  isLoading: _quoteLoading,
                  error: _quoteError,
                  onRetry: _loadQuote,
                ),
                const SizedBox(height: 28),
                Text(
                  "Today's study plan",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (todayTasks.isEmpty)
                  AppCard(
                    child: Text(
                      state.subjects.isEmpty
                          ? 'Add a subject to generate your study plan.'
                          : 'Nothing scheduled for today. You are all caught up!',
                    ),
                  )
                else
                  for (final task in todayTasks)
                    _TaskTile(
                      task: task,
                      onDone: () => state.toggleTopic(task.topicId),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.date});

  final String greeting;
  final String date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.nextExam});

  final Subject? nextExam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exam = nextExam;
    final days = exam == null ? 0 : daysBetween(dateOnly(DateTime.now()), exam.examDate);
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam == null ? 'No upcoming exams' : 'Next exam: ${exam.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  exam == null
                      ? 'Add a subject to start your countdown.'
                      : DateFormat.yMMMMd().format(exam.examDate),
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (exam != null) ...[
            const SizedBox(width: 16),
            Column(
              children: [
                Text(
                  days == 0 ? 'Today' : '$days',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  days == 0 ? 'exam day' : (days == 1 ? 'day left' : 'days left'),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({required this.completed, required this.total, required this.progress});

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          ProgressRing(progress: progress, size: 96, strokeWidth: 9),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall progress',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0 ? 'No topics added yet' : '$completed of $total topics completed',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onDone});

  final StudyTask task;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: CheckboxListTile(
          value: false,
          onChanged: (_) => onDone(),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(task.topicName, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${task.subjectName} - ${task.minutes} min'),
        ),
      ),
    );
  }
}
