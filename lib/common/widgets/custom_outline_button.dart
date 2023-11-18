import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    Key? key,
    this.title,
    this.icon,
    this.isDisabled = false,
    this.showBoarder = true,
    this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  final String? title;
  final String? icon;
  final Function onTap;
  final bool isDisabled, showBoarder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        overlayColor: MaterialStateProperty.all(
          isDisabled
              ? Colors.transparent
              : context.appTheme.highlightedBGColor.withOpacity(0.2),
        ),
        backgroundColor: MaterialStateProperty.all(
            backgroundColor ?? context.appTheme.normalTextFieldColor),
        side: MaterialStateProperty.resolveWith((state) {
          return showBoarder
              ? BorderSide(
                  color: isDisabled
                      ? context.appTheme.titleTextColor
                      : context.appTheme.highlightedBGColor,
                )
              : BorderSide.none;
        }),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )),
      ),
      onPressed: isDisabled ? null : () => onTap(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.sh),
        child: Row(
          children: [
            if (icon != null && icon!.isNotEmpty)
              SvgPicture.asset(
                icon!,
                height: 20.w,
                width: 20.w,
              ),
            if (icon != null && icon!.isNotEmpty)
              SizedBox(
                width: 8.w,
              ),
            if (title != null && title!.isNotEmpty)
              Text(title!,
                  style: secondary14(context).copyWith(
                      color: isDisabled
                          ? context.appTheme.titleTextColor
                          : context.appTheme.highlightedBGColor)),
          ],
        ),
      ),
    );
  }
}
