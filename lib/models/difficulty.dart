/// How hard a subject is to learn. Scales the study time each of its topics needs.
enum Difficulty {
  easy('Easy', 1.0),
  medium('Medium', 1.5),
  hard('Hard', 2.0);

  const Difficulty(this.label, this.effortMultiplier);

  final String label;
  final double effortMultiplier;
}
