/// One topic scheduled for study on a specific day.
class StudyTask {
  const StudyTask({
    required this.subjectId,
    required this.subjectName,
    required this.topicId,
    required this.topicName,
    required this.minutes,
  });

  final String subjectId;
  final String subjectName;
  final String topicId;
  final String topicName;
  final int minutes;
}
