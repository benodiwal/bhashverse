import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/speaker_status.dart';
import '../../localization/localization_keys.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import '../../utils/waveform_style.dart';
import '../custom_circular_loading.dart';

class ASRAndTTSActions extends StatelessWidget {
  const ASRAndTTSActions({
    super.key,
    required String textToCopy,
    required bool isRecordedAudio,
    required bool expandFeedbackIcon,
    required bool showFeedbackIcon,
    required SpeakerStatus speakerStatus,
    bool isShareButtonLoading = false,
    String? currentDuration,
    String? totalDuration,
    Function? onMusicPlayOrStop,
    Function? onFileShare,
    PlayerController? playerController,
    Function? onFeedbackButtonTap,
  })  : _textToCopy = textToCopy,
        _playerController = playerController,
        _isRecordedAudio = isRecordedAudio,
        _expandFeedbackIcon = expandFeedbackIcon,
        _showFeedbackIcon = showFeedbackIcon,
        _isShareButtonLoading = isShareButtonLoading,
        _currentDuration = currentDuration,
        _totalDuration = totalDuration,
        _speakerStatus = speakerStatus,
        _onAudioPlayOrStop = onMusicPlayOrStop,
        _onFileShare = onFileShare,
        _onFeedbackButtonTap = onFeedbackButtonTap;

  final bool _isRecordedAudio,
      _isShareButtonLoading,
      _expandFeedbackIcon,
      _showFeedbackIcon;
  final String _textToCopy;
  final PlayerController? _playerController;
  final String? _currentDuration;
  final String? _totalDuration;
  final SpeakerStatus _speakerStatus;
  final Function? _onFileShare;
  final Function? _onAudioPlayOrStop, _onFeedbackButtonTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: _speakerStatus != SpeakerStatus.playing,
            child: Row(
              children: [
                Visibility(
                  visible: _speakerStatus != SpeakerStatus.hidden,
                  child: InkWell(
                    onTap: () async {
                      if (_onFileShare != null) _onFileShare!();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: _isShareButtonLoading
                          ? SizedBox(
                              height: 20.w,
                              width: 20.w,
                              child: const CustomCircularLoading(),
                            )
                          : SvgPicture.asset(
                              iconShare,
                              height: 20.w,
                              width: 20.w,
                              color: _textToCopy.isNotEmpty
                                  ? context.appTheme.disabledTextColor
                                  : context.appTheme.disabledIconOutlineColor,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                InkWell(
                  onTap: () async {
                    if (_textToCopy.isEmpty) {
                      showDefaultSnackbar(message: noTextForCopy.tr);
                      return;
                    } else {
                      await Clipboard.setData(ClipboardData(text: _textToCopy));
                      showDefaultSnackbar(message: textCopiedToClipboard.tr);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: SvgPicture.asset(
                      iconCopy,
                      height: 20.w,
                      width: 20.w,
                      color: _textToCopy.isNotEmpty
                          ? context.appTheme.disabledTextColor
                          : context.appTheme.disabledIconOutlineColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _speakerStatus != SpeakerStatus.playing
              ? _showFeedbackIcon
                  ? Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _onFeedbackButtonTap != null
                                ? () => _onFeedbackButtonTap!()
                                : null,
                            child: AnimatedContainer(
                              duration: feedbackButtonCloseTime,
                              curve: Curves.fastOutSlowIn,
                              decoration: BoxDecoration(
                                  color: _expandFeedbackIcon
                                      ? context.appTheme.feedbackBGColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.h, horizontal: 15.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    iconLikeDislike,
                                    height: 20.w,
                                    width: 20.w,
                                    color: _expandFeedbackIcon
                                        ? context.appTheme.feedbackIconColor
                                        : context
                                            .appTheme.feedbackIconClosedColor,
                                  ),
                                  AnimatedCrossFade(
                                    duration: feedbackButtonCloseTime,
                                    firstChild: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 8.w),
                                        Text(
                                          feedback.tr,
                                          style: regular14(context).copyWith(
                                              color: context
                                                  .appTheme.feedbackTextColor),
                                        ),
                                      ],
                                    ),
                                    secondChild: const SizedBox.shrink(),
                                    crossFadeState: _expandFeedbackIcon
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer()
                        ],
                      ),
                    )
                  : const Spacer()
              : Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AudioFileWaveforms(
                        size: Size(WaveformStyle.getDefaultWidth, 25.h),
                        playerController:
                            _playerController ?? PlayerController(),
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: WaveformStyle.getDefaultPlayerStyle(
                          isRecordedAudio: _isRecordedAudio,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: WaveformStyle.getDefaultWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_currentDuration ?? '',
                                style: secondary12(context).copyWith(
                                    color: context.appTheme.titleTextColor),
                                textAlign: TextAlign.start),
                            Text(_totalDuration ?? '',
                                style: secondary12(context).copyWith(
                                    color: context.appTheme.titleTextColor),
                                textAlign: TextAlign.end),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(width: 12.w),
          Visibility(
            visible: _speakerStatus != SpeakerStatus.hidden,
            child: InkWell(
              onTap: () {
                if (_speakerStatus != SpeakerStatus.disabled) {
                  if (_onAudioPlayOrStop != null) _onAudioPlayOrStop!();
                } else {
                  showDefaultSnackbar(message: cannotPlayAudioAtTheMoment.tr);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _speakerStatus != SpeakerStatus.disabled
                      ? context.appTheme.buttonSelectedColor
                      : context.appTheme.speakerColor,
                ),
                padding: const EdgeInsets.all(6).w,
                child: SizedBox(
                  height: 20.w,
                  width: 20.w,
                  child: _speakerStatus == SpeakerStatus.loading
                      ? const CustomCircularLoading()
                      : SvgPicture.asset(
                          _speakerStatus == SpeakerStatus.playing
                              ? iconStopPlayback
                              : iconSound,
                          color: _speakerStatus != SpeakerStatus.disabled
                              ? context.appTheme.iconOutlineColor
                              : context.appTheme.disabledIconOutlineColor,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
