import 'dart:convert';

import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as FlutterLibPhoneNumber;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

ParsedNumber parsedNumberFromJson(String str) =>
    ParsedNumber.fromJson(json.decode(str));

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

  factory ParsedNumber.fromJson(Map<String, dynamic> json) => ParsedNumber(
        countryCode: json["country_code"],
        e164: json["e164"],
        national: json["national"],
        type: json["type"],
        international: json["international"],
        nationalNumber: json["national_number"],
        regionCode: json["region_code"],
      );

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

class PhoneNumberTools {
  Future<ParsedNumber> parse(
    String phoneNumberString, {
    String? regionCode,
  }) async {
    final parsedNumber = await FlutterLibPhoneNumber.parse(
      phoneNumberString,
      region: regionCode,
    );

    return ParsedNumber.fromJson(parsedNumber);
  }

  bool validate(
    String phoneNumberString, {
    String? regionCode,
  }) {
    final parsedNumber = PhoneNumber.parse(
      phoneNumberString,
      callerCountry: IsoCode.values.firstWhere(
        (e) => e.name.toLowerCase() == regionCode?.toLowerCase(),
        orElse: null,
      ),
    );
    return parsedNumber.isValid();
  }
}
