import 'package:flutter/material.dart';

class WatchXColors {
  static const bgBlack = Color(0xFF0A0907);
  static const surfaceDark = Color(0xFF14120F);
  static const cardDark = Color(0xFF1A1713);
  static const borderDark = Color(0xFF2B251D);
  static const goldPrimary = Color(0xFFE5C17B);
  static const goldMuted = Color(0xFFB89758);
  static const textWhite = Color(0xFFF7F4EE);
  static const textMuted = Color(0xFF9E9689);
  static const errorRed = Color(0xFFE57373);
  static const successGreen = Color(0xFF81C784);
}

class MobileFrameWrapper extends StatelessWidget {
  final Widget child;
  const MobileFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050504),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          decoration: BoxDecoration(
            color: WatchXColors.bgBlack,
            border: Border.symmetric(
              vertical: BorderSide(
                color: WatchXColors.goldPrimary.withValues(alpha: 0.14),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

InputDecoration watchXInputDecoration({
  required String hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: WatchXColors.textMuted, fontSize: 13),
    filled: true,
    fillColor: WatchXColors.cardDark,
    prefixIcon: Icon(prefixIcon, color: WatchXColors.textMuted, size: 20),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WatchXColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WatchXColors.goldPrimary, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WatchXColors.errorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WatchXColors.errorRed),
    ),
  );
}

String formatWatchPrice(dynamic rawPrice) {
  final val = (rawPrice is int) ? rawPrice : int.tryParse('$rawPrice') ?? 0;
  final s = val.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buffer.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) {
      buffer.write(',');
    }
  }
  return '\$${buffer.toString().split('').reversed.join()}';
}