import 'package:phone_number/phone_number.dart';

class PhoneNumberTools implements PhoneNumberUtil {
  PhoneNumberUtil _plugin = PhoneNumberUtil();
  @override
  Future<List<RegionInfo>> allSupportedRegions({String? locale}) {
    return _plugin.allSupportedRegions(locale: locale);
  }

  @override
  Future<String> carrierRegionCode() {
    return _plugin.carrierRegionCode();
  }

  @override
  Future<String> format(String phoneNumberString, String regionCode) {
    return _plugin.format(phoneNumberString, regionCode);
  }

  @override
  Future<PhoneNumber> parse(String phoneNumberString, {String? regionCode}) {
    return _plugin.parse(phoneNumberString, regionCode: regionCode);
  }

  @override
  Future<Map<String, PhoneNumber>> parseList(
    List<String> phoneNumberStrings, {
    String? regionCode,
  }) {
    return _plugin.parseList(phoneNumberStrings, regionCode: regionCode);
  }

  @override
  Future<bool> validate(
    String phoneNumberString,
    String regionCode,
  ) {
    return _plugin.validate(phoneNumberString, regionCode);
  }
}
