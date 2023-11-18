import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme/app_theme_provider.dart';

class IndicatorWidget extends StatelessWidget {
  final int currentIndex;
  final int indicatorIndex;
  const IndicatorWidget(
      {Key? key, required this.currentIndex, required this.indicatorIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.w,
      width: currentIndex == indicatorIndex ? 30.w : 8.w,
      margin: EdgeInsets.only(right: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: currentIndex == indicatorIndex
            ? context.appTheme.highlightedBGColor
            : context.appTheme.lightBGColor,
      ),
    );
  }
}
