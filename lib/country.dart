class Country {
  final String name;
  final String flag;
  final String countryCode;
  final String callingCode;
  final Map<String, String> nameTranslations;

  const Country(
    this.name,
    this.flag,
    this.countryCode,
    this.callingCode,
    this.nameTranslations,
  );

  factory Country.fromJson(Map<String, dynamic> json) {
    return new Country(
      json['name'] as String,
      json['flag'] as String,
      json['country_code'] as String,
      json['calling_code'] as String,
      json['nameTranslations'] as Map<String, String>,
    );
  }
}
