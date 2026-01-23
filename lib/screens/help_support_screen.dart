import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late TextEditingController _searchController;
  int? _expandedFaqIndex;

  Color get _bg => const Color(0xFF0F1622);
  Color get _card => const Color(0xFF18232E);
  Color get _primary => const Color(0xFF55A6F6);
  Color get _textPrimary => const Color(0xFFF5F7F8);
  Color get _textSecondary => const Color(0xFF9CABB9);

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I cancel my booking?',
      'answer':
          'You can cancel your booking up to 2 hours before showtime. Go to "My Bookings", select your ticket, and tap "Cancel Booking". Refunds are processed within 5-7 business days.'
    },
    {
      'question': 'Can I change my seat after purchase?',
      'answer':
          'Yes, you can change seats up to 1 hour before showtime if available. Go to your booking details and tap "Change Seats" to select new ones.'
    },
    {
      'question': 'Refund policy for late arrivals',
      'answer':
          'Unfortunately, we cannot offer refunds for late arrivals. Please arrive at least 15 minutes before showtime to ensure entry.'
    },
    {
      'question': 'Where can I find my e-ticket?',
      'answer':
          'Your e-ticket is available in the "My Bookings" section. You can also access it from the confirmation email sent to your registered email address.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getCategoryIcon(title), color: _primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactSupportDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chat_bubble, color: _primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Contact Support',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'Your Name', Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField(emailController, 'Email Address', Icons.email_outlined),
                const SizedBox(height: 12),
                _buildTextField(
                  messageController,
                  'Describe your issue...',
                  Icons.message_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          nameController.dispose();
                          emailController.dispose();
                          messageController.dispose();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _textSecondary.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Here you would send the support request
                          nameController.dispose();
                          emailController.dispose();
                          messageController.dispose();
                          Navigator.pop(context);
                          _showSuccessDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Message Sent!',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our support team will get back to you within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Booking Issues':
        return Icons.confirmation_num;
      case 'Account Help':
        return Icons.account_circle;
      case 'Payments':
        return Icons.payment;
      case 'Cinema Info':
        return Icons.movie;
      default:
        return Icons.help_outline;
    }
  }

  String _getCategoryContent(String title) {
    switch (title) {
      case 'Booking Issues':
        return 'Get help with booking tickets, seat selection, show times, and ticket modifications. We\'re here to ensure your booking experience is smooth.';
      case 'Account Help':
        return 'Need help with your account? Manage your profile, update preferences, reset password, or modify your personal information.';
      case 'Payments':
        return 'Questions about payment methods, refunds, or billing? We support multiple payment options and ensure secure transactions.';
      case 'Cinema Info':
        return 'Find information about cinema locations, facilities, accessibility features, and available amenities at our theaters.';
      default:
        return 'How can we help you today?';
    }
  }

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
          localizations.help_support,
          style: const TextStyle(
            color: Color(0xFFF5F7F8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: localizations.search_for_help,
                    hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: _textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Categories
              _sectionHeader(localizations.categories),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _categoryCard('Booking Issues', Icons.confirmation_num),
                  _categoryCard('Account Help', Icons.account_circle),
                  _categoryCard('Payments', Icons.payment),
                  _categoryCard('Cinema Info', Icons.movie),
                ],
              ),
              const SizedBox(height: 32),

              // Popular FAQs
              _sectionHeader(localizations.popular_faqs),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: List.generate(_faqs.length, (index) {
                    final isExpanded = _expandedFaqIndex == index;
                    return Column(
                      children: [
                        if (index > 0)
                          Container(
                            height: 1,
                            margin: const EdgeInsets.only(left: 16),
                            color: Colors.white.withOpacity(0.05),
                          ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _expandedFaqIndex = isExpanded ? null : index;
                              });
                            },
                            borderRadius: BorderRadius.vertical(
                              top: index == 0 ? const Radius.circular(20) : Radius.zero,
                              bottom: index == _faqs.length - 1 && !isExpanded
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _faqs[index]['question']!,
                                          style: TextStyle(
                                            color: _textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.remove : Icons.add,
                                        color: _textSecondary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      _faqs[index]['answer']!,
                                      style: TextStyle(
                                        color: _textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              // Still Need Help
              Container(
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      localizations.still_need_help,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.support_team_available,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showContactSupportDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: _primary.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contact Support',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      localizations.privacy_policy,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSecondary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      localizations.terms_of_service,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer Text
              Center(
                child: Text(
                  'CineWay Support Center v1.2',
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  Widget _categoryCard(String title, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCategoryDialog(title, _getCategoryContent(title)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
