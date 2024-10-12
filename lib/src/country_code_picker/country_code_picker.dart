library countrycodepicker;

import 'package:dartarabic/dartarabic.dart';
import 'package:flutter/material.dart';
import 'package:country_code_helper/src/country_code_picker/country_code_helper.dart';

import 'country.dart';

// Default styles and parameters
const TextStyle _defaultItemTextStyle = TextStyle(fontSize: 16);
const TextStyle _defaultSearchInputStyle = TextStyle(fontSize: 16);
const String _kDefaultSearchHintText = 'Search country name, code';
const String countryCodePackageName = 'country_code_helper';
const String placeholderImgPath = 'flags/placeholder.png';

class CountryPickerWidget extends StatefulWidget {
  final ValueChanged<Country>? onSelected;
  final TextStyle itemTextStyle;
  final TextStyle searchInputStyle;
  final InputDecoration? searchInputDecoration;
  final double flagIconSize;
  final bool showSeparator;
  final bool focusSearchBox;
  final String searchHintText;
  final String locale;
  final bool listWithCodes;

  const CountryPickerWidget({
    Key? key,
    required this.locale,
    this.onSelected,
    this.itemTextStyle = _defaultItemTextStyle,
    this.searchInputStyle = _defaultSearchInputStyle,
    this.searchInputDecoration,
    this.searchHintText = _kDefaultSearchHintText,
    this.flagIconSize = 32,
    this.showSeparator = false,
    this.focusSearchBox = false,
    this.listWithCodes = true,
  }) : super(key: key);

  @override
  _CountryPickerWidgetState createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<Country> _list = [];
  List<Country> _filteredList = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Normalize text based on locale
  String _normalize(String text, String locale) {
    if (locale == 'ar') {
      return DartArabic.normalizeLetters(DartArabic.normalizeAlef(text)).toLowerCase();
    } else {
      return text.toLowerCase();
    }
  }

  // Handle search query updates
  void _onSearch(String text) {
    if (text.isEmpty) {
      setState(() {
        _filteredList = List.from(_list); // Reset to full list
      });
    } else {
      setState(() {
        final normalizedSearch = _normalize(text, widget.locale);
        _filteredList = _list.where((country) {
          final countryName = country.nameTranslations[widget.locale];
          return (countryName != null &&
                  _normalize(countryName, widget.locale).contains(normalizedSearch)) ||
              _normalize(country.name, widget.locale).contains(normalizedSearch) ||
              country.callingCode.contains(normalizedSearch) ||
              country.countryCode.startsWith(normalizedSearch);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCountryList();
    _scrollController.addListener(() {
      if (!FocusScope.of(context).hasPrimaryFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  // Load country data
  void _loadCountryList() {
    setState(() {
      _list = CountryCode.countries().values.toList();
      _filteredList = List.from(_list);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            controller: _controller,
            autofocus: widget.focusSearchBox,
            style: widget.searchInputStyle,
            decoration: widget.searchInputDecoration ??
                InputDecoration(
                  labelText: widget.searchHintText,
                  hintText: widget.searchHintText,
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _filteredList = List.from(_list);
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(width: 2, color: Color(0xFFCBD0D6)),
                  ),
                ),
            onChanged: _onSearch,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  controller: _scrollController,
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, __) =>
                      widget.showSeparator ? const Divider() : const SizedBox(),
                  itemBuilder: (context, index) {
                    final country = _filteredList[index];
                    return ListTile(
                      onTap: () => widget.onSelected?.call(country),
                      leading: Image.asset(
                        country.localFlag,
                        package: countryCodePackageName,
                        width: widget.flagIconSize,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(placeholderImgPath, width: widget.flagIconSize),
                      ),
                      title: Text(
                        country.nameTranslations[widget.locale] ?? country.name,
                        style: widget.itemTextStyle,
                      ),
                      trailing: Text(
                        widget.listWithCodes ? '+${country.callingCode}' : '',
                        style: widget.itemTextStyle.copyWith(color: const Color(0xFFCBD0D6)),
                      ),
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
}
