import 'package:flutter/material.dart';
import '../services/watchx_database_service.dart';
import '../theme/watchx_theme.dart';
import 'main_shell_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  final String? prefilledEmail;
  const SignInScreen({super.key, this.prefilledEmail});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
    _loadSavedEmailIfEmpty();
  }

  Future<void> _loadSavedEmailIfEmpty() async {
    if (_emailController.text.trim().isNotEmpty) return;
    final activeUser = await WatchXDatabaseService.getActiveUser();
    if (activeUser != null && mounted) {
      setState(() {
        _emailController.text = activeUser['email']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = await WatchXDatabaseService.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => WatchXMainShell(user: user)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: WatchXColors.cardDark,
          content: Text(
            'Invalid email or password. Create an account first if new.',
            style: TextStyle(color: WatchXColors.errorRed),
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WatchXColors.cardDark,
        title: const Text(
          'Geneva Vault Recovery',
          style: TextStyle(color: WatchXColors.textWhite, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your registered email address to receive a recovery link.',
              style: TextStyle(color: WatchXColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmailCtrl,
              style: const TextStyle(color: WatchXColors.textWhite),
              decoration: watchXInputDecoration(
                hint: 'collector@watchx.luxury',
                prefixIcon: Icons.mail_outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: WatchXColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: WatchXColors.cardDark,
                  content: Text(
                    'Recovery link sent to ${resetEmailCtrl.text.trim().isEmpty ? "your email" : resetEmailCtrl.text.trim()}.',
                    style: const TextStyle(color: WatchXColors.goldPrimary),
                  ),
                ),
              );
            },
            child: const Text('Send Link',
                style: TextStyle(color: WatchXColors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  void _showQuickAuthNotice(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: WatchXColors.cardDark,
        content: Text(
          '$method authentication ready.',
          style: const TextStyle(color: WatchXColors.goldPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WatchXColors.bgBlack,
      body: MobileFrameWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.watch,
                          color: WatchXColors.goldPrimary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'WATCHX',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: WatchXColors.textWhite,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Haute Horlogerie',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: WatchXColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '—  PRIVATE ATELIER  —',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      color: WatchXColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: WatchXColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue your journey into haute\nhorlogerie.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: WatchXColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: WatchXColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: WatchXColors.textWhite),
                    decoration: watchXInputDecoration(
                      hint: 'collector@watchx.luxury',
                      prefixIcon: Icons.mail_outline,
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Please enter your email address';
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: WatchXColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: const Text(
                          'FORGOT PASSWORD?',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: WatchXColors.goldPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: WatchXColors.textWhite),
                    decoration: watchXInputDecoration(
                      hint: '••••••••••••',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: WatchXColors.textMuted,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 7, color: WatchXColors.goldPrimary),
                          SizedBox(width: 6),
                          Text(
                            'CALIBRE 256-BIT SSL',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              color: WatchXColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'GENEVA VAULT',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: WatchXColors.goldMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WatchXColors.goldPrimary,
                        foregroundColor: WatchXColors.bgBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
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
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: WatchXColors.borderDark)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.8,
                            color: WatchXColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: WatchXColors.borderDark)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialAuthButton(
                          icon: Icons.face_unlock_outlined,
                          label: 'FACE ID',
                          onTap: () => _showQuickAuthNotice('Face ID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialAuthButton(
                          icon: Icons.g_mobiledata,
                          label: 'GOOGLE',
                          onTap: () => _showQuickAuthNotice('Google Sign-In'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
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
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: WatchXColors.goldPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'BESPOKE CONCIERGE   •   VERIFIED VAULT',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      color: WatchXColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: WatchXColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WatchXColors.borderDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: WatchXColors.goldPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: WatchXColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}