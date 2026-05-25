import 'package:flutter/material.dart';

import 'package:country_code_helper/src/country_code_picker/country_code_picker.dart';
import 'package:country_code_helper/src/models/country.dart';

/// Opens a modal bottom sheet hosting a [CountryPickerWidget].
///
/// Resolves to the selected [Country] or `null` if dismissed.
///
/// ```dart
/// final country = await showCountryPickerSheet(
///   context: context,
///   priorityCodes: ['IQ', 'JO'],
/// );
/// ```
Future<Country?> showCountryPickerSheet(
  BuildContext context, {
  String? locale,
  Country? selected,
  String? title,
  List<String>? priorityCodes,
  List<String>? excludedCodes,
  bool showOnlyPriority = false,
  double heightFactor = 0.85,
  CountryPickerConfig? config,
  ShapeBorder? shape,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? barrierColor,
  Color? backgroundColor,
}) {
  final resolvedLocale =
      locale ?? Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

  final mergedConfig = config == null
      ? CountryPickerConfig(
          priorityCountryCodes: priorityCodes,
          excludedCountryCodes: excludedCodes,
          showOnlyPriorityCountries:
              showOnlyPriority && (priorityCodes?.isNotEmpty ?? false),
        )
      : CountryPickerConfig(
          searchHintText: config.searchHintText,
          noCountriesFoundText: config.noCountriesFoundText,
          flagIconSize: config.flagIconSize,
          showSeparator: config.showSeparator,
          focusSearchBox: config.focusSearchBox,
          listWithCodes: config.listWithCodes,
          showDialCode: config.showDialCode,
          showCountryCode: config.showCountryCode,
          loadingIndicator: config.loadingIndicator,
          itemBuilder: config.itemBuilder,
          priorityCountryCodes:
              config.priorityCountryCodes ?? priorityCodes,
          excludedCountryCodes:
              config.excludedCountryCodes ?? excludedCodes,
          showOnlyPriorityCountries: config.showOnlyPriorityCountries ||
              (showOnlyPriority && (priorityCodes?.isNotEmpty ?? false)),
          contentPadding: config.contentPadding,
          searchInputStyle: config.searchInputStyle,
          searchInputDecoration: config.searchInputDecoration,
          itemTextStyle: config.itemTextStyle,
        );

  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: barrierColor,
    backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
    shape: shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * heightFactor,
    ),
    builder: (sheetContext) => _CountryPickerSheetBody(
      title: title,
      locale: resolvedLocale,
      selected: selected,
      config: mergedConfig,
    ),
  );
}

class _CountryPickerSheetBody extends StatelessWidget {
  final String? title;
  final String locale;
  final Country? selected;
  final CountryPickerConfig config;

  const _CountryPickerSheetBody({
    required this.title,
    required this.locale,
    required this.selected,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      title ?? 'Select country',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Flexible(
              child: CountryPickerWidget(
                locale: locale,
                selected: selected,
                config: config,
                onSelected: (country) =>
                    Navigator.of(context).maybePop(country),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
