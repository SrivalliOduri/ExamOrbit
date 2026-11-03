import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/progress_ring.dart';
import '../widgets/stat_tile.dart';

enum _Phase { focus, shortBreak }

/// Pomodoro timer alternating 25 minute focus blocks and 5 minute breaks.
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> with SingleTickerProviderStateMixin {
  static const int _focusSeconds = 25 * 60;
  static const int _breakSeconds = 5 * 60;

  late final AnimationController _pulse;
  Timer? _ticker;
  bool _running = false;
  _Phase _phase = _Phase.focus;
  int _remaining = _focusSeconds;
  int _sessions = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  int _durationFor(_Phase phase) => phase == _Phase.focus ? _focusSeconds : _breakSeconds;

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    _pulse.repeat(reverse: true);
    setState(() => _running = true);
  }

  void _pause() {
    _ticker?.cancel();
    _pulse.reset();
    setState(() => _running = false);
  }

  void _reset() {
    _pause();
    setState(() => _remaining = _durationFor(_phase));
  }

  void _onTick(Timer timer) {
    if (_remaining > 1) {
      setState(() => _remaining--);
      return;
    }
    _pause();
    final finished = _phase;
    setState(() {
      if (finished == _Phase.focus) _sessions++;
      _phase = finished == _Phase.focus ? _Phase.shortBreak : _Phase.focus;
      _remaining = _durationFor(_phase);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          finished == _Phase.focus
              ? 'Focus session complete. Time for a 5 minute break.'
              : 'Break is over. Ready for another focus session?',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFocus = _phase == _Phase.focus;
    final phaseColor = isFocus ? scheme.primary : scheme.secondary;
    final total = _durationFor(_phase);
    final elapsed = (total - _remaining) / total;
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Focus timer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFocus ? scheme.primaryContainer : scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isFocus ? 'Focus' : 'Short break',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isFocus ? scheme.onPrimaryContainer : scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.05).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: ProgressRing(
                    progress: elapsed,
                    size: 260,
                    strokeWidth: 14,
                    color: phaseColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$minutes:$seconds',
                          style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _running ? 'Stay focused' : 'Ready when you are',
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _running ? _pause : _start,
                      icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(_running ? 'Pause' : 'Start'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.local_fire_department_rounded,
                        value: '$_sessions',
                        label: 'Sessions completed',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
