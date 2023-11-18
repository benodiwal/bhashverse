import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class TextAndMicLimit extends StatelessWidget {
  const TextAndMicLimit({
    super.key,
    bool showMicButton = false,
    int sourceCharLength = 0,
    Stream<int>? rawTimeStream,
  })  : _showMicButton = showMicButton,
        _sourceCharLength = sourceCharLength,
        _rawTimeStream = rawTimeStream;

  final bool _showMicButton;
  final int _sourceCharLength;
  final Stream<int>? _rawTimeStream;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _showMicButton
          ? Row(
              children: [
                AvatarGlow(
                  animate: true,
                  repeat: true,
                  glowColor: context.appTheme.errorColor,
                  endRadius: 16,
                  shape: BoxShape.circle,
                  showTwoGlows: true,
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.mic_none,
                    color: context.appTheme.warningColor,
                  ),
                ),
                SizedBox(width: 4.w),
                StreamBuilder<int>(
                  stream: _rawTimeStream,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(
                        recordingMaxTimeLimit - (value ?? 0),
                        hours: false,
                        minute: false,
                        milliSecond: true);
                    return Text(
                      '-$displayTime',
                      style: regular14Title(context).copyWith(
                          color: (recordingMaxTimeLimit - (value ?? 0)) >= 5000
                              ? context.appTheme.titleTextColor
                              : (recordingMaxTimeLimit - (value ?? 0)) >= 2000
                                  ? context.appTheme.warningColor
                                  : context.appTheme.errorColor),
                    );
                  },
                ),
              ],
            )
          : Text(
              '$_sourceCharLength/$textCharMaxLength',
              style: regular12Title(context).copyWith(
                  color: _sourceCharLength >= textCharMaxLength
                      ? context.appTheme.errorColor
                      : _sourceCharLength >= textCharMaxLength - 20
                          ? context.appTheme.warningColor
                          : context.appTheme.titleTextColor),
            ),
    ]);
  }
}
