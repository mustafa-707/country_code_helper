import 'package:country_code_helper/src/country_code_picker/counties.dart';
import 'package:country_code_helper/src/models/country.dart';
import 'package:sim_card_code/sim_card_code.dart';

class CountryCode {
  static Map<String, Country>? _sortedCountries;

  /// Returns the Country based on the device's SIM card country code.
  /// If not found, returns the first country in the list.
  static Future<Country> initCountry({
    List<String>? preferred,
    List<String>? exclude,
  }) async {
    try {
      _sortedCountries =
          _sortedCountries ?? countries(preferred: preferred, exclude: exclude);

      if (_sortedCountries == null) throw Exception('Failed to get countries');

      final countryCode = await SimCardInfo.simCountryCode;

      // Return the first country if no SIM card country code is found
      return _sortedCountries!.values.firstWhere(
        (country) =>
            country.countryCode.toLowerCase() == countryCode?.toLowerCase(),
        orElse: () => _sortedCountries!.values.first,
      );
    } catch (e) {
      throw Exception('Failed to get default country: $e');
    }
  }

  /// Returns a map of countries based on preferred and/or excluded lists.
  static Map<String, Country> countries({
    List<String>? preferred,
    List<String>? exclude,
  }) {
    if (_sortedCountries != null && preferred == null && exclude == null) {
      return _sortedCountries!;
    }

    final sortedEntries =
        _getSortedEntries(preferred: preferred, exclude: exclude);
    _sortedCountries = Map.fromEntries(sortedEntries);

    return _sortedCountries!;
  }

  static Set<MapEntry<String, Country>> _getSortedEntries({
    List<String>? preferred,
    List<String>? exclude,
  }) {
    final preferredSet = preferred?.toSet();
    final excludeSet = exclude?.toSet();
    final sortedEntries = <MapEntry<String, Country>>{};

    countriesData.entries.forEach((entry) {
      final countryCode = entry.key;
      final isPreferred = preferredSet?.contains(countryCode) ?? false;
      final isExcluded = excludeSet?.contains(countryCode) ?? false;

      if (isPreferred || !isExcluded) {
        sortedEntries.add(entry);
      }
    });

    return sortedEntries;
  }

  /// Returns a country based on the [countryCode].
  static Country? getCountryByCountryCode(String countryCode) =>
      _sortedCountries?['${countryCode.toUpperCase()}'] ??
      countriesData['${countryCode.toUpperCase()}'];
}
