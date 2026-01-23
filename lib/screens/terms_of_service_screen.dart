import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _agreedToTerms = false;

  Color get _bg => const Color(0xFF0F1622);
  Color get _card => const Color(0xFF18232E);
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
          localizations.terms_of_service,
          style: const TextStyle(
            color: Color(0xFFF5F7F8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revised Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'REVISED JAN 2026',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Please read carefully',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By using CineWay, you agree to follow the terms below. These govern your legal relationship with our platform.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Acceptance of Agreement
                _buildSection(
                  icon: Icons.gavel,
                  title: 'Acceptance of Agreement',
                  content: [
                    'This Terms of Service agreement is a legally binding contract between you and CineWay regarding your use of our mobile application and services.',
                    'If you are using the app on behalf of an entity, you represent and warrant that you have the authority to bind that entity to these terms.',
                  ],
                ),
                const SizedBox(height: 40),

                // Ticketing Policy
                _buildSection(
                  icon: Icons.confirmation_num,
                  title: 'Ticketing Policy',
                  content: [
                    'CineWay provides a digital marketplace for cinema tickets. We facilitate transactions but do not own the cinemas or determine screening schedules.',
                  ],
                  bulletPoints: [
                    'Seats are locked for 10 minutes during checkout.',
                    'QR codes are only valid for a single entry.',
                    'Promotional codes cannot be combined.',
                  ],
                ),
                const SizedBox(height: 40),

                // Payments & Billing
                _buildSection(
                  icon: Icons.payment,
                  title: 'Payments & Billing',
                  content: [
                    'All prices are inclusive of VAT unless stated otherwise. A convenience fee is applied to each transaction to maintain our platform infrastructure.',
                  ],
                  highlightedText:
                      '"Refunds are processed within 48 hours for cancelled screenings or technical errors on our end."',
                ),
                const SizedBox(height: 40),

                // User Conduct
                _buildSection(
                  icon: Icons.shield_outlined,
                  title: 'User Conduct',
                  content: [
                    'Users must provide accurate information. Any attempt to bypass security measures or scrape data from the CineWay platform will result in immediate account termination.',
                  ],
                ),
                const SizedBox(height: 40),

                // Footer Info
                Container(
                  padding: const EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CineWay Digital Services LLC',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '123 Cinema Plaza, San Francisco, CA 94103',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'For legal inquiries: legal@cineway.app',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Agreement Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _bg.withOpacity(0.9),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreedToTerms = !_agreedToTerms;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: _agreedToTerms ? _primary : Colors.transparent,
                            border: Border.all(
                              color: _agreedToTerms
                                  ? _primary
                                  : Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I confirm that I have read and agree to be bound by the CineWay Terms of Service and Privacy Policy.',
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
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms
                          ? () => Navigator.pop(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agreedToTerms ? _primary : _card,
                        disabledBackgroundColor: _card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: _agreedToTerms ? 10 : 0,
                        shadowColor: _primary.withOpacity(0.3),
                      ),
                      child: Text(
                        'Agree and Continue',
                        style: TextStyle(
                          color: _agreedToTerms ? Colors.white : _textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> content,
    List<String>? bulletPoints,
    String? highlightedText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _card,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                text,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            )),
        if (bulletPoints != null) ...[
          const SizedBox(height: 4),
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: _primary, size: 18),
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
        if (highlightedText != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.5),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              highlightedText,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
