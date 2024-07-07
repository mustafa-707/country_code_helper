# country_code_helper

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md) [![Pub Package](https://img.shields.io/pub/v/country_code_helper.svg)](https://pub.dev/packages/country_code_helper)

A Flutter package to handle country codes, country data, and phone number parsing/validation. This package provides easy access to country information, sorting capabilities, and a convenient widget for displaying and selecting countries.

## Installation

Add `country_code_helper` to your `pubspec.yaml`:

## Features

### Initialization

#### `initCountry`

Fetches the country code based on the SIM card information.

Example:

```dart
Country? initCountry = await CountryCode.initCountry();
print(initCountry); // Outputs the country information based on the SIM card.
```

> Note: fallback is the first country in the list; hence, it can be sorted before selecting the first one as a fallback.

### Country Data

#### `countries`

Fetches all country data and supports sorting based on a preferred list of country codes.

```dart
Map<String, Country> allCountries = CountryCode.countries();
print(allCountries); // Outputs a map of all countries with their data.
```

#### Sorting

Countries can be sorted based on a preferred list of country codes. This ensures specific countries appear first in the list.

```dart
List<String> preferredCountries = ['US', 'CA', 'GB', 'AU'];
Map<String, Country> sortedCountries = CountryCode.countries(preferredCountries);
print(sortedCountries); // Outputs a map of countries sorted by the preferred list.
```

### Accessing Country Data

#### `getCountryByCountryCode`

Retrieves country data using the country code.

```dart
Country? country = CountryCode.getCountryByCountryCode('US');
print(country); // Outputs the country information for the United States.
```

### Regions

Fetches a list of countries based on region.

#### `arabCountries`

```dart
List<String> arabCountries = CountryCode.arabCountries;
```

#### `easternEuropeanCountries`

```dart
List<String> easternEuropeanCountries = CountryCode.easternEuropeanCountries;
```

#### `westernEuropeanCountries`

```dart
List<String> westernEuropeanCountries = CountryCode.westernEuropeanCountries;
```

#### `stanCountries`

```dart
List<String> stanCountries = CountryCode.stanCountries;
```

#### `africanCountries`

```dart
List<String> africanCountries = CountryCode.africanCountries;
```

### Phone Number Tools

#### Parsing and Validation

Provides tools for parsing and validating phone numbers.

```dart
ParsedNumber parsedNumber = await PhoneNumberTools.parse('+123456789');
print(parsedNumber); 
// Outputs the parsed phone number information :
// countryCode
// e164
// national
// type
// international
// nationalNumber
// regionCode

bool isValid = PhoneNumberTools.validate('+123456789');
print(isValid); // Outputs true/false based on whether the phone number is valid.
```

### Flags and Placeholders

Access to flag images and a placeholder image path.

```dart
String flagImagePath = 'flags/PS.png'; // Example path to the Palestine flag.
// package: countryCodePackageName, use this in image widget to show package assets only

String placeholderImagePath = placeholderImgPath;
print(placeholderImagePath); // Outputs the path to the placeholder image.
```

### Widget Integration

#### `CountryPickerWidget`

A Flutter widget for displaying and selecting countries, with search functionality supporting Arabic words normalization.

Example usage:

```dart
CountryPickerWidget(
  onSelected: (country) => Navigator.of(context).pop(country),
  searchHintText: 'search...',
  locale: Localizations.localeOf(context).languageCode,
  //... more params
);
```

## Support

If you find this plugin helpful, consider supporting me:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)
