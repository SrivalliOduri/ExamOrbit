import 'package:flutter/material.dart';

import '../services/quote_service.dart';
import 'app_card.dart';

/// Shows a motivational quote, or its loading and error states with a retry action.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final Quote? quote;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _content(theme, scheme),
      ),
    );
  }

  Widget _content(ThemeData theme, ColorScheme scheme) {
    if (isLoading) {
      return Row(
        key: const ValueKey('loading'),
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading today\'s quote...',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }
    if (error != null) {
      return Column(
        key: const ValueKey('error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error!, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      );
    }
    final current = quote;
    return Column(
      key: ValueKey(current?.text),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.format_quote_rounded, color: scheme.secondary, size: 32),
        const SizedBox(height: 8),
        Text(
          current?.text ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Text(
          '- ${current?.author ?? ''}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
