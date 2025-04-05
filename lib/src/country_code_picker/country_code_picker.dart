library country_code_picker;

import 'package:dartarabic/dartarabic.dart';
import 'package:flutter/material.dart';
import 'package:country_code_helper/src/country_code_picker/country_code_helper.dart';
import 'package:country_code_helper/src/models/country.dart';

const String countryCodePackageName = 'country_code_helper';
const String placeholderImgPath = 'flags/placeholder.png';

class CountryPickerConfig {
  final TextStyle itemTextStyle;
  final TextStyle searchInputStyle;
  final InputDecoration? searchInputDecoration;
  final double flagIconSize;
  final bool showSeparator;
  final bool focusSearchBox;
  final String searchHintText;
  final String noCountriesFoundText;
  final bool listWithCodes;
  final bool showDialCode;
  final bool showCountryCode;
  final Widget? loadingIndicator;
  final Widget Function(Country)? itemBuilder;
  final List<String>? priorityCountryCodes;
  final List<String>? excludedCountryCodes;
  final bool showOnlyPriorityCountries;
  final EdgeInsets contentPadding;

  const CountryPickerConfig({
    this.itemTextStyle = const TextStyle(fontSize: 16),
    this.searchInputStyle = const TextStyle(fontSize: 16),
    this.searchInputDecoration,
    this.searchHintText = 'Search country name, code',
    this.noCountriesFoundText = 'No countries found',
    this.flagIconSize = 32,
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
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24),
  });
}

typedef CountryFilterFunction = bool Function(Country country, String query);

class CountryPickerWidget extends StatefulWidget {
  final ValueChanged<Country>? onSelected;
  final String locale;
  final CountryPickerConfig config;
  final CountryFilterFunction? customFilter;
  final VoidCallback? onCancelled;
  final bool cacheResults;

  const CountryPickerWidget({
    Key? key,
    required this.locale,
    this.onSelected,
    this.customFilter,
    this.onCancelled,
    this.cacheResults = true,
    CountryPickerConfig? config,
  })  : config = config ?? const CountryPickerConfig(),
        super(key: key);

  @override
  CountryPickerWidgetState createState() => CountryPickerWidgetState();
}

