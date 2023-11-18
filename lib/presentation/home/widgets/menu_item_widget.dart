import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme/app_theme_provider.dart';
import '../../../utils/theme/app_text_style.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required String title,
    required Image image,
    required bool isDisabled,
    required Function onTap,
  })  : _title = title,
        _image = image,
        _isDisabled = isDisabled,
        _onTap = onTap;

  final String _title;
  final Image _image;
  final bool _isDisabled;
  final Function _onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.appTheme.cardBGColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0).w,
                    child: _image,
                  ),
                ),
                Text(
                  _title,
                  style: semibold20(context),
                ),
                SizedBox(height: 16.h)
              ],
            ),
          ),
          if (_isDisabled)
            Container(
              decoration: BoxDecoration(
                color: context.appTheme.disabledBGColor.withOpacity(.6),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
        ],
      ),
    );
  }
}
