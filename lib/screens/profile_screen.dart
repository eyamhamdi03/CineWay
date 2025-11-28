import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// theme colors are taken from ThemeData/colorScheme
import '../services/app_state.dart';
import 'profile_setup_screen.dart';
import 'package:cineway/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profile_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.person, color: colorScheme.onSurface)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.fullName ?? user?.email ?? 'Guest', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)), Text(user?.email ?? '', style: TextStyle(color: textColor.withOpacity(0.7)))])),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: user == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: user))),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(AppLocalizations.of(context)!.edit_profile),
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.surface),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.dark_mode, style: TextStyle(color: textColor)),
                subtitle: Text(AppLocalizations.of(context)!.dark_mode_sub, style: TextStyle(color: textColor.withOpacity(0.7))),
                trailing: Switch(
                  value: appState.isDark,
                  thumbColor: MaterialStateProperty.all(colorScheme.primary),
                  onChanged: (_) => appState.toggleTheme(),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.language, style: TextStyle(color: textColor)),
                subtitle: Text(AppLocalizations.of(context)!.language_sub, style: TextStyle(color: textColor.withOpacity(0.7))),
                trailing: DropdownButton<String>(
                  value: appState.language,
                  dropdownColor: Theme.of(context).dialogBackgroundColor,
                  items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'fr', child: Text('Français'))],
                  onChanged: (v) {
                    if (v != null) appState.setLanguage(v);
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  appState.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/get_started', (r) => false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.surface),
                child: Text(AppLocalizations.of(context)!.log_out, style: TextStyle(color: colorScheme.onSurface)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
