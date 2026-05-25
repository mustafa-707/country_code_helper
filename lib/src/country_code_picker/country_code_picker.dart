import 'dart:async';

import 'package:dartarabic/dartarabic.dart';
import 'package:flutter/material.dart';

import 'package:country_code_helper/src/country_code_picker/country_code_helper.dart';
import 'package:country_code_helper/src/models/country.dart';

/// Package name used when loading bundled flag assets via [Image.asset].
const String countryCodePackageName = 'country_code_helper';

/// Path to the bundled placeholder flag.
const String placeholderImgPath = 'flags/placeholder.png';

/// Optional country filter used by [CountryPickerWidget].
typedef CountryFilterFunction = bool Function(Country country, String query);

/// Builds a custom list item for a country.
typedef CountryItemBuilder = Widget Function(
  BuildContext context,
  Country country,
  bool selected,
);

const double _tileHeight = 56.0;

/// Visual + behavioural configuration for [CountryPickerWidget].
class CountryPickerConfig {
  /// Hint text shown inside the search field.
  final String searchHintText;

  /// Text shown when no countries match the search.
  final String noCountriesFoundText;

  /// Flag size in logical pixels.
  final double flagIconSize;

  /// Whether to draw a divider between items.
  final bool showSeparator;

  /// Whether to autofocus the search field on open.
  final bool focusSearchBox;

  /// Whether to render the trailing dial / ISO codes.
  final bool listWithCodes;

  /// Whether to show the dial code (e.g. `+964`) in the trailing area.
  final bool showDialCode;

  /// Whether to show the ISO code (e.g. `IQ`) in the trailing area.
  final bool showCountryCode;

  /// Custom loading indicator. Defaults to a [CircularProgressIndicator].
  final Widget? loadingIndicator;

  /// Builds a custom row for each country. Overrides default tile.
  final CountryItemBuilder? itemBuilder;

  /// Codes pinned to the top of the list (in order). Common picks: `IQ`, `JO`.
  final List<String>? priorityCountryCodes;

  /// Codes hidden from the list.
  final List<String>? excludedCountryCodes;

  /// When `true`, the list contains only [priorityCountryCodes].
  final bool showOnlyPriorityCountries;

  /// Padding around the search field.
  final EdgeInsetsGeometry contentPadding;

  /// Override the search field's style. Defaults to theme's `bodyLarge`.
  final TextStyle? searchInputStyle;

  /// Override the search field's decoration.
  final InputDecoration? searchInputDecoration;

  /// Override item text style. Defaults to theme's `bodyLarge`.
  final TextStyle? itemTextStyle;

  /// Search debounce. Smaller = faster feedback. Larger = fewer filter passes.
  final Duration searchDebounce;

  const CountryPickerConfig({
    this.searchHintText = 'Search country, code, or number',
    this.noCountriesFoundText = 'No countries found',
    this.flagIconSize = 28,
    this.showSeparator = false,
    this.focusSearchBox = false,
    this.listWithCodes = true,
    this.showDialCode = true,
    this.showCountryCode = false,
    this.loadingIndicator,
    this.itemBuilder,
    this.priorityCountryCodes,
    this.excludedCountryCodes,
    this.showOnlyPriorityCountries = false,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.searchInputStyle,
    this.searchInputDecoration,
    this.itemTextStyle,
    this.searchDebounce = const Duration(milliseconds: 80),
  });
}

/// Internal indexed row — country plus its precomputed normalized search key.
class _IndexedCountry {
  final Country country;
  final String searchKey;
  const _IndexedCountry(this.country, this.searchKey);
}

/// Scrollable list of countries with search + priority pinning.
///
/// Most apps should use the top-level `showCountryPickerSheet` instead.
class CountryPickerWidget extends StatefulWidget {
  /// Fires when the user taps a country.
  final ValueChanged<Country>? onSelected;

  /// Locale used for translated country names (e.g. `ar`, `en`, `pt_BR`).
  final String locale;

  /// Optional currently-selected country, used to highlight the row.
  final Country? selected;

  /// Visual / behavioural configuration.
  final CountryPickerConfig config;

  /// Custom search predicate. Overrides built-in matching.
  final CountryFilterFunction? customFilter;

  /// Keep widget alive when nested in tab views.
  final bool cacheResults;

