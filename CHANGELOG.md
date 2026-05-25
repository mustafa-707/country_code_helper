# CHANGES

## [0.3.0]

### Highlights

- **Pure Dart** — dropped `flutter_libphonenumber` and removed the hard dependency on `sim_card_code`. No native code, no Android KGP, no iOS SwiftPM coupling. Zero plugin warnings for consumers.
- **Built-in `showCountryPickerSheet`** modal — no more wrapping `CountryPickerWidget` in your own bottom sheet.
- **`CountryCodePrefix`** widget for phone-input fields (flag + dial code + divider).
- **Modernized picker UI** — Material 3 theming, drag handle, search with prefix icon + inline clear, selection state, empty state, RTL-friendly paddings, divider between priority and full list.

### API

- `PhoneNumberTools.parse` is now **synchronous** (was async). Reimplemented on top of `phone_numbers_parser`.
- `PhoneNumberTools.validateMobile` / `validateFixedLine` added.
- `PhoneNumberTools` methods are now `static`.
- `CountryCode.initCountry` accepts an optional `regionResolver` callback so apps can plug in SIM-card detection (e.g. via `sim_card_code`) without forcing every consumer to pull native deps. Default detection is `PlatformDispatcher.locales`. Now returns `Country?` (was always non-null).
- New `CountryCode.detectCountry({fallback})` and `CountryCode.detectRegionCode()`.
- New `CountryCode.getCountryByCallingCode(...)`.
- `Country.localizedName(locale)`, `copyWith`, value-based `==` / `hashCode`, `toJson`.
- `CountryPickerConfig.itemBuilder` signature changed to `(context, country, selected)`.

### Performance

- Pre-normalized search keys per locale (one `String.contains` per row).
- Debounced search (80 ms).
- Fixed-extent `ListView.builder` with `itemExtent` for O(1) scroll-to-index.
- `RepaintBoundary` around tiles + keyed.
- `cacheWidth` + `FilterQuality.medium` on flag images.

### Fixes

- Priority codes are ordered exactly as provided.
- `initCountry` no longer silently returns the first country on a missed lookup.

### Internal

- Removed `flutter_hooks` / `modal_bottom_sheet` from example.
- Trimmed example app and modernized Android setup (Gradle 8.14, AGP 8.13.2, Kotlin 2.2.20 via built-in Kotlin override).

## [0.2.4]

- Update dependencies (packages)

## [0.2.3]

- Update dependencies (packages)

## [0.2.2]

- Update dependencies (packages)
- Update Syrian Flag

## [0.2.1]

- Update dependencies (packages)
- UI enhancements

## [0.2.0]

- Update dependencies (packages)

## [0.1.2]

- Remove network flags
- Add Kurdistan as a country
- Optimize code

## [0.1.1]

- Add network flag using flagcdn.com

## [0.1.0]

- Add exclude feature

## [0.0.3]

- Correct package repo url

## [0.0.2]

- Remove logs

## [0.0.1]

- Release the package
