import 'package:flutter/material.dart';

import '../theme/watchx_theme.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _openSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _openSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WatchXColors.bgBlack,
      body: MobileFrameWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: WatchXColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: WatchXColors.borderDark),
                  ),
                  child: const Text(
                    '•  GENEVA PRIVATE SALON',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: WatchXColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.watch,
                      color: WatchXColors.goldPrimary,
                      size: 22,
                    ),
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
                      'Luxury Salon',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: WatchXColors.goldPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      child: Divider(
                        color: WatchXColors.borderDark,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'EST. 1884',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2.5,
                          color: WatchXColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Divider(
                        color: WatchXColors.borderDark,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A1611), Color(0xFF0E0C0A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: WatchXColors.goldPrimary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: SizedBox(
                          height: 195,
                          width: double.infinity,
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF14110D),
                              BlendMode.multiply,
                            ),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=900&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.watch_later_outlined,
                                      size: 64,
                                      color: WatchXColors.goldPrimary,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: WatchXColors.borderDark),
                          ),
                        ),
                        child: const Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Text(
                              'CHRONOGRAPH MASTERWORK',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: WatchXColors.goldPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'SWISS EDITION',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.4,
                                color: WatchXColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Row(
                  children: [
                    Expanded(
                      child: _OnboardingSpecBox(
                        label: 'CALIBRE',
                        value: 'WX-940',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _OnboardingSpecBox(
                        label: 'RESERVE',
                        value: '72 Hours',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _OnboardingSpecBox(
                        label: 'FREQUENCY',
                        value: '28,800\nvph',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Timeless Style,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: WatchXColors.textWhite,
                  ),
                ),

                const Text(
                  'Every Second',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: WatchXColors.goldPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Discover watches that define your style.\nExplore rare masterworks, limited editions, and\nprecision Swiss engineering.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: WatchXColors.textMuted,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _openSignUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WatchXColors.goldPrimary,
                      foregroundColor: WatchXColors.bgBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "LET'S GET STARTED",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a member? ',
                      style: TextStyle(
                        color: WatchXColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openSignIn(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: WatchXColors.goldPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: WatchXColors.goldMuted,
                    ),
                    Text(
                      'Certified Chronometer',
                      style: TextStyle(
                        fontSize: 11,
                        color: WatchXColors.textMuted,
                      ),
                    ),
                    Text('•', style: TextStyle(color: WatchXColors.textMuted)),
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: WatchXColors.goldMuted,
                    ),
                    Text(
                      'Insured Global Vault',
                      style: TextStyle(
                        fontSize: 11,
                        color: WatchXColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSpecBox extends StatelessWidget {
  final String label;
  final String value;

  const _OnboardingSpecBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: WatchXColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WatchXColors.borderDark),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: WatchXColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: WatchXColors.textWhite,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
