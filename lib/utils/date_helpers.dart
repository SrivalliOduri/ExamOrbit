/// Strips the time of day so dates can be compared by calendar day.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Whole calendar days from [from] to [to]. Negative when [to] is earlier.
int daysBetween(DateTime from, DateTime to) {
  final start = DateTime.utc(from.year, from.month, from.day);
  final end = DateTime.utc(to.year, to.month, to.day);
  return end.difference(start).inDays;
}
