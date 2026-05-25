import 'package:flutter/material.dart';

import 'package:country_code_helper/src/country_code_picker/country_code_picker.dart';
import 'package:country_code_helper/src/country_code_picker/country_picker_sheet.dart';
import 'package:country_code_helper/src/models/country.dart';

/// Drop-in phone-field prefix that shows a flag + dial code and opens the
/// [showCountryPickerSheet] picker on tap.
///
/// ```dart
/// TextField(
///   decoration: InputDecoration(
///     prefixIcon: CountryCodePrefix(
///       country: country,
///       onChanged: (c) => setState(() => country = c),
///     ),
///   ),
/// )
/// ```
class CountryCodePrefix extends StatelessWidget {
  /// Currently-selected country (renders flag + dial code).
  final Country? country;

  /// Fires when the user picks a new country.
  final ValueChanged<Country>? onChanged;

  /// Codes pinned to the top of the picker (in order).
  final List<String>? priorityCodes;

  /// Codes hidden from the picker.
  final List<String>? excludedCodes;

  /// When `true` and [priorityCodes] is non-empty, the picker shows ONLY
  /// the priority codes.
  final bool lockToPriority;

  /// Optional sheet title.
  final String? title;

  /// Optional explicit locale (defaults to context locale).
  final String? locale;

  /// Disables the tap target.
  final bool enabled;

  /// Padding around the inner row.
  final EdgeInsetsGeometry padding;

  const CountryCodePrefix({
    super.key,
    required this.country,
    this.onChanged,
    this.priorityCodes,
    this.excludedCodes,
    this.lockToPriority = false,
    this.title,
    this.locale,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divider = theme.colorScheme.onSurface.withValues(alpha: 0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () async {
                final picked = await showCountryPickerSheet(
                  context,
                  selected: country,
                  locale: locale,
                  title: title,
                  priorityCodes: priorityCodes,
                  excludedCodes: excludedCodes,
                  showOnlyPriority: lockToPriority,
                );
                if (picked != null) onChanged?.call(picked);
              }
            : null,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: country == null
                    ? Image.asset(
                        placeholderImgPath,
                        package: countryCodePackageName,
                        width: 24,
                        height: 18,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        country!.localFlag,
                        package: countryCodePackageName,
                        width: 24,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          placeholderImgPath,
                          package: countryCodePackageName,
                          width: 24,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                country?.callingCode ?? '+--',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: divider),
            ],
          ),
        ),
      ),
    );
  }
}
