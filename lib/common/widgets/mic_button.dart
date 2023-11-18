import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/mic_button_status.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class MicButton extends StatelessWidget {
  const MicButton({
    super.key,
    required MicButtonStatus micButtonStatus,
    required bool showLanguage,
    String languageName = '',
    required Function onMicButtonTap,
    Function? onLanguageTap,
  })  : _micButtonStatus = micButtonStatus,
        _showLanguage = showLanguage,
        _languageName = languageName,
        _onMicButtonTap = onMicButtonTap,
        _onLanguageTap = onLanguageTap;

  final MicButtonStatus _micButtonStatus;
  final bool _showLanguage;
  final String _languageName;
  final Function _onMicButtonTap;
  final Function? _onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) => _onMicButtonTap(true),
          onTapUp: (_) => _onMicButtonTap(false),
          onTapCancel: () => _onMicButtonTap(false),
          onPanEnd: (_) => _onMicButtonTap(false),
          child: PhysicalModel(
            color: Colors.transparent,
            shape: BoxShape.circle,
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(
                color: _micButtonStatus == MicButtonStatus.pressed
                    ? context.appTheme.buttonSelectedColor
                    : context.appTheme.disabledOrangeColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(
                        _micButtonStatus == MicButtonStatus.pressed ? 18 : 13.0)
                    .w,
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: _micButtonStatus == MicButtonStatus.loading
                      ? CircularProgressIndicator(
                          color: Colors.black.withOpacity(0.7),
                          strokeWidth: 2,
                        )
                      : SvgPicture.asset(
                          _micButtonStatus == MicButtonStatus.pressed
                              ? iconMicStop
                              : iconMicroPhone,
                          color: Colors.black.withOpacity(0.7),
                        ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: _showLanguage ? 10.w : 0),
        if (_showLanguage)
          GestureDetector(
            onTap: () => _onLanguageTap != null ? _onLanguageTap!() : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: AutoSizeText(
                    _languageName,
                    maxLines: 2,
                    style: secondary16(context),
                  ),
                ),
                SizedBox(width: 6.w),
                SvgPicture.asset(
                  iconDownArrow,
                  color: context.appTheme.primaryTextColor,
                  width: 8.w,
                  height: 8.w,
                )
              ],
            ),
          )
      ],
    );
  }
}
