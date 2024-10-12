class Country {
  final String name;
  final String localFlag;

  final String countryCode;
  final String callingCode;
  final Map<String, String> nameTranslations;

  const Country({
    required this.name,
    required this.localFlag,
    required this.countryCode,
    required this.callingCode,
    required this.nameTranslations,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return new Country(
      name: json['name'] as String,
      localFlag: json['flag'] as String,
      countryCode: json['country_code'] as String,
      callingCode: json['calling_code'] as String,
      nameTranslations: json['nameTranslations'] as Map<String, String>,
    );
  }
}
