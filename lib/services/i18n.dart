import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class I18n {
  static const Map<String, Map<String, String>> _t = {
    'en': {
      'profile_title': 'Profile',
      'dark_mode': 'Dark Mode',
      'dark_mode_sub': 'Toggle app theme',
      'language': 'Language',
      'language_sub': 'English / Français',
      'log_out': 'Log Out',
      'edit_profile': 'Edit Profile',
      'create_profile': 'Create Your Profile',
      'complete_profile': 'Complete Profile',
    },
    'fr': {
      'profile_title': 'Profil',
      'dark_mode': 'Mode sombre',
      'dark_mode_sub': "Basculer le thème de l'application",
      'language': 'Langue',
      'language_sub': 'Anglais / Français',
      'log_out': 'Se déconnecter',
      'edit_profile': "Modifier le profil",
      'create_profile': 'Créez votre profil',
      'complete_profile': 'Terminer le profil',
    }
  };

  static String t(BuildContext context, String key) {
    final state = Provider.of<AppState>(context, listen: false);
    final lang = state.language;
    return _t[lang]?[key] ?? _t['en']![key] ?? key;
  }
}
