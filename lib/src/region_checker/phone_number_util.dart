import 'package:country_code_helper/src/models/parsed_number.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Phone number parsing + validation helpers.
///
/// Pure Dart — no native code, no Android KGP, no iOS SwiftPM coupling.
class PhoneNumberTools {
  PhoneNumberTools._();

  /// Parses [phoneNumber] into a [ParsedNumber].
  ///
  /// Pass [regionCode] (ISO 3166-1 alpha-2) when the number is not in
  /// E.164 format (i.e. has no leading `+`).
  ///
  /// Throws [FormatException] if the number cannot be parsed.
  static ParsedNumber parse(String phoneNumber, {String? regionCode}) {
    final caller = _isoFromCode(regionCode);
    final PhoneNumber phone;
    try {
      phone = PhoneNumber.parse(phoneNumber, callerCountry: caller);
    } catch (e) {
      throw FormatException('Could not parse "$phoneNumber": $e');
    }

    return ParsedNumber(
      countryCode: phone.countryCode,
      e164: '+${phone.countryCode}${phone.nsn}',
      national: phone.formatNsn(),
      international: phone.formatNsn(format: NsnFormat.international),
      nationalNumber: phone.nsn,
      regionCode: phone.isoCode.name.toUpperCase(),
      type: _typeOf(phone),
    );
  }

  /// Returns `true` when [phoneNumber] is a valid number for [regionCode].
  static bool validate(String phoneNumber, {String? regionCode}) {
    try {
      final caller = _isoFromCode(regionCode);
      return PhoneNumber.parse(phoneNumber, callerCountry: caller).isValid();
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` when [phoneNumber] is a valid mobile number.
  static bool validateMobile(String phoneNumber, {String? regionCode}) =>
      _validateType(phoneNumber, regionCode, PhoneNumberType.mobile);

  /// Returns `true` when [phoneNumber] is a valid fixed-line number.
  static bool validateFixedLine(String phoneNumber, {String? regionCode}) =>
      _validateType(phoneNumber, regionCode, PhoneNumberType.fixedLine);

  static bool _validateType(
    String phoneNumber,
    String? regionCode,
    PhoneNumberType type,
  ) {
    try {
      return PhoneNumber.parse(
        phoneNumber,
        callerCountry: _isoFromCode(regionCode),
      ).isValid(type: type);
    } catch (_) {
      return false;
    }
  }

  static IsoCode? _isoFromCode(String? regionCode) {
    if (regionCode == null) return null;
    final name = regionCode.toLowerCase();
    for (final iso in IsoCode.values) {
      if (iso.name.toLowerCase() == name) return iso;
    }
    return null;
  }

  static String _typeOf(PhoneNumber phone) {
    if (phone.isValid(type: PhoneNumberType.mobile)) return 'mobile';
    if (phone.isValid(type: PhoneNumberType.fixedLine)) return 'fixedLine';
    return 'unknown';
  }
}
