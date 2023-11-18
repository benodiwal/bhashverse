import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/theme/app_text_style.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onButtonTap,
    required String buttonText,
  })  : _backgroundColor = backgroundColor,
        _borderRadius = borderRadius,
        _onButtonTap = onButtonTap,
        _buttonText = buttonText;

  final Color? _backgroundColor;
  final double? _borderRadius;
  final VoidCallback? _onButtonTap;
  final String _buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        backgroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius?.w ?? 16.w),
        ),
      ),
      onPressed: _onButtonTap,
      child: Text(
        _buttonText,
        style: regular18Primary(context),
      ),
    );
  }
}
