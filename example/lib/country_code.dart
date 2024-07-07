import 'package:flutter/material.dart';
import 'package:country_code_helper/country_code_helper.dart';

class CountryCodeWidget extends StatefulWidget {
  const CountryCodeWidget({Key? key}) : super(key: key);

  @override
  State<CountryCodeWidget> createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
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
                onSelected: (country) => Navigator.of(context).pop(country),
                searchHintText: 'search',
                locale: Localizations.localeOf(context).languageCode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
