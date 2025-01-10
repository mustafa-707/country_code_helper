import 'package:country_code_helper/src/models/parsed_number.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as FlutterLibPhoneNumber;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneNumberTools {
  /// Parses the given [phoneNumberString] into a [ParsedNumber] object.
  /// Optionally, pass the [regionCode] to assist parsing.
  Future<ParsedNumber> parse(String phoneNumberString,
      {String? regionCode}) async {
    try {
      final parsedNumber = await FlutterLibPhoneNumber.parse(phoneNumberString,
          region: regionCode);
      return ParsedNumber.fromJson(parsedNumber);
    } catch (e) {
      throw Exception('Failed to parse phone number: $e');
    }
  }

  /// Validates the given [phoneNumberString] against the optional [regionCode].
  /// Returns `true` if valid, `false` otherwise.
  bool validate(String phoneNumberString, {String? regionCode}) {
    try {
      final parsedNumber = PhoneNumber.parse(
        phoneNumberString,
        callerCountry: regionCode != null
            ? IsoCode.values.firstWhere(
                (e) => e.name.toLowerCase() == regionCode.toLowerCase(),
              )
            : null,
      );
      return parsedNumber.isValid();
    } catch (e) {
      return false; // Return false on failure to parse or invalid format
    }
  }
}
