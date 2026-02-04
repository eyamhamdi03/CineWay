import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../viewmodel/auth_view_model.dart';
import '../viewmodel/session/session_viewmodel.dart';
import '../viewmodel/settings/settings_viewmodel.dart';
import 'notifications_settings_screen.dart';
import 'payment_methods_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_setup_screen.dart';
import 'purchase_history_screen.dart';
import 'help_support_screen.dart';
import 'terms_of_service_screen.dart';
import 'liked_movies_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Color _bg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F1622) : const Color(0xFFF7F8FA);
  }

  Color _card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF18232E) : Colors.white;
  }

  Color _primary() => const Color(0xFF55A6F6);

  Color _textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF5F7F8) : const Color(0xFF0F172A);
  }

  Color _textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9CABB9) : const Color(0xFF64748B);
  }

  Color _iconColor(BuildContext context) => _textPrimary(context);

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final appState = context.watch<AppState>();
    final user = session.user;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _iconColor(context)),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: 0,
          ),
        ),
        title: Text(
          localizations.profile_title,
          style: TextStyle(color: _textPrimary(context), fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 24),
              _sectionTitle(context, localizations.preferences.toUpperCase()),
              _cardSurface(context, [
                _rowItem(
                  context,
                  icon: Icons.favorite,
                  label: '${(user?.fullName?.isNotEmpty == true ? user!.fullName : 'User')} Movies',
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedMoviesScreen())),
                ),
                _divider(context),
                _switchRow(
                  context,
                  icon: Icons.dark_mode,
                  label: localizations.dark_mode,
                  value: settings.isDark,
                  onChanged: (_) => settings.toggleTheme(),
                ),
                _divider(context),
                _rowItem(
                  context,
                  icon: Icons.language,
                  label: localizations.language,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.language == 'fr' ? 'Français' : 'English',
                        style: TextStyle(color: _textSecondary(context), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: _textSecondary(context)),
                    ],
                  ),
                  onTap: () => _showLanguageSheet(context, settings),
                ),
                _divider(context),
                _rowItem(
                  context,
                  icon: Icons.notifications,
                  label: localizations.notifications,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle(context, localizations.payments.toUpperCase()),
              _cardSurface(context, [
                _rowItem(
                  context,
                  icon: Icons.credit_card,
                  label: localizations.payment_methods,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                ),
                _divider(context),
                _rowItem(
                  context,
                  icon: Icons.receipt_long,
                  label: localizations.purchase_history,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen())),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle(context, localizations.support_legal.toUpperCase()),
              _cardSurface(context, [
                _rowItem(
                  context,
                  icon: Icons.help_outline,
                  label: localizations.help_support,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
                _divider(context),
                _rowItem(
                  context,
                  icon: Icons.gavel,
                  label: localizations.terms_of_service,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                ),
                _divider(context),
                _rowItem(
                  context,
                  icon: Icons.privacy_tip,
                  label: localizations.privacy_policy,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary(context)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                ),
              ]),
              const SizedBox(height: 28),
              _primaryButton(
                context,
                label: localizations.log_out,
                onTap: () async {
                  await context.read<AuthViewModel>().signOut();
                  await context.read<SessionViewModel>().signOut();
                  appState.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamedAndRemoveUntil(context, '/get_started', (r) => false);
                },
              ),
              const SizedBox(height: 12),
              _textButton(context, localizations.delete_account, Colors.redAccent, onTap: () {}),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'CineWay Version 2.4.0',
                  style: TextStyle(color: _textSecondary(context).withOpacity(0.6), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9D3BE),
                border: Border.all(color: _card(context), width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: const Icon(Icons.person, size: 58, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: user))),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary(),
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg(context), width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          (user?.fullName?.isNotEmpty ?? false) ? user!.fullName! : 'Guest',
          style: TextStyle(color: _textPrimary(context), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.2),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'guest@cineway.com',
          style: TextStyle(color: _textSecondary(context), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: _textSecondary(context),
          fontSize: 11,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _cardSurface(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _rowItem(BuildContext context, {required IconData icon, required String label, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.04),
      splashColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: _primary().withOpacity(0.16), shape: BoxShape.circle),
              child: Icon(icon, color: _primary(), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: _textPrimary(context), fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(BuildContext context, {required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _primary().withOpacity(0.16), shape: BoxShape.circle),
            child: Icon(icon, color: _primary(), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: TextStyle(color: _textPrimary(context), fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _primary(),
            inactiveThumbColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF475569),
            inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.06),
      );

  Widget _primaryButton(BuildContext context, {required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _card(context),
          foregroundColor: _primary(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(color: _primary(), fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _textButton(BuildContext context, String label, Color color, {VoidCallback? onTap}) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context, SettingsViewModel settings) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: _card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language, color: _textPrimary(context)),
              title: Text('English', style: TextStyle(color: _textPrimary(context), fontWeight: FontWeight.w700)),
              trailing: settings.language == 'en' ? Icon(Icons.check, color: _primary()) : null,
              onTap: () {
                settings.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: _textPrimary(context)),
              title: Text('Français', style: TextStyle(color: _textPrimary(context), fontWeight: FontWeight.w700)),
              trailing: settings.language == 'fr' ? Icon(Icons.check, color: _primary()) : null,
              onTap: () {
                settings.setLanguage('fr');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
