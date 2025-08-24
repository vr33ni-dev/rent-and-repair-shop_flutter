import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/env/env.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _rentalFeeController = TextEditingController();
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadRentalFee();
  }

  Future<void> _loadRentalFee() async {
    try {
      final fee = await ApiService().fetchDefaultRentalFee();
      if (fee != null) {
        _rentalFeeController.text = fee.toStringAsFixed(2);
      }
    } catch (e) {
      print('❌ Failed to load rental fee: $e');
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _updateRentalFee() async {
    final loc = AppLocalizations.of(context);
    final newFee = double.tryParse(_rentalFeeController.text.trim());
    if (newFee == null) return;

    setState(() => _isLoading = true);
    final success = await ApiService().updateDefaultRentalFee(newFee);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? loc.translate('settings_fee_updated')
              : loc.translate('settings_fee_update_failed'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentLang = Localizations.localeOf(context).languageCode;
    final appName = Env.appName;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings_title'))),
      body:
          _isFetching
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('settings_language'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListTile(
                    title: const Text('English'),
                    trailing:
                        currentLang == 'en' ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, 'en'),
                  ),
                  ListTile(
                    title: const Text('Español'),
                    trailing:
                        currentLang == 'es' ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, 'es'),
                  ),

                  const Divider(height: 32),

                  Text(
                    loc.translate('settings_rental_fee_label'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: _rentalFeeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: loc.translate('settings_rental_fee_label'),
                      suffixIcon:
                          _isLoading
                              ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: _updateRentalFee,
                              ),
                    ),
                  ),

                  const Divider(height: 32),

                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(loc.translate('settings_about')),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: appName,
                        applicationVersion: '1.0.0',
                        children: [
                          Text(loc.translate('settings_about_description')),
                        ],
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
