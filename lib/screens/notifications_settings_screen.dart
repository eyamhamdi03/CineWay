import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _newMovies = true;
  bool _showtimeReminders = true;
  bool _promotions = false;
  bool _ticketUpdates = true;

  Color get _bg => const Color(0xFF0F1622);
  Color get _card => const Color(0xFF18232E);
  Color get _primary => const Color(0xFF55A6F6);
  Color get _textPrimary => const Color(0xFFF5F7F8);
  Color get _textSecondary => const Color(0xFF9CABB9);

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          AppLocalizations.of(context)!.notification_settings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  AppLocalizations.of(context)!.customize_notifications,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              _sectionTitle(AppLocalizations.of(context)!.activity_alerts),
              _cardSurface([
                _toggleItem(
                  icon: Icons.movie,
                  title: AppLocalizations.of(context)!.new_movies,
                  subtitle: AppLocalizations.of(context)!.new_movies_desc,
                  value: _newMovies,
                  onChanged: (v) => setState(() => _newMovies = v),
                ),
                _divider(),
                _toggleItem(
                  icon: Icons.schedule,
                  title: AppLocalizations.of(context)!.showtime_reminders,
                  subtitle: AppLocalizations.of(context)!.showtime_reminders_desc,
                  value: _showtimeReminders,
                  onChanged: (v) => setState(() => _showtimeReminders = v),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionTitle(AppLocalizations.of(context)!.marketing_updates),
              _cardSurface([
                _toggleItem(
                  icon: Icons.local_offer,
                  title: AppLocalizations.of(context)!.promotions,
                  subtitle: AppLocalizations.of(context)!.promotions_desc,
                  value: _promotions,
                  onChanged: (v) => setState(() => _promotions = v),
                ),
                _divider(),
                _toggleItem(
                  icon: Icons.confirmation_number,
                  title: AppLocalizations.of(context)!.ticket_updates,
                  subtitle: AppLocalizations.of(context)!.ticket_updates_desc,
                  value: _ticketUpdates,
                  onChanged: (v) => setState(() => _ticketUpdates = v),
                ),
              ]),
              const SizedBox(height: 24),
              _infoBox(AppLocalizations.of(context)!),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'CineWay Notification Manager',
                  style: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: _textSecondary,
          fontSize: 11,
          letterSpacing: 1.2,
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

  Widget _toggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withOpacity(0.06),
      );

  Widget _infoBox(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.08),
        border: Border.all(color: _primary.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.critical_alerts_text,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
