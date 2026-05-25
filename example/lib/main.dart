import 'package:country_code_helper/country_code_helper.dart';
import 'package:flutter/material.dart';
import 'package:sim_card_code/sim_card_code.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'country_code_helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Country? _country;
  Country? _restrictedCountry;
  final _phoneController = TextEditingController();
  String? _validationMessage;
  bool _isValid = false;

  static const _restrictedCodes = ['IQ', 'JO', 'SA', 'AE'];

  @override
  void initState() {
    super.initState();
    _initDefault();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initDefault() async {
    final country = await CountryCode.initCountry(
      preferred: const ['IQ', 'JO', 'SA'],
      regionResolver: () => SimCardManager.simCountryCode,
      fallback: CountryCode.getCountryByCountryCode('IQ'),
    );
    if (!mounted) return;
    setState(() {
      _country = country;
      _restrictedCountry = CountryCode.getCountryByCountryCode('IQ');
    });
  }

  Future<void> _pickOpen() async {
    final picked = await showCountryPickerSheet(
      context,
      selected: _country,
      priorityCodes: const ['IQ', 'JO', 'SA', 'AE'],
      title: 'Select country',
    );
    if (picked != null) setState(() => _country = picked);
  }

  Future<void> _pickLocked() async {
    final picked = await showCountryPickerSheet(
      context,
      selected: _restrictedCountry,
      priorityCodes: _restrictedCodes,
      showOnlyPriority: true,
      title: 'Allowed countries only',
    );
    if (picked != null) setState(() => _restrictedCountry = picked);
  }

  void _validate() {
    final region = _country?.countryCode;
    final number = _phoneController.text.trim();
    if (number.isEmpty) {
      setState(() {
        _isValid = false;
        _validationMessage = 'Enter a phone number';
      });
      return;
    }
    final ok = PhoneNumberTools.validate(
      '${_country?.callingCode ?? ''}$number',
      regionCode: region,
    );
    setState(() {
      _isValid = ok;
      _validationMessage = ok
          ? 'Valid number for ${_country?.name ?? region}'
          : 'Invalid number for ${_country?.name ?? region ?? '—'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('country_code_helper'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _SectionHeader(
            title: 'Open picker',
            subtitle: 'Full list. Priority codes pinned to top.',
          ),
          _CountryCard(country: _country, onTap: _pickOpen),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Restricted picker',
            subtitle: 'Locked to: ${_restrictedCodes.join(', ')}',
          ),
          _CountryCard(
            country: _restrictedCountry,
            onTap: _pickLocked,
            trailingLabel: 'Locked',
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Phone field with prefix',
            subtitle: 'Tap the flag to swap country.',
          ),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _validate(),
            decoration: InputDecoration(
              labelText: 'Phone number',
              hintText: '7701234567',
              border: const OutlineInputBorder(),
              prefixIcon: CountryCodePrefix(
                country: _country,
                priorityCodes: const ['IQ', 'JO', 'SA', 'AE'],
                onChanged: (c) => setState(() => _country = c),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _validate,
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Validate'),
          ),
          if (_validationMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isValid
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isValid
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: _isValid
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationMessage!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Region presets',
            subtitle: 'Built-in ISO code lists.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RegionChip(label: 'Arab', count: CountryCode.arab.length),
              _RegionChip(
                label: 'West EU',
                count: CountryCode.westernEuropean.length,
              ),
              _RegionChip(
                label: 'East EU',
                count: CountryCode.easternEuropean.length,
              ),
              _RegionChip(label: 'Stan', count: CountryCode.stan.length),
              _RegionChip(label: 'Africa', count: CountryCode.african.length),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final Country? country;
  final VoidCallback onTap;
  final String? trailingLabel;

  const _CountryCard({
    required this.country,
    required this.onTap,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: country == null
            ? const Icon(Icons.public_rounded)
            : ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  country!.localFlag,
                  package: countryCodePackageName,
                  width: 36,
                  height: 27,
                  fit: BoxFit.cover,
                ),
              ),
        title: Text(country?.name ?? 'No country selected'),
        subtitle: Text(
          country == null
              ? 'Tap to pick'
              : '${country!.countryCode} • ${country!.callingCode}',
        ),
        trailing: trailingLabel == null
            ? const Icon(Icons.chevron_right_rounded)
            : Chip(
                label: Text(trailingLabel!),
                visualDensity: VisualDensity.compact,
              ),
        onTap: onTap,
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final int count;
  const _RegionChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        child: Text(
          count.toString(),
          style: const TextStyle(fontSize: 11),
        ),
      ),
      label: Text(label),
    );
  }
}
