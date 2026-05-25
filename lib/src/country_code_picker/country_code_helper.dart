import 'dart:async';
import 'dart:ui';

import 'package:country_code_helper/src/country_code_picker/counties.dart';
import 'package:country_code_helper/src/models/country.dart';

/// Returns an ISO 3166-1 alpha-2 region code (e.g. `IQ`) or `null`.
///
/// Use this to plug a SIM-card resolver — or any custom signal — into
/// [CountryCode.initCountry] without forcing every consumer of this package
/// to pull native plugins.
///
/// Example with `sim_card_code` (kept as an app-level dep):
///
/// ```dart
/// import 'package:sim_card_code/sim_card_code.dart';
///
/// final country = await CountryCode.initCountry(
///   regionResolver: () => SimCardManager.simCountryCode,
/// );
/// ```
typedef RegionResolver = FutureOr<String?> Function();

/// Static accessors for country data and device-region detection.
class CountryCode {
  CountryCode._();

  static Map<String, Country>? _cache;

  /// Predefined region lists.
  static const List<String> arab = arabCountries;
  static const List<String> westernEuropean = westernEuropeanCountries;
  static const List<String> easternEuropean = easternEuropeanCountries;
  static const List<String> stan = stanCountries;
  static const List<String> african = africanCountries;

  /// Clears the cached country map. Call only if [preferred]/[exclude]
  /// were used and you need to recompute the ordering.
  static void clearCache() => _cache = null;

  /// Returns the device's country.
  ///
  /// Resolution order:
  ///   1. [regionResolver] (optional — e.g. SIM card lookup from your app).
  ///   2. [PlatformDispatcher.instance.locales] (pure Dart, no native deps).
  ///   3. [fallback] (or `null`).
  ///
  /// Pass [preferred]/[exclude] to control list ordering.
  static Future<Country?> initCountry({
    List<String>? preferred,
    List<String>? exclude,
    Country? fallback,
    RegionResolver? regionResolver,
  }) async {
    final map = countries(preferred: preferred, exclude: exclude);

    String? region;
    if (regionResolver != null) {
      try {
        region = await regionResolver();
      } catch (_) {
        region = null;
      }
    }
    region ??= detectRegionCode();
    if (region == null) return fallback;

    final upper = region.toUpperCase();
    return map[upper] ?? fallback;
  }

  /// Synchronous device-locale lookup. Skips any async resolver.
  static Country? detectCountry({Country? fallback}) {
    final region = detectRegionCode();
    if (region == null) return fallback;
    return countriesData[region] ?? fallback;
  }

  /// Returns the device locale region code (ISO 3166-1 alpha-2, uppercase),
  /// or `null` when unavailable.
  static String? detectRegionCode() {
    final locales = PlatformDispatcher.instance.locales;
    for (final locale in locales) {
      final code = locale.countryCode;
      if (code != null && code.isNotEmpty) return code.toUpperCase();
    }
    return null;
  }

  /// Returns the full country map.
  ///
  /// [preferred] codes are moved to the top in the order given.
  /// [exclude] codes are removed entirely.
  static Map<String, Country> countries({
    List<String>? preferred,
    List<String>? exclude,
  }) {
    if (_cache != null &&
        (preferred == null || preferred.isEmpty) &&
        (exclude == null || exclude.isEmpty)) {
      return _cache!;
    }

    final excludeSet = exclude?.map((e) => e.toUpperCase()).toSet() ??
        const <String>{};
    final preferredCodes =
        preferred?.map((e) => e.toUpperCase()).toList() ?? const <String>[];

    final result = <String, Country>{};

    for (final code in preferredCodes) {
      if (excludeSet.contains(code)) continue;
      final entry = countriesData[code];
      if (entry != null) result[code] = entry;
    }

    for (final entry in countriesData.entries) {
      if (excludeSet.contains(entry.key)) continue;
      if (result.containsKey(entry.key)) continue;
      result[entry.key] = entry.value;
    }

    _cache = result;
    return result;
  }

  /// Returns the [Country] for [countryCode] (case-insensitive), or `null`.
  static Country? getCountryByCountryCode(String countryCode) =>
      countriesData[countryCode.toUpperCase()];

  /// Returns the [Country] matching the dial code (e.g. `+964` or `964`).
  static Country? getCountryByCallingCode(String callingCode) {
    final normalized =
        callingCode.startsWith('+') ? callingCode : '+$callingCode';
    for (final country in countriesData.values) {
      if (country.callingCode == normalized) return country;
    }
    return null;
  }
}
