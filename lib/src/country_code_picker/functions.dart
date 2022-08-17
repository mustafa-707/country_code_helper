import 'package:flutter_country_code/src/country_code_picker/statics.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import 'country.dart';

///This function returns list of countries
List<Country> getCountries() =>
    countriesData.map<Country>((json) => new Country.fromJson(json)).toList();

///This function returns an user's current country. User's sim country code is matched with the ones in the list.
///if there's no sim country code it will return `first country on the list`
Future<Country> getDefaultCountry() async {
  final list = getCountries();
  try {
    final countryCode = await FlutterSimCountryCode.simCountryCode;
    if (countryCode == null) {
      return list.first;
    }
    return list.firstWhere((element) =>
        element.countryCode.toLowerCase() == countryCode.toLowerCase());
  } catch (e) {
    return list.first;
  }
}

///This function returns an country whose [countryCode] matches with the passed one.
Country getCountryByCountryCode(String countryCode) =>
    getCountries().firstWhere(
      (element) => element.countryCode == countryCode,
      orElse: () => Country(
        '',
        'flags/placeholder.png',
        '',
        '',
        {},
      ),
    );
