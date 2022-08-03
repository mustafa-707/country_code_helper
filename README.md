# flutter_country_code

Searchable country picker service with sim card detect , copied from `https://github.com/dev-naiksan/country-calling-code-picker`

1: Import the plugin using

```dart
 import 'package:flutter_country_code/picker.dart';
```

2: trigger the service by default country.

```dart
  void initCountry() async {
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
  }
```

3: Use widget `CountryPickerWidget` to get the list of the countries.

```dart
void _showCountryPicker() async{
    final country = await showCountryPickerSheet(context,);
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
}
```

4: support locale by trigger :

```dart
 locale: Localizations.localeOf(context).languageCode,} //in CountryPickerWidget
 //or
 _selectedCountry.nameTranslations['en'] // it can be jp , ar ..etc

```

5: If you just need the list of countries for making your own custom country picker, you can all getCountries() which returns list of countries.

```dart
List<Country> list = await getCountries(context);
```

6: If you want to get flag from the country code, you can use below method to get country using the country code.
   Eg. for getting India's flag,

```dart
Country country = await getCountryByCountryCode(context, 'IN');
```
