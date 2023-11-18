import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_text_style.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({
    super.key,
    required String title,
    bool showBackButton = true,
    showLogo = true,
    VoidCallback? onBackPress,
  })  : _title = title,
        _showBackButton = showBackButton,
        _onBackPress = onBackPress,
        _showLogo = showLogo;

  final VoidCallback? _onBackPress;
  final bool _showBackButton, _showLogo;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showBackButton)
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _onBackPress,
              child: Padding(
                padding: const EdgeInsets.all(6.0).w,
                child: SvgPicture.asset(
                  iconPrevious,
                ),
              ),
            ),
          ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _showLogo
                  ? Image.asset(
                      imgAppLogoSmall,
                      height: 30.w,
                      width: 30.w,
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                width: 8.w,
              ),
              Text(
                _title,
                style: regular22(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
