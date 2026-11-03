/// A single checklist item inside a unit.
class Topic {
  const Topic({required this.id, required this.name, this.isCompleted = false});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        name: json['name'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  final String id;
  final String name;
  final bool isCompleted;

  Topic copyWith({bool? isCompleted}) => Topic(
        id: id,
        name: name,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'isCompleted': isCompleted};
}
