import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentLang = Localizations.localeOf(context).languageCode;
    final appName = dotenv.env['APP_NAME'] ?? 'SurfShop admin panel';

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Text(
            loc.translate('settings_language'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text('English'),
            trailing: currentLang == 'en' ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, 'en'),
          ),
          ListTile(
            title: const Text('Español'),
            trailing: currentLang == 'es' ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, 'es'),
          ),

          const Divider(height: 32),

          // You can add more settings here:
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.translate('settings_about')),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: appName,
                applicationVersion: '1.0.0',
                children: [Text(loc.translate('settings_about_description'))],
              );
            },
          ),
        ],
      ),
    );
  }
}