class CountryPickerWidgetState extends State<CountryPickerWidget>
    with AutomaticKeepAliveClientMixin {
  List<Country> _allCountries = [];
  List<Country> _priorityCountries = [];
  List<Country> _filteredList = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  Country? selectedCountry;

  String get currentSearchText => _controller.text;

  void setSearchText(String text) {
    _controller.text = text;
    _filterCountries(text);
  }

  void clearSearch() {
    _controller.clear();
    _resetList();
  }

  void scrollToCountry(String countryCode) {
    final index = _filteredList.indexWhere(
        (c) => c.countryCode.toLowerCase() == countryCode.toLowerCase());

    if (index != -1) {
      _scrollController.animateTo(
        index * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _normalize(String text, String locale) {
    if (locale == 'ar') {
      return DartArabic.normalizeLetters(DartArabic.normalizeAlef(text))
          .toLowerCase();
    } else {
      return text.toLowerCase();
    }
  }

  void _filterCountries(String text) {
    if (text.isEmpty) {
      _resetList();
      return;
    }

    setState(() {
      final normalizedSearch = _normalize(text, widget.locale);

      if (widget.customFilter != null) {
        _filteredList = _allCountries
            .where((country) => widget.customFilter!(country, normalizedSearch))
            .toList();
        return;
      }

      _filteredList = _allCountries.where((country) {
        final countryName = country.nameTranslations[widget.locale];
        final normalizedName = countryName != null
            ? _normalize(countryName, widget.locale)
            : _normalize(country.name, widget.locale);

        return normalizedName.contains(normalizedSearch) ||
            country.callingCode.contains(normalizedSearch) ||
            country.countryCode.toLowerCase().contains(normalizedSearch);
      }).toList();
    });
  }

  void _resetList() {
    setState(() {
      if (widget.config.showOnlyPriorityCountries &&
          _priorityCountries.isNotEmpty) {
        _filteredList = List.from(_priorityCountries);
      } else if (_priorityCountries.isNotEmpty) {
        _filteredList = [
          ..._priorityCountries,
          ..._allCountries.where((c) => !_priorityCountries.contains(c))
        ];
      } else {
        _filteredList = List.from(_allCountries);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCountryList();
  }

  @override
  void didUpdateWidget(CountryPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.locale != widget.locale ||
        oldWidget.config.priorityCountryCodes !=
            widget.config.priorityCountryCodes ||
        oldWidget.config.excludedCountryCodes !=
            widget.config.excludedCountryCodes) {
      _loadCountryList();
    }
  }

  Future<void> _loadCountryList() async {
    setState(() => _isLoading = true);

    await Future.microtask(() {
      final allCountries = CountryCode.countries().values.toList();

      final List<Country> filtered = widget.config.excludedCountryCodes != null
          ? allCountries
              .where((c) =>
                  !widget.config.excludedCountryCodes!.contains(c.countryCode))
              .toList()
          : allCountries;

      List<Country> priorityList = [];
      if (widget.config.priorityCountryCodes?.isNotEmpty ?? false) {
        for (final code in widget.config.priorityCountryCodes!) {
          final country = filtered.firstWhere(
            (c) => c.countryCode.toLowerCase() == code.toLowerCase(),
            orElse: () => filtered.first,
          );
          priorityList.add(country);
        }
      }

      setState(() {
        _allCountries = filtered;
        _priorityCountries = priorityList;
        _resetList();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: widget.config.contentPadding,
          child: TextFormField(
            controller: _controller,
            autofocus: widget.config.focusSearchBox,
            style: widget.config.searchInputStyle,
            decoration: widget.config.searchInputDecoration ??
                InputDecoration(
                  labelText: widget.config.searchHintText,
                  hintText: widget.config.searchHintText,
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xFFCBD0D6)),
                  ),
                ),
            onChanged: _filterCountries,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? Center(
                  child: widget.config.loadingIndicator ??
                      const CircularProgressIndicator(),
                )
              : _filteredList.isEmpty
                  ? Center(
                      child: Text(
                        widget.config.noCountriesFoundText,
                        style: widget.config.itemTextStyle,
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount: _filteredList.length,
                      separatorBuilder: (_, __) => widget.config.showSeparator
                          ? const Divider()
                          : const SizedBox(),
                      itemBuilder: (context, index) {
                        final country = _filteredList[index];

                        if (widget.config.itemBuilder != null) {
                          return InkWell(
                            onTap: () => widget.onSelected?.call(country),
                            child: widget.config.itemBuilder!(country),
                          );
                        }

                        return ListTile(
                          onTap: () {
                            selectedCountry = country;
                            widget.onSelected?.call(country);
                          },
                          leading: Image.asset(
                            country.localFlag,
                            package: countryCodePackageName,
                            width: widget.config.flagIconSize,
                            errorBuilder: (_, __, ___) => Image.asset(
                                placeholderImgPath,
                                package: countryCodePackageName,
                                width: widget.config.flagIconSize),
                          ),
                          title: Text(
                            country.nameTranslations[widget.locale] ??
                                country.name,
                            style: widget.config.itemTextStyle,
                          ),
                          trailing: widget.config.listWithCodes
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.config.showCountryCode)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          country.countryCode,
                                          style: widget.config.itemTextStyle
                                              .copyWith(
                                            color: const Color(0xFFCBD0D6),
                                          ),
                                        ),
                                      ),
                                    if (widget.config.showDialCode)
                                      Text(
                                        country.callingCode,
                                        style: widget.config.itemTextStyle
                                            .copyWith(
                                          color: const Color(0xFFCBD0D6),
                                        ),
                                      ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.cacheResults;
}
