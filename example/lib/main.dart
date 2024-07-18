import 'package:example/bottom_sheet.dart';
import 'package:example/country_code.dart';
import 'package:flutter/material.dart';
import 'package:country_code_helper/country_code_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'country_code_helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'country_code_helper example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Country? _selectedCountry;

  Future<void> _initCountry() async {
    try {
      final country = await CountryCode.initCountry(
        exclude: [
          'SA',
          'JO',
        ],
        prefered: [
          'JO',
          'SA',
        ],
      );
      if (mounted) {
        setState(() {
          _selectedCountry = country;
        });
      }
    } catch (e) {
      return;
    }
  }

  void _showCountryPicker() async {
    final country = await showSheetPage<Country>(
      context: context,
      isModal: false,
      enableDrag: false,
      builder: (_) => const CountryCodeWidget(),
    );
    if (country != null && mounted) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  @override
  void initState() {
    _initCountry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${_selectedCountry?.name ?? "no country"}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 12),
            Image.asset(
              _selectedCountry?.flag ?? placeholderImgPath,
              package: countryCodePackageName,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCountryPicker,
        tooltip: 'select country',
        child: const Icon(Icons.add),
      ),
    );
  }
}
