class OnboardingInfo {
  final String name;
  final int pregnancyWeek;
  final bool firstPregnancy;

  const OnboardingInfo({
    required this.name,
    required this.pregnancyWeek,
    required this.firstPregnancy,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'pregnancyWeek': pregnancyWeek,
        'firstPregnancy': firstPregnancy,
      };

  factory OnboardingInfo.fromJson(Map<String, dynamic> json) => OnboardingInfo(
        name: json['name'] as String,
        pregnancyWeek: json['pregnancyWeek'] as int,
        firstPregnancy: json['firstPregnancy'] as bool,
      );
}