  const CountryPickerWidget({
    super.key,
    required this.locale,
    this.onSelected,
    this.selected,
    this.customFilter,
    this.cacheResults = true,
    CountryPickerConfig? config,
  }) : config = config ?? const CountryPickerConfig();

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<_IndexedCountry> _all = const [];
  List<_IndexedCountry> _priority = const [];
  List<_IndexedCountry> _filtered = const [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  @override
  void didUpdateWidget(CountryPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale ||
        !_listEq(oldWidget.config.priorityCountryCodes,
            widget.config.priorityCountryCodes) ||
        !_listEq(oldWidget.config.excludedCountryCodes,
            widget.config.excludedCountryCodes) ||
        oldWidget.config.showOnlyPriorityCountries !=
            widget.config.showOnlyPriorityCountries) {
      _load();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    final excludeSet = widget.config.excludedCountryCodes
            ?.map((e) => e.toUpperCase())
            .toSet() ??
        const <String>{};

    // Build the canonical (alphabetical) list once.
    final raw = CountryCode.countries().values
        .where((c) => !excludeSet.contains(c.countryCode))
        .toList();

    // Pre-normalize once per (country, locale). Bundle codes + name into a
    // single space-joined key so search becomes one `String.contains`.
    final all = <_IndexedCountry>[
      for (final c in raw)
        _IndexedCountry(c, _buildSearchKey(c, widget.locale)),
    ];

    final priorityCodes = widget.config.priorityCountryCodes
            ?.map((e) => e.toUpperCase())
            .toList() ??
        const <String>[];

    final byCode = {for (final ic in all) ic.country.countryCode: ic};
    final priority = <_IndexedCountry>[
      for (final code in priorityCodes)
        if (byCode[code] != null) byCode[code]!,
    ];

    if (!mounted) return;
    setState(() {
      _all = all;
      _priority = priority;
      _filtered = _baseList(all, priority);
      _loading = false;
    });
  }

  List<_IndexedCountry> _baseList(
      List<_IndexedCountry> all, List<_IndexedCountry> priority) {
    if (widget.config.showOnlyPriorityCountries && priority.isNotEmpty) {
      return List.of(priority);
    }
    if (priority.isEmpty) return all;
    final prioritySet = {for (final ic in priority) ic.country.countryCode};
    return [
      ...priority,
      ...all.where((ic) => !prioritySet.contains(ic.country.countryCode)),
    ];
  }

  String _buildSearchKey(Country c, String locale) {
    final localized = c.localizedName(locale);
    return [
      _normalize(localized, locale),
      _normalize(c.name, locale),
      c.countryCode.toLowerCase(),
      c.callingCode.toLowerCase(),
    ].join(' ');
  }

  String _normalize(String text, String locale) {
    if (locale.startsWith('ar')) {
      return DartArabic.normalizeLetters(DartArabic.normalizeAlef(text))
          .toLowerCase();
    }
    return text.toLowerCase();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(widget.config.searchDebounce, _applyFilter);
  }

  void _applyFilter() {
    final query = _searchController.text.trim();
    if (query == _query) return;
    _query = query;

    if (query.isEmpty) {
      if (!mounted) return;
      setState(() => _filtered = _baseList(_all, _priority));
      return;
    }
    final normalized = _normalize(query, widget.locale);
    final custom = widget.customFilter;
    final filtered = <_IndexedCountry>[];
    for (final ic in _all) {
      if (custom != null) {
        if (custom(ic.country, normalized)) filtered.add(ic);
      } else if (ic.searchKey.contains(normalized)) {
        filtered.add(ic);
      }
    }
    if (!mounted) return;
    setState(() => _filtered = filtered);
  }

  /// Scrolls the list to the row matching [countryCode], if present.
  void scrollToCountry(String countryCode) {
    final index = _filtered.indexWhere(
      (ic) => ic.country.countryCode.toLowerCase() ==
          countryCode.toLowerCase(),
    );
    if (index == -1) return;
    _scrollController.animateTo(
      index * _tileHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final config = widget.config;

    final searchStyle =
        config.searchInputStyle ?? theme.textTheme.bodyLarge;
    final itemStyle = config.itemTextStyle ?? theme.textTheme.bodyLarge;

    return Column(
      children: [
        Padding(
          padding: config.contentPadding,
          child: TextField(
            controller: _searchController,
            autofocus: config.focusSearchBox,
            style: searchStyle,
            textInputAction: TextInputAction.search,
            decoration: config.searchInputDecoration ??
                _defaultSearchDecoration(theme, config.searchHintText),
          ),
        ),
        Expanded(
          child: _loading
              ? Center(
                  child: config.loadingIndicator ??
                      const CircularProgressIndicator.adaptive(),
                )
              : _filtered.isEmpty
                  ? _EmptyState(
                      text: config.noCountriesFoundText,
                      style: itemStyle,
                    )
                  : _CountryList(
                      countries: _filtered,
                      priorityCount: _query.isEmpty ? _priority.length : 0,
                      controller: _scrollController,
                      locale: widget.locale,
                      selected: widget.selected,
                      config: config,
                      itemStyle: itemStyle,
                      onTap: (c) => widget.onSelected?.call(c),
                    ),
        ),
      ],
    );
  }

  InputDecoration _defaultSearchDecoration(ThemeData theme, String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded, size: 22),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (_, value, __) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Clear',
            onPressed: _searchController.clear,
          );
        },
      ),
      isDense: true,
      filled: true,
      fillColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.cacheResults;

  static bool _listEq(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _CountryList extends StatelessWidget {
  final List<_IndexedCountry> countries;
  final int priorityCount;
  final ScrollController controller;
  final String locale;
  final Country? selected;
  final CountryPickerConfig config;
  final TextStyle? itemStyle;
  final ValueChanged<Country> onTap;

  const _CountryList({
    required this.countries,
    required this.priorityCount,
    required this.controller,
    required this.locale,
    required this.selected,
    required this.config,
    required this.itemStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showDivider = priorityCount > 0 || config.showSeparator;

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: countries.length,
      // Fixed extent enables O(1) scroll-to-index + faster paint.
      itemExtent: _tileHeight,
      itemBuilder: (context, index) {
        final ic = countries[index];
        final country = ic.country;
        final isSelected = selected?.countryCode == country.countryCode;
        final isPriorityBoundary =
            priorityCount > 0 && index == priorityCount - 1;

        Widget child;
        if (config.itemBuilder != null) {
          child = InkWell(
            onTap: () => onTap(country),
            child: config.itemBuilder!(context, country, isSelected),
          );
        } else {
          child = _CountryTile(
            country: country,
            locale: locale,
            selected: isSelected,
            config: config,
            itemStyle: itemStyle,
            onTap: () => onTap(country),
          );
        }

        if (showDivider && (isPriorityBoundary || config.showSeparator)) {
          child = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: child),
              Divider(
                height: 1,
                color: isPriorityBoundary
                    ? theme.dividerColor.withValues(alpha: 0.5)
                    : null,
              ),
            ],
          );
        }

        return RepaintBoundary(
          key: ValueKey('country_${country.countryCode}'),
          child: child,
        );
      },
    );
  }
}

