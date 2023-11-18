import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme_provider.dart';

class WaveformStyle {
  static PlayerWaveStyle getDefaultPlayerStyle({
    required bool isRecordedAudio,
  }) {
    final appTheme =
        Provider.of<AppThemeProvider>(Get.context!, listen: false).theme;
    return PlayerWaveStyle(
        fixedWaveColor: appTheme.primaryColor.withOpacity(0.3),
        liveWaveColor: appTheme.primaryColor,
        scaleFactor: isRecordedAudio ? 200 : 70,
        waveThickness: 2);
  }

  static double getDefaultWidth = (ScreenUtil().screenWidth / 1.3);
  static double getDefaultHeight = 40.w;
}
