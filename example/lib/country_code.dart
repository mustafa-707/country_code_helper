import 'package:flutter/material.dart';
import 'package:flutter_country_code/flutter_country_code.dart';

class CountryCode extends StatefulWidget {
  const CountryCode({Key? key}) : super(key: key);

  @override
  State<CountryCode> createState() => _CountryCodeState();
}

class _CountryCodeState extends State<CountryCode> {
  Future<List<Country>> getCountriesByPackage() async {
    return (await getCountries(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<List<Country>>(
        future: getCountriesByPackage(),
        builder: (context, snap) {
          if (snap.hasData) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),
                  Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 18, right: 18),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'select',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CountryPickerWidget(
                      onSelected: (country) =>
                          Navigator.of(context).pop(country),
                      searchHintText: 'search',
                      locale: Localizations.localeOf(context).languageCode,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
