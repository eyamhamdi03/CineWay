import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../l10n/app_localizations.dart';
import '../repository/user_repository.dart';
import '../viewmodel/session/session_viewmodel.dart';

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
  bool _saving = false;

  final _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Prefill from session if available, or provided user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionViewModel>();
      final u = session.user ?? widget.user;
      try {
        _nameController.text = (u?.fullName ?? '').toString();
        _emailController.text = (u?.email ?? '').toString();
        if (u?.dob != null && u!.dob is DateTime) _dob = u.dob as DateTime;
        if (u?.favoriteGenres is List) {
          _selectedGenres.addAll(List<String>.from(u!.favoriteGenres));
        }
        if (u?.receiveNewsletter != null) _newsletter = u!.receiveNewsletter == true;
      } catch (_) {}
      setState(() {});
    });
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

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final session = context.read<SessionViewModel>();
    final token = session.accessToken;
    final repo = UserRepository();

    try {
      if (token != null && token.isNotEmpty) {
        // Update basic profile
        await repo.updateMe(
          token: token,
          fullName: name.isEmpty ? null : name,
          email: email.isEmpty ? null : email,
          dateOfBirth: _dob,
        );

        // Update preferences (push notifications)
        await repo.updatePreferences(
          token: token,
          notificationsEnabled: _pushNotifications,
        );

        // Upload profile picture if picked
        if (_pickedImage != null) {
          await repo.uploadProfilePicture(token: token, file: File(_pickedImage!.path));
        }
      }

      // Persist minimal data locally in session
      await session.completeProfile(
        fullName: name,
        dob: _dob,
        avatarPath: _pickedImage?.path,
        favoriteGenres: _selectedGenres.toList(),
        newsletter: _newsletter,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );

      if (widget.user != null) {
        Navigator.maybePop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Text('Profile Setup', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 180),
              child: Column(
                children: [
                  // Progress
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(width: 24, active: false),
                      const SizedBox(width: 8),
                      _dot(width: 48, active: true),
                      const SizedBox(width: 8),
                      _dot(width: 24, active: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Let's get you set up",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add your details to personalize your experience.',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 22),

                  // Avatar with add button
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: ClipOval(
                            child: _pickedImage != null
                                ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                                : Icon(Icons.person, size: 48, color: textColor.withOpacity(0.6)),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Material(
                            color: AppColors.dodgerBlue,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _pickImage,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add_a_photo, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Full Name'),
                        _input(
                          controller: _nameController,
                          hint: 'e.g. Alex Doe',
                          icon: Icons.badge_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                        ),
                        const SizedBox(height: 16),
                        _label('Email Address'),
                        _input(
                          controller: _emailController,
                          hint: 'alex.doe@cine.way',
                          icon: Icons.mail_outline,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _label('Date of Birth'),
                        GestureDetector(
                          onTap: _pickDob,
                          child: AbsorbPointer(
                            child: _input(
                              controller: TextEditingController(text: _formatDob()),
                              hint: 'mm/dd/yyyy',
                              icon: Icons.calendar_today_outlined,
                              validator: (v) => (v == null || v.isEmpty) ? 'Select your date of birth' : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _label('Favorite Genres'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _genres.map((g) {
                            final selected = _selectedGenres.contains(g);
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (selected) ...[
                                    const Icon(Icons.check, size: 18),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(g),
                                ],
                              ),
                              selected: selected,
                              onSelected: (_) => _toggleGenre(g),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : textColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                              selectedColor: AppColors.dodgerBlue.withOpacity(0.9),
                              backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                              shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.dodgerBlue.withOpacity(0.5) : Colors.transparent)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        // Push notifications card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_active_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
                                    Text('Alerts for ticket availability', style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _pushNotifications,
                                onChanged: (v) => setState(() => _pushNotifications = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient and actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dodgerBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: _saving
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.complete_profile, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
        ),
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.dodgerBlue.withOpacity(0.5))),
      ),
    );
  }

  Widget _dot({required double width, required bool active}) {
    return Container(
      height: 6,
      width: width,
      decoration: BoxDecoration(
        color: active ? AppColors.dodgerBlue : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.dodgerBlue.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
    );
  }
}
