import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../services/app_state.dart';
import 'profile_setup_screen.dart';
import '../services/i18n.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(title: Text(I18n.t(context, 'profile_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF101418), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.jumbo)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.fullName ?? user?.email ?? 'Guest', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)), Text(user?.email ?? '', style: const TextStyle(color: AppColors.jumbo))])),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: user == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: user))),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(I18n.t(context, 'edit_profile')),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2933)),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              ListTile(
                title: Text(I18n.t(context, 'dark_mode'), style: const TextStyle(color: Colors.white)),
                subtitle: Text(I18n.t(context, 'dark_mode_sub'), style: const TextStyle(color: AppColors.jumbo)),
                trailing: Switch(value: appState.isDark, activeColor: AppColors.dodgerBlue, onChanged: (_) => appState.toggleTheme()),
              ),
              ListTile(
                title: Text(I18n.t(context, 'language'), style: const TextStyle(color: Colors.white)),
                subtitle: Text(I18n.t(context, 'language_sub'), style: const TextStyle(color: AppColors.jumbo)),
                trailing: DropdownButton<String>(
                  value: appState.language,
                  dropdownColor: const Color(0xFF141A20),
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
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2933)),
                child: Text(I18n.t(context, 'log_out'), style: const TextStyle(color: AppColors.jumbo)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
