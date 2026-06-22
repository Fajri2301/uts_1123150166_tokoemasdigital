import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool light;
  final bool withText;

  const AppLogo({super.key, this.size = 56, this.light = false, this.withText = false});

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'PlusJakartaSans';

    Widget icon = Icon(
      Icons.diamond,
      size: size,
      color: light ? Colors.white : AppColors.primary,
    );

    if (!withText) return icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toko Emas',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w800,
                color: light ? Colors.white : AppColors.ink,
                letterSpacing: -0.3,
                height: 1.05,
              ),
            ),
            Text(
              'DIGITAL',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.205,
                fontWeight: FontWeight.w700,
                color: light ? Colors.white.withValues(alpha: 0.85) : AppColors.primary,
                letterSpacing: 1.5,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
