import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Color get _bg => const Color(0xFF0F1622);
  Color get _primary => const Color(0xFF55A6F6);
  Color get _textPrimary => const Color(0xFFF5F7F8);
  Color get _textSecondary => const Color(0xFF9CABB9);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF55A6F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.privacy_policy,
          style: const TextStyle(
            color: Color(0xFFF5F7F8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: _textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Collection
            _buildSection(
              icon: Icons.storage,
              title: '1. Data Collection',
              content:
                  'We collect information you provide directly to us when you create an account, purchase tickets, or communicate with us. This includes:',
              bulletPoints: [
                'Name, email address, and phone number',
                'Payment information (processed securely via encrypted providers)',
                'Movie preferences and booking history',
                'Device information and IP address',
              ],
            ),
            const SizedBox(height: 32),

            // How We Use Data
            _buildSection(
              icon: Icons.analytics_outlined,
              title: '2. How We Use Data',
              content:
                  'Your data allows us to provide a personalized cinema experience. We use your information to:',
              bulletPoints: [
                'Process your ticket and snack orders',
                'Send booking confirmations and digital tickets',
                'Provide recommendations based on your movie interests',
                'Improve our mobile application performance and UI',
              ],
            ),
            const SizedBox(height: 32),

            // Information Sharing
            _buildSection(
              icon: Icons.share_outlined,
              title: '3. Information Sharing',
              content:
                  'CineWay does not sell your personal data. We only share information with third parties in the following cases:',
              additionalContent:
                  'We share necessary booking details with cinema partners to facilitate your entry and seat allocation. We also use trusted payment processors and cloud infrastructure providers who adhere to strict security standards.',
            ),
            const SizedBox(height: 32),

            // Your Rights
            _buildSection(
              icon: Icons.verified_user_outlined,
              title: '4. Your Rights',
              content:
                  'You have full control over your personal information. Within the app settings, you can:',
              bulletPoints: [
                'Access and export your personal data',
                'Request the deletion of your account and related info',
                'Opt-out of marketing communications',
                'Update or correct inaccurate information',
              ],
            ),
            const SizedBox(height: 32),

            // Footer Info
            Container(
              padding: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Updated: January 23, 2026',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CineWay Privacy Office • privacy@cineway.app',
                    style: TextStyle(
                      color: _textSecondary.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // I Understand Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: _primary.withOpacity(0.3),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    List<String>? bulletPoints,
    String? additionalContent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 16),
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        if (additionalContent != null) ...[
          const SizedBox(height: 16),
          Text(
            additionalContent,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
