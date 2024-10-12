library countrycodepicker;

import 'package:dartarabic/dartarabic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:country_code_helper/src/country_code_picker/country_code_helper.dart';

import 'country.dart';

const TextStyle _defaultItemTextStyle = const TextStyle(fontSize: 16);
const TextStyle _defaultSearchInputStyle = const TextStyle(fontSize: 16);
const String _kDefaultSearchHintText = 'Search country name, code';
const String countryCodePackageName = 'country_code_helper';
const String placeholderImgPath = 'flags/placeholder.png';

class CountryPickerWidget extends StatefulWidget {
  /// This callback will be called on selection of a [Country].
  final ValueChanged<Country>? onSelected;

  /// [itemTextStyle] can be used to change the TextStyle of the Text in ListItem. Default is [_defaultItemTextStyle]
  final TextStyle itemTextStyle;

  /// [searchInputStyle] can be used to change the TextStyle of the Text in SearchBox. Default is [searchInputStyle]
  final TextStyle searchInputStyle;

  /// [searchInputDecoration] can be used to change the decoration for SearchBox.
  final InputDecoration? searchInputDecoration;

  /// Flag icon size (width). Default set to 32.
  final double flagIconSize;

  ///Can be set to `true` for showing the List Separator. Default set to `false`
  final bool showSeparator;

  ///Can be set to `true` for opening the keyboard automatically. Default set to `false`
  final bool focusSearchBox;

  ///This will change the hint of the search box. Alternatively [searchInputDecoration] can be used to change decoration fully.
  final String searchHintText;

  ///pass the current locale String to translate the countries name.
  final String locale;

  ///pass the current locale String to translate the countries name.
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
  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;

  String _normalize(String text, String locale) {
    if (locale == 'ar') {
      return DartArabic.normalizeLetters(
        DartArabic.normalizeAlef(text),
      ).toLowerCase();
    } else {
      return text.toLowerCase();
    }
  }

  void _onSearch(String text) {
    if (text.isEmpty) {
      setState(() {
        _filteredList.clear();
        _filteredList.addAll(_list);
      });
    } else {
      setState(() {
        _filteredList = _list
            .where((element) {
              final countryName = element.nameTranslations[widget.locale];
              final normalizedSearch = _normalize(text, widget.locale);

              return countryName != null &&
                      _normalize(countryName, widget.locale).contains(normalizedSearch) ||
                  _normalize(element.name, widget.locale).contains(normalizedSearch) ||
                  element.callingCode.contains(normalizedSearch) ||
                  element.countryCode.startsWith(normalizedSearch);
            })
            .map((e) => e)
            .toList();
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
    loadList();
    super.initState();
  }

  void loadList() {
    CountryCode.countries().forEach((key, value) {
      _list.add(value);
    });

    setState(() {
      _filteredList = _list.map((e) => e).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Container(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: TextFormField(
            style: widget.searchInputStyle,
            autofocus: widget.focusSearchBox,
            maxLines: 1,
            autocorrect: false,
            decoration: widget.searchInputDecoration ??
                InputDecoration(
                  suffixIcon: Visibility(
                    visible: _controller.text.isNotEmpty,
                    child: InkWell(
                      child: Icon(Icons.clear_rounded),
                      onTap: () => setState(() {
                        _controller.clear();
                        _filteredList.clear();
                        _filteredList.addAll(_list);
                      }),
                    ),
                  ),
                  counterText: '',
                  labelText: widget.searchHintText,
                  hintText: widget.searchHintText,
                  errorMaxLines: 1,
                  errorStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onError,
                    height: 0.8,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Color(0xFFCBD0D6),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
            textInputAction: TextInputAction.done,
            controller: _controller,
            onChanged: _onSearch,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: EdgeInsets.only(top: 16),
                  controller: _scrollController,
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, index) => widget.showSeparator ? Divider() : Container(),
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () {
                        widget.onSelected?.call(_filteredList[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: 12,
                          top: 12,
                          left: 24,
                          right: 24,
                        ),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              _filteredList[index].localFlag,
                              package: countryCodePackageName,
                              width: widget.flagIconSize,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text(
                                '${_filteredList[index].nameTranslations['${widget.locale}']}',
                                textAlign: TextAlign.start,
                                style: widget.itemTextStyle,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${Unicode.LRM}${widget.listWithCodes ? _filteredList[index].callingCode + ' ' : ''}',
                              textAlign: TextAlign.end,
                              style: widget.itemTextStyle.copyWith(
                                color: Color(0xFFCBD0D6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        )
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
