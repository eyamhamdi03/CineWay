import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'package:cineway/l10n/app_localizations.dart';

class ProfileSetupScreen extends StatefulWidget {
  final dynamic user; // optional UserProfile for editing
  const ProfileSetupScreen({super.key, this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _dob;

  final List<String> _genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Horror',
    'Romance',
    'Thriller'
  ];
  final Set<String> _selectedGenres = {};

  bool _newsletter = true;
  bool _pushNotifications = false;

  @override
  void initState() {
    super.initState();
    // if user passed, prefill controllers
    if (widget.user != null) {
      try {
        final u = widget.user;
        _nameController.text = u.fullName ?? '';
        _emailController.text = u.email ?? '';
        if (u.dob != null && u.dob is DateTime) _dob = u.dob as DateTime;
        if (u.favoriteGenres is List) _selectedGenres.addAll(List<String>.from(u.favoriteGenres));
        if (u.receiveNewsletter != null) _newsletter = u.receiveNewsletter as bool;
      } catch (_) {}
    }
  }

  // simple email validation
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final email = v.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);
    final first = DateTime(1900);
    final last = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.dodgerBlue,
            onPrimary: Colors.white,
            surface: AppColors.mirage,
            onSurface: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  String _formatDob() {
    if (_dob == null) return '';
    final d = _dob!;
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$mm/$dd/$yyyy';
  }

  void _toggleGenre(String g) {
    setState(() {
      if (_selectedGenres.contains(g)) _selectedGenres.remove(g);
      else _selectedGenres.add(g);
    });
  }

  void _completeProfile() {
    if (!_formKey.currentState!.validate()) return;

  // For now, just show a summary snackbar
  final name = _nameController.text.trim();

    // Save profile into AppState
    final appState = Provider.of<AppState>(context, listen: false);
    appState.completeProfile(
      fullName: name,
      dob: _dob,
      avatarPath: null,
      favoriteGenres: _selectedGenres.toList(),
      newsletter: _newsletter,
    );

    // If we opened this screen to edit an existing profile, pop back; otherwise go home
    if (widget.user != null) {
      Navigator.maybePop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
  title: Text(AppLocalizations.of(context)!.create_profile, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Center(
                child: SizedBox(height: 10),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Let's get your account personalized.",
                  style: const TextStyle(color: AppColors.jumbo, fontSize: 16),
                ),
              ),

              const SizedBox(height: 18),

              // Avatar placeholder
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.mirageLight, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.mirageLight),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // simple placeholder action: show dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Upload Picture'),
                              content: const Text('Image upload is not wired in this preview.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27455A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Upload Picture', style: TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Full Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g. Alex Doe',
                        hintStyle: const TextStyle(color: AppColors.mirageLight),
                        filled: true,
                        fillColor: const Color(0xFF101820),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                    ),

                    const SizedBox(height: 14),
                    const Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'alex.doe@email.com',
                        hintStyle: const TextStyle(color: AppColors.mirageLight),
                        filled: true,
                        fillColor: const Color(0xFF101820),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 14),
                    const Text('Date of Birth', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDob,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'mm/dd/yyyy',
                            hintStyle: const TextStyle(color: AppColors.mirageLight),
                            suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.mirageLight),
                            filled: true,
                            fillColor: const Color(0xFF101820),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          controller: TextEditingController(text: _formatDob()),
                          validator: (v) => (v == null || v.isEmpty) ? 'Select your date of birth' : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text('Favorite Genres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _genres.map((g) {
                        final selected = _selectedGenres.contains(g);
                        return FilterChip(
                          label: Text(g, style: TextStyle(color: selected ? Colors.white : AppColors.jumbo)),
                          selected: selected,
                          onSelected: (_) => _toggleGenre(g),
                          selectedColor: AppColors.dodgerBlue,
                          backgroundColor: const Color(0xFF141A23),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Newsletter toggle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF101820), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Receive newsletters', style: TextStyle(color: Colors.white)),
                          Switch(
                            value: _newsletter,
                            activeColor: AppColors.dodgerBlue,
                            onChanged: (v) => setState(() => _newsletter = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF101820), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Push notifications', style: TextStyle(color: Colors.white)),
                          Switch(
                            value: _pushNotifications,
                            activeColor: AppColors.dodgerBlue,
                            onChanged: (v) => setState(() => _pushNotifications = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _completeProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dodgerBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(AppLocalizations.of(context)!.complete_profile, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Skip for now',
                          style: const TextStyle(color: AppColors.dodgerBlue),
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.maybePop(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