class _CountryTile extends StatelessWidget {
  final Country country;
  final String locale;
  final bool selected;
  final CountryPickerConfig config;
  final TextStyle? itemStyle;
  final VoidCallback onTap;

  const _CountryTile({
    required this.country,
    required this.locale,
    required this.selected,
    required this.config,
    required this.itemStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final flagW = config.flagIconSize;
    final flagH = (config.flagIconSize * 0.75).roundToDouble();
    // 3x DPR cap — good for retina without wasting memory on huge devices.
    final cacheW = (flagW * 3).round();

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  country.localFlag,
                  package: countryCodePackageName,
                  width: flagW,
                  height: flagH,
                  fit: BoxFit.cover,
                  cacheWidth: cacheW,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Image.asset(
                    placeholderImgPath,
                    package: countryCodePackageName,
                    width: flagW,
                    height: flagH,
                    fit: BoxFit.cover,
                    cacheWidth: cacheW,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  country.localizedName(locale),
                  style: itemStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (config.listWithCodes) ...[
                if (config.showCountryCode)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Text(
                      country.countryCode,
                      style: itemStyle?.copyWith(color: muted),
                    ),
                  ),
                if (config.showDialCode)
                  Text(
                    country.callingCode,
                    style: itemStyle?.copyWith(
                      color: muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _EmptyState({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public_off_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(text, style: style),
        ],
      ),
    );
  }
}
