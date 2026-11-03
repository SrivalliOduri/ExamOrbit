import 'dart:math';

/// Returns a local identifier for newly created subjects, units and topics.
String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}';
