import 'package:flutter/material.dart';
import '../core/colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _cardController = TextEditingController(text: '**** **** **** 1234');
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  int _selectedMethod = 0; // 0 = card, 1 = wallet
  bool _saveCard = true;

  final double _amount = 25.50;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _selectMethod(int index) => setState(() => _selectedMethod = index);

  void _pay() {
    if (_selectedMethod == 0) {
      // If card selected, require form valid
      if (!_formKey.currentState!.validate()) return;
    }

    // Demo success
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful (demo)')));
  }

  Widget _methodTile({required IconData icon, required String title, required String subtitle, required int index}) {
    final selected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => _selectMethod(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E21),
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.dodgerBlue, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: const Color(0xFF213036), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.dodgerBlue, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.jumbo)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.dodgerBlue : Colors.white24, width: selected ? 6 : 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.mirageLight),
      filled: true,
      fillColor: const Color(0xFF141414),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.jumbo) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFF1F2426), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: const Color(0xFF213036), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long, color: AppColors.dodgerBlue, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Amount to Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    Text('\$${_amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text('Select Payment Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 12),
              _methodTile(icon: Icons.credit_card, title: 'Credit / Debit Card', subtitle: 'Visa, Mastercard, Amex', index: 0),
              const SizedBox(height: 10),
              _methodTile(icon: Icons.account_balance_wallet, title: 'Digital Wallets', subtitle: 'Google Pay, Apple Pay', index: 1),

              const SizedBox(height: 18),
              if (_selectedMethod == 0) ...[
                const Text('Card Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration(hint: 'Cardholder Name', icon: Icons.person_outline),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter cardholder name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cardController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration(hint: 'Card Number', icon: Icons.credit_card),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter card number' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _expiryController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecoration(hint: 'MM/YY', icon: Icons.calendar_today_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter expiry' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _cvvController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecoration(hint: 'CVV', icon: Icons.lock_outline),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter CVV' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Save card for future use', style: TextStyle(color: Colors.white)),
                          Switch(
                            value: _saveCard,
                            activeColor: AppColors.dodgerBlue,
                            onChanged: (v) => setState(() => _saveCard = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.lock_outline, color: AppColors.jumbo, size: 16),
                          SizedBox(width: 8),
                          Text('Your payment is safe and secure.', style: TextStyle(color: AppColors.jumbo)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _pay,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.dodgerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Pay \$${_amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
