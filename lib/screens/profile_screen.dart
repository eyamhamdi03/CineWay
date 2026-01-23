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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Color get _bg => const Color(0xFF0F1622);
  Color get _card => const Color(0xFF18232E);
  Color get _primary => const Color(0xFF55A6F6);
  Color get _textPrimary => const Color(0xFFF5F7F8);
  Color get _textSecondary => const Color(0xFF9CABB9);

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final appState = context.watch<AppState>();
    final user = session.user;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(localizations.profile_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 24),
              _sectionTitle(localizations.preferences.toUpperCase()),
              _cardSurface([
                _switchRow(
                  icon: Icons.dark_mode,
                  label: localizations.dark_mode,
                  value: settings.isDark,
                  onChanged: (_) => settings.toggleTheme(),
                ),
                _divider(),
                _rowItem(
                  icon: Icons.language,
                  label: localizations.language,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.language == 'fr' ? 'Français' : 'English',
                        style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: _textSecondary),
                    ],
                  ),
                  onTap: () => _showLanguageSheet(context, settings),
                ),
                _divider(),
                _rowItem(
                  icon: Icons.notifications,
                  label: localizations.notifications,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle(localizations.payments.toUpperCase()),
              _cardSurface([
                _rowItem(
                  icon: Icons.credit_card,
                  label: localizations.payment_methods,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                ),
                _divider(),
                _rowItem(
                  icon: Icons.receipt_long,
                  label: localizations.purchase_history,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen())),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle(localizations.support_legal.toUpperCase()),
              _cardSurface([
                _rowItem(
                  icon: Icons.help_outline,
                  label: localizations.help_support,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
                _divider(),
                _rowItem(
                  icon: Icons.gavel,
                  label: localizations.terms_of_service,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                ),
                _divider(),
                _rowItem(
                  icon: Icons.privacy_tip,
                  label: localizations.privacy_policy,
                  trailing: Icon(Icons.chevron_right, color: _textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                ),
              ]),
              const SizedBox(height: 28),
              _primaryButton(
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
              _textButton(localizations.delete_account, Colors.redAccent, onTap: () {}),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'CineWay Version 2.4.0',
                  style: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 11),
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
                border: Border.all(color: _card, width: 4),
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
                  color: _primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 3),
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
          style: TextStyle(color: _textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.2),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'guest@cineway.com',
          style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: _textSecondary,
          fontSize: 11,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _cardSurface(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(children: children),
    );
  }

  Widget _rowItem({required IconData icon, required String label, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.white.withOpacity(0.04),
      splashColor: Colors.white.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: _primary.withOpacity(0.16), shape: BoxShape.circle),
              child: Icon(icon, color: _primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _primary.withOpacity(0.16), shape: BoxShape.circle),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.white.withOpacity(0.06));

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _card,
          foregroundColor: _primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(color: _primary, fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _textButton(String label, Color color, {VoidCallback? onTap}) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context, SettingsViewModel settings) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: Text('English', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700)),
              trailing: settings.language == 'en' ? Icon(Icons.check, color: _primary) : null,
              onTap: () {
                settings.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: Text('Français', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700)),
              trailing: settings.language == 'fr' ? Icon(Icons.check, color: _primary) : null,
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
