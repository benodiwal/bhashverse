import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../utils/theme/app_theme_provider.dart';
import '../utils/theme/app_text_style.dart';

class LottieAnimation extends StatelessWidget {
  const LottieAnimation({
    Key? key,
    required this.context,
    required this.lottieAsset,
    required this.footerText,
  }) : super(key: key);

  final BuildContext context;
  final String lottieAsset;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.56)),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 22).w,
            padding: const EdgeInsets.all(22).w,
            decoration: BoxDecoration(
              color: context.appTheme.cardBGColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieBuilder.asset(
                  lottieAsset,
                  width: 60.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 14.w),
                Text(
                  footerText,
                  style: regular16(context),
                ),
                SizedBox(height: 8.w)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
