/// User preferences that persist across launches.
class AppSettings {
  const AppSettings({required this.isDarkMode, required this.dailyStudyHours});

  const AppSettings.defaults() : this(isDarkMode: false, dailyStudyHours: 2.0);

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        isDarkMode: json['isDarkMode'] as bool,
        dailyStudyHours: (json['dailyStudyHours'] as num).toDouble(),
      );

  final bool isDarkMode;
  final double dailyStudyHours;

  AppSettings copyWith({bool? isDarkMode, double? dailyStudyHours}) => AppSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      );

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'dailyStudyHours': dailyStudyHours,
      };
}
