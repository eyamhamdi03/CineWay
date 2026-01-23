import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
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
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF55A6F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.payment_methods,
          style: const TextStyle(
            color: Color(0xFFF5F7F8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFFF5F7F8)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CineWay Credits Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, const Color(0xFF2E7FD6)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CineWay Credits',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$124.75',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE MEMBER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Saved Cards Section
            _sectionHeader(localizations.saved_cards),
            const SizedBox(height: 12),
            _paymentCard(
              cardName: 'Visa Platinum',
              cardNumber: '**** 4242',
              icon: Icons.credit_card,
              isDefault: true,
            ),
            const SizedBox(height: 12),
            _paymentCard(
              cardName: 'Mastercard Gold',
              cardNumber: '**** 8812',
              icon: Icons.credit_card,
              isDefault: false,
            ),
            const SizedBox(height: 12),
            _paymentCard(
              cardName: 'Digital Wallet',
              cardNumber: 'Apple Pay',
              icon: Icons.account_balance_wallet,
              isDefault: false,
            ),
            const SizedBox(height: 24),

            // Add New Method Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: _primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      localizations.add_new_method,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Other Options Section
            _sectionHeader(localizations.other_options),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _optionButton(
                      icon: Icons.receipt_long,
                      label: localizations.transaction_history,
                      onTap: () {},
                    ),
                    _divider(),
                    _optionButton(
                      icon: Icons.card_giftcard,
                      label: localizations.redeem_gift_card,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer Text
            Center(
              child: Text(
                'Your payment information is encrypted and securely stored.\nCineWay does not share your card details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String cardName,
    required String cardNumber,
    required IconData icon,
    required bool isDefault,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cardNumber,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'DEFAULT',
                style: TextStyle(
                  color: _primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: _textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: _textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withOpacity(0.06),
      );
}
