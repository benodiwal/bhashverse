import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class TransliterationHints extends StatelessWidget {
  const TransliterationHints(
      {super.key,
      required ScrollController scrollController,
      required List<dynamic> transliterationHints,
      required bool showScrollIcon,
      isScrollArrowVisible,
      required Function onSelected})
      : _scrollController = scrollController,
        _transliterationHints = transliterationHints,
        _showScrollIcon = showScrollIcon,
        _isScrollArrowVisible = isScrollArrowVisible,
        _onHintTap = onSelected;

  final ScrollController _scrollController;
  final List<dynamic> _transliterationHints;
  final bool _showScrollIcon, _isScrollArrowVisible;

  final Function _onHintTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _showScrollIcon ? 85.w : 50.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _showScrollIcon ? 6.w : null),
          if (_showScrollIcon)
            _isScrollArrowVisible
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_outlined,
                      color: Colors.grey.shade400,
                      size: 22.w,
                    ),
                  )
                : SizedBox(height: 22.w),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ..._transliterationHints.map((hintText) => GestureDetector(
                      onTap: () => _onHintTap(hintText),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: context.appTheme.lightBGColor,
                        ),
                        margin: const EdgeInsets.all(4).w,
                        padding: EdgeInsets.symmetric(
                            vertical: 3.h, horizontal: 4.w),
                        alignment: Alignment.center,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: (ScreenUtil().screenWidth / 7.3).w,
                          ),
                          child: Text(
                            hintText,
                            style: regular16(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
