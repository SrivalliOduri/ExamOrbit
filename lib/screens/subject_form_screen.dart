import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/difficulty.dart';
import '../models/study_unit.dart';
import '../models/subject.dart';
import '../state/app_state.dart';
import '../utils/date_helpers.dart';
import '../utils/id_generator.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';

/// Create or edit a subject. Edits keep existing units and topics intact.
class SubjectFormScreen extends StatefulWidget {
  const SubjectFormScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController();
  final _dateController = TextEditingController();
  late final Subject? _existing;
  DateTime? _examDate;
  Difficulty _difficulty = Difficulty.medium;
  int _priority = 3;

  int get _minimumUnits => _existing?.units.length ?? 1;

  @override
  void initState() {
    super.initState();
    final id = widget.subjectId;
    final existing = id == null ? null : context.read<AppState>().subjectById(id);
    _existing = existing;
    if (existing == null) return;
    _nameController.text = existing.name;
    _unitsController.text = existing.units.length.toString();
    _examDate = existing.examDate;
    _dateController.text = DateFormat.yMMMd().format(existing.examDate);
    _difficulty = existing.difficulty;
    _priority = existing.priority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final current = _examDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(today) ? current : today,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _examDate = picked;
      _dateController.text = DateFormat.yMMMd().format(picked);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final existing = _existing;
    final unitCount = int.parse(_unitsController.text.trim());
    final keptUnits = existing?.units ?? const <StudyUnit>[];
    final subject = Subject(
      id: existing?.id ?? newId(),
      name: _nameController.text.trim(),
      examDate: _examDate!,
      difficulty: _difficulty,
      priority: _priority,
      units: [
        ...keptUnits,
        for (var number = keptUnits.length + 1; number <= unitCount; number++)
          StudyUnit(id: newId(), name: 'Unit $number', topics: const []),
      ],
    );
    if (existing == null) {
      state.addSubject(subject);
    } else {
      state.updateSubject(subject);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = _existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit subject' : 'New subject')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Subject name',
                            hintText: 'e.g. Data Structures',
                          ),
                          validator: Validators.subjectName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: const InputDecoration(
                            labelText: 'Exam date',
                            suffixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          validator: (_) => Validators.examDate(_examDate),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _unitsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Number of units',
                            helperText: isEditing
                                ? 'Existing units cannot be removed here.'
                                : 'You can add topics to each unit later.',
                          ),
                          validator: (value) => Validators.unitCount(value, minimum: _minimumUnits),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Difficulty>(
                          value: _difficulty,
                          decoration: const InputDecoration(labelText: 'Difficulty'),
                          items: [
                            for (final level in Difficulty.values)
                              DropdownMenuItem(value: level, child: Text(level.label)),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _difficulty = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority: $_priority of 5',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Higher priority subjects get scheduled first.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        Slider(
                          value: _priority.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$_priority',
                          onChanged: (value) => setState(() => _priority = value.round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: const Text('Save subject'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
