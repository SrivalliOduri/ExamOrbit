import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';

/// Theme, daily study time and data reset options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    final hours = context.read<AppState>().settings.dailyStudyHours;
    _hoursController = TextEditingController(text: hours.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  void _saveHours() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().setDailyHours(double.parse(_hoursController.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily study time saved')),
    );
  }

  Future<void> _confirmReset() async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently clears all subjects, topics and progress on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<AppState>().resetAll();
    _hoursController.text = context.read<AppState>().settings.dailyStudyHours.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data has been reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = context.watch<AppState>().settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionTitle('Appearance'),
              AppCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Dark mode'),
                  subtitle: const Text('Easier on the eyes at night'),
                  value: settings.isDarkMode,
                  onChanged: (value) => context.read<AppState>().setDarkMode(value),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Study plan'),
              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _hoursController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Study hours per day',
                          helperText: 'Your daily plan is fitted to this amount of time.',
                        ),
                        validator: Validators.studyHours,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _saveHours, child: const Text('Save hours')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Data'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset everything',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remove all subjects, topics and settings from this device.',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _confirmReset,
                      style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Reset data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
