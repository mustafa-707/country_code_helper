// Utility to parse JSON string to ParsedNumber object
import 'dart:convert';

ParsedNumber parsedNumberFromJson(String str) => ParsedNumber.fromJson(json.decode(str));

class ParsedNumber {
  final String countryCode;
  final String e164;
  final String national;
  final String type;
  final String international;
  final String nationalNumber;
  final String regionCode;

  ParsedNumber({
    required this.countryCode,
    required this.e164,
    required this.national,
    required this.type,
    required this.international,
    required this.nationalNumber,
    required this.regionCode,
  });

  // Factory to create a ParsedNumber from a JSON map
  factory ParsedNumber.fromJson(Map<String, dynamic> json) => ParsedNumber(
        countryCode: json["country_code"],
        e164: json["e164"],
        national: json["national"],
        type: json["type"],
        international: json["international"],
        nationalNumber: json["national_number"],
        regionCode: json["region_code"],
      );

  // Convert ParsedNumber to JSON map
  Map<String, dynamic> toJson() => {
        "country_code": countryCode,
        "e164": e164,
        "national": national,
        "type": type,
        "international": international,
        "national_number": nationalNumber,
        "region_code": regionCode,
      };
}
