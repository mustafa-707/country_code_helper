# country_code_helper

[![StandWithPalestine](https://raw.githubusercontent.com/TheBSD/StandWithPalestine/main/badges/StandWithPalestine.svg)](https://github.com/TheBSD/StandWithPalestine/blob/main/docs/README.md) [![Pub Package](https://img.shields.io/pub/v/country_code_helper.svg)](https://pub.dev/packages/country_code_helper)

A **pure-Dart** Flutter package for picking, displaying, and validating country / dial codes. No native code. No Android KGP. No iOS SwiftPM coupling. Ships with:

- A built-in themed bottom-sheet picker (`showCountryPickerSheet`).
- A drop-in phone-input prefix (`CountryCodePrefix`).
- A modern, Material 3 `CountryPickerWidget` (search, RTL/Arabic-aware, priority pinning).
- Device-locale country detection (`CountryCode.initCountry`).
- Phone number parsing + validation (`PhoneNumberTools`).
- Bundled flag assets — no network.

## Install

```yaml
dependencies:
  country_code_helper: ^0.3.0
```

```dart
import 'package:country_code_helper/country_code_helper.dart';
```

## Quick start — built-in picker sheet

No more wrapping the widget in your own `showModalBottomSheet`:

```dart
final country = await showCountryPickerSheet(
  context,
  selected: currentCountry,
  priorityCodes: const ['IQ', 'JO', 'SA'],
  title: 'Select country',
);
```

Restrict the list (e.g. only show event-allowed countries):

```dart
await showCountryPickerSheet(
  context,
  priorityCodes: allowedCodes,
  showOnlyPriority: true,
);
```

## Phone-field prefix

```dart
TextField(
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: 'Phone number',
    border: const OutlineInputBorder(),
    prefixIcon: CountryCodePrefix(
      country: country,
      priorityCodes: const ['IQ', 'JO', 'SA'],
      onChanged: (c) => setState(() => country = c),
    ),
  ),
);
```

## Full control — `CountryPickerWidget`

Drop the widget anywhere (page, dialog, custom sheet):

```dart
CountryPickerWidget(
  locale: Localizations.localeOf(context).languageCode,
  selected: country,
  onSelected: (c) => Navigator.pop(context, c),
  config: const CountryPickerConfig(
    priorityCountryCodes: ['IQ', 'JO'],
    showOnlyPriorityCountries: false,
    showDialCode: true,
    showCountryCode: false,
  ),
);
```

## Country data

```dart
// All countries (preferred codes pinned to the top, in order):
final all = CountryCode.countries(preferred: ['IQ', 'JO']);

// Lookup by ISO code:
final iq = CountryCode.getCountryByCountryCode('IQ');

// Lookup by dial code:
final jo = CountryCode.getCountryByCallingCode('+962');

// Device-locale region detection (pure Dart) with fallback:
final detected = await CountryCode.initCountry(
  preferred: const ['IQ', 'JO'],
  fallback: CountryCode.getCountryByCountryCode('IQ'),
);
```

### Plugging in SIM-card detection

The package itself stays **pure Dart**. If your app needs SIM-card based
detection, add your preferred plugin (e.g. [`sim_card_code`](https://pub.dev/packages/sim_card_code))
to your *app's* `pubspec.yaml` and wire it in via `regionResolver`:

```dart
import 'package:sim_card_code/sim_card_code.dart';

final country = await CountryCode.initCountry(
  preferred: const ['IQ', 'JO'],
  regionResolver: () => SimCardManager.simCountryCode,
  fallback: CountryCode.getCountryByCountryCode('IQ'),
);
```

Resolution order:

1. `regionResolver` (if provided) — e.g. SIM card.
2. `PlatformDispatcher.locales` — device locale region.
3. `fallback`.

The `Country` model exposes:

```dart
country.name;                       // English name
country.countryCode;                // 'IQ'
country.callingCode;                // '+964'
country.localFlag;                  // 'flags/iq.png'
country.localizedName('ar');        // 'العراق'
```

## Region presets

```dart
CountryCode.arab;
CountryCode.westernEuropean;
CountryCode.easternEuropean;
CountryCode.stan;
CountryCode.african;
```

## Phone number parsing & validation

```dart
final parsed = PhoneNumberTools.parse('+9647701234567');
parsed.e164;            // '+9647701234567'
parsed.national;        // '0770 123 4567'
parsed.international;
parsed.regionCode;      // 'IQ'

final ok = PhoneNumberTools.validate('07701234567', regionCode: 'IQ');
```

## Flags

Bundled PNG flag assets ship inside the package. Render with:

```dart
Image.asset(
  country.localFlag,            // or placeholderImgPath
  package: countryCodePackageName,
);
```

## Migrating from 0.2.x

- `CountryPickerWidget`'s `selected` parameter highlights the active row.
- `CountryPickerConfig.itemBuilder` now receives `(context, country, selected)`.
- `PhoneNumberTools.parse` / `validate` are now **static** — drop the `()`.
- `CountryCode.initCountry` returns `Country?` (was always non-null); pass `fallback` if you need the old behavior.

## Support

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-1.svg)](https://buymeacoffee.com/is10vmust)
