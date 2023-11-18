import 'package:flutter/material.dart';

import '../utils/theme/app_theme_provider.dart';

class CustomCircularLoading extends StatelessWidget {
  const CustomCircularLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: context.appTheme.primaryTextColor,
      strokeWidth: 2,
    );
  }
}
