import 'package:flutter/material.dart';

import '../services/watchx_database_service.dart';
import '../theme/watchx_theme.dart';
import 'main_shell_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: WatchXColors.cardDark,
          content: Text(
            'Please agree to the WATCHX Terms of Service and Privacy Policy.',
            style: TextStyle(color: WatchXColors.errorRed),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final error = await WatchXDatabaseService.registerUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (error != null) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: WatchXColors.cardDark,
            content: Text(
              error,
              style: const TextStyle(color: WatchXColors.errorRed),
            ),
          ),
        );
        return;
      }

      // Get the newly registered active user.
      final user = await WatchXDatabaseService.getActiveUser();

      if (!mounted) return;

      if (user == null) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: WatchXColors.cardDark,
            content: Text(
              'Account created, but unable to load your session. Please sign in.',
              style: TextStyle(color: WatchXColors.errorRed),
            ),
          ),
        );
        return;
      }

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: WatchXColors.cardDark,
          content: Text(
            'Welcome to WATCHX! Your account has been created.',
            style: TextStyle(color: WatchXColors.goldPrimary),
          ),
        ),
      );

      // Open Home screen directly after successful registration.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => WatchXMainShell(user: user)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: WatchXColors.cardDark,
          content: Text(
            'Unable to create account: $e',
            style: const TextStyle(color: WatchXColors.errorRed),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WatchXColors.bgBlack,
      body: MobileFrameWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.watch,
                      color: WatchXColors.goldPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'WATCHX',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: WatchXColors.textWhite,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Atelier',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: WatchXColors.goldPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: WatchXColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: WatchXColors.borderDark),
                  ),
                  child: const Text(
                    '•  ATELIER REGISTRY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: WatchXColors.goldPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: WatchXColors.textWhite,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Join an exclusive circle of watch\nenthusiasts and collectors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: WatchXColors.textMuted,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WatchXColors.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WatchXColors.borderDark),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SignUpFieldHeader(
                          leftText: 'FULL NAME',
                          rightText: 'REQUIRED',
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: WatchXColors.textWhite),
                          decoration: watchXInputDecoration(
                            hint: 'Arthur Pendelton',
                            prefixIcon: Icons.person_outline,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Full name is required'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        const _SignUpFieldHeader(
                          leftText: 'EMAIL ADDRESS',
                          rightText: 'PRIMARY CONTACT',
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: WatchXColors.textWhite),
                          decoration: watchXInputDecoration(
                            hint: 'name@example.com',
                            prefixIcon: Icons.mail_outline,
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';

                            if (val.isEmpty) {
                              return 'Email is required';
                            }

                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        const _SignUpFieldHeader(
                          leftText: 'PASSWORD',
                          rightText: 'MIN. 8 CHARS',
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePass,
                          style: const TextStyle(color: WatchXColors.textWhite),
                          decoration: watchXInputDecoration(
                            hint: 'Create a strong password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePass = !_obscurePass;
                                });
                              },
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: WatchXColors.textMuted,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        const _SignUpFieldHeader(
                          leftText: 'CONFIRM PASSWORD',
                          rightText: 'VERIFICATION',
                        ),

                        const SizedBox(height: 6),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: const TextStyle(color: WatchXColors.textWhite),
                          decoration: watchXInputDecoration(
                            hint: 'Re-enter your password',
                            prefixIcon: Icons.verified_user_outlined,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: WatchXColors.textMuted,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: WatchXColors.goldPrimary,
                                checkColor: WatchXColors.bgBlack,
                                side: const BorderSide(
                                  color: WatchXColors.borderDark,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _acceptedTerms = val ?? false;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Expanded(
                              child: Wrap(
                                children: [
                                  Text(
                                    'I agree to the WATCHX ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: WatchXColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Terms of Service',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: WatchXColors.goldPrimary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  Text(
                                    ' and ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: WatchXColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: WatchXColors.goldPrimary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  Text(
                                    '.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: WatchXColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleCreateAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WatchXColors.goldPrimary,
                              foregroundColor: WatchXColors.bgBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: WatchXColors.bgBlack,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'CREATE ACCOUNT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 13,
                              color: WatchXColors.textMuted,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ENCRYPTED GENEVA ARCHIVE',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: WatchXColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: WatchXColors.textMuted,
                        fontSize: 13,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              color: WatchXColors.goldPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.north_east,
                            size: 14,
                            color: WatchXColors.goldPrimary,
                          ),
                        ],
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
}

class _SignUpFieldHeader extends StatelessWidget {
  final String leftText;
  final String rightText;

  const _SignUpFieldHeader({required this.leftText, required this.rightText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.4,
            color: WatchXColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          rightText,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: WatchXColors.textMuted,
          ),
        ),
      ],
    );
  }
}
