import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class LanguageSelectionWidget extends StatelessWidget {
  const LanguageSelectionWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.selectedIndex,
    required this.index,
    required this.onItemTap,
  });

  final String title;
  final String subTitle;
  final int? selectedIndex;
  final int index;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (selectedIndex != null && selectedIndex == index)
            ? context.appTheme.lightBGColor
            : context.appTheme.cardBGColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (selectedIndex != null && selectedIndex == index)
              ? context.appTheme.highlightedBorderColor
              : context.appTheme.disabledBGColor,
          width:
              (selectedIndex != null && selectedIndex == index) ? 1.5.w : 1.w,
        ),
      ),
      child: InkWell(
        onTap: onItemTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title.isNotEmpty)
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  title,
                  style: light16(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(height: 4.w),
            if (subTitle.isNotEmpty)
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  subTitle,
                  style: light16(context)
                      .copyWith(color: context.appTheme.secondaryTextColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
