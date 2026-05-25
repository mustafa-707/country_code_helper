/// Country metadata: ISO code, dial code, flag asset, localized names.
class Country {
  /// English country name.
  final String name;

  /// Path to the bundled flag asset, e.g. `flags/iq.png`.
  /// Render with `Image.asset(country.localFlag, package: countryCodePackageName)`.
  final String localFlag;

  /// ISO 3166-1 alpha-2 code, uppercase (e.g. `IQ`).
  final String countryCode;

  /// Dial code including leading `+` (e.g. `+964`).
  final String callingCode;

  /// Map of locale code → translated country name.
  final Map<String, String> nameTranslations;

  const Country({
    required this.name,
    required this.localFlag,
    required this.countryCode,
    required this.callingCode,
    required this.nameTranslations,
  });

  /// Returns the translated name for [locale], falling back to [name].
  ///
  /// Tries an exact match (e.g. `pt_BR`) then the language code (`pt`).
  String localizedName(String locale) {
    return nameTranslations[locale] ??
        nameTranslations[locale.split(RegExp('[_-]')).first] ??
        name;
  }

  Country copyWith({
    String? name,
    String? localFlag,
    String? countryCode,
    String? callingCode,
    Map<String, String>? nameTranslations,
  }) {
    return Country(
      name: name ?? this.name,
      localFlag: localFlag ?? this.localFlag,
      countryCode: countryCode ?? this.countryCode,
      callingCode: callingCode ?? this.callingCode,
      nameTranslations: nameTranslations ?? this.nameTranslations,
    );
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      localFlag: json['flag'] as String,
      countryCode: json['country_code'] as String,
      callingCode: json['calling_code'] as String,
      nameTranslations:
          (json['nameTranslations'] as Map).cast<String, String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'flag': localFlag,
        'country_code': countryCode,
        'calling_code': callingCode,
        'nameTranslations': nameTranslations,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && other.countryCode == countryCode;

  @override
  int get hashCode => countryCode.hashCode;

  @override
  String toString() => 'Country($countryCode, $callingCode, $name)';
}
