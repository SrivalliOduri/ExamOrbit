import 'date_helpers.dart';

/// Form validation rules shared by the subject form, topic dialog and settings.
abstract final class Validators {
  static const int maxSubjectNameLength = 40;
  static const int maxTopicNameLength = 80;
  static const int maxUnits = 30;
  static const double minStudyHours = 0.5;
  static const int maxStudyHours = 16;

  static String? subjectName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter a subject name';
    if (name.length > maxSubjectNameLength) {
      return 'Keep the name under $maxSubjectNameLength characters';
    }
    return null;
  }

  static String? examDate(DateTime? date) {
    if (date == null) return 'Pick an exam date';
    if (daysBetween(dateOnly(DateTime.now()), date) < 0) {
      return 'Exam date cannot be in the past';
    }
    return null;
  }

  static String? unitCount(String? value, {int minimum = 1}) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null) return 'Enter a whole number';
    if (count < minimum) {
      return 'Use at least $minimum ${minimum == 1 ? 'unit' : 'units'}';
    }
    if (count > maxUnits) return 'Use $maxUnits units or fewer';
    return null;
  }

  static String? topicName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter a topic name';
    if (name.length > maxTopicNameLength) {
      return 'Keep the name under $maxTopicNameLength characters';
    }
    return null;
  }

  static String? studyHours(String? value) {
    final hours = double.tryParse(value?.trim() ?? '');
    if (hours == null) return 'Enter a number of hours';
    if (hours < minStudyHours || hours > maxStudyHours) {
      return 'Enter between $minStudyHours and $maxStudyHours hours';
    }
    return null;
  }
}
