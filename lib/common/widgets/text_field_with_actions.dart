import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/speaker_status.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'asr_tts_actions.dart';
import 'custom_outline_button.dart';
import 'text_and_mic_limit.dart';

class TextFieldWithActions extends StatelessWidget {
  const TextFieldWithActions({
    super.key,
    required TextEditingController textController,
    required FocusNode focusNode,
    String? translateButtonTitle,
    required String textToCopy,
    required Color backgroundColor,
    required Color borderColor,
    required bool isRecordedAudio,
    required bool isReadOnly,
    required bool showASRTTSActionButtons,
    required double topBorderRadius,
    required double bottomBorderRadius,
    required SpeakerStatus speakerStatus,
    bool isShareButtonLoading = false,
    int? currentDuration,
    int? totalDuration,
    PlayerController? playerController,
    Function? onMusicPlayOrStop,
    Function? onFileShare,
    bool showFeedbackIcon = true,
    required bool expandFeedbackIcon,
    String? hintText,
    int sourceCharLength = 0,
    bool showMicButton = false,
    bool showTranslateButton = true,
    Stream<int>? rawTimeStream,
    Function? onChanged,
    Function? onSubmitted,
    Function? onTranslateButtonTap,
    Function? onFeedbackButtonTap,
  })  : _textController = textController,
        _focusNode = focusNode,
        _hintText = hintText,
        _translateButtonTitle = translateButtonTitle,
        _textToCopy = textToCopy,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _currentDuration = currentDuration,
        _totalDuration = totalDuration,
        _sourceCharLength = sourceCharLength,
        _isRecordedAudio = isRecordedAudio,
        _showMicButton = showMicButton,
        _isReadOnly = isReadOnly,
        _isShareButtonLoading = isShareButtonLoading,
        _showTranslateButton = showTranslateButton,
        _showASRTTSActionButtons = showASRTTSActionButtons,
        _topBorderRadius = topBorderRadius,
        _bottomBorderRadius = bottomBorderRadius,
        _onChanged = onChanged,
        _onSubmitted = onSubmitted,
        _onMusicPlayOrStop = onMusicPlayOrStop,
        _onTranslateButtonTap = onTranslateButtonTap,
        _onFileShare = onFileShare,
        _expandFeedbackIcon = expandFeedbackIcon,
        _showFeedbackIcon = showFeedbackIcon,
        _playerController = playerController,
        _speakerStatus = speakerStatus,
        _rawTimeStream = rawTimeStream,
        _onFeedbackButtonTap = onFeedbackButtonTap;

  final TextEditingController _textController;
  final FocusNode _focusNode;
  final String? _translateButtonTitle;
  final String _textToCopy;
  final String? _hintText;
  final int _sourceCharLength;
  final int? _currentDuration, _totalDuration;
  final bool _isRecordedAudio,
      _showMicButton,
      _showASRTTSActionButtons,
      _showTranslateButton,
      _isReadOnly,
      _isShareButtonLoading,
      _expandFeedbackIcon,
      _showFeedbackIcon;
  final double _topBorderRadius, _bottomBorderRadius;
  final Color _backgroundColor, _borderColor;
  final Function? _onMusicPlayOrStop, _onFileShare;
  final Function? _onTranslateButtonTap,
      _onChanged,
      _onSubmitted,
      _onFeedbackButtonTap;

  final PlayerController? _playerController;
  final SpeakerStatus _speakerStatus;
  final Stream<int>? _rawTimeStream;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_topBorderRadius),
          topRight: Radius.circular(_topBorderRadius),
          bottomLeft: Radius.circular(_bottomBorderRadius),
          bottomRight: Radius.circular(_bottomBorderRadius),
        ),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(8).w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: regular18Primary(context),
                maxLines: null,
                expands: true,
                maxLength: textCharMaxLength,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                  hintText: _hintText,
                  hintStyle: regular20(context)
                      .copyWith(color: context.appTheme.hintTextColor),
                  hintMaxLines: 4,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
                onChanged: (newText) =>
                    _onChanged != null ? _onChanged!(newText) : null,
                onSubmitted: (newText) =>
                    _onSubmitted != null ? _onSubmitted!(newText) : null,
              ),
            ),
            SizedBox(height: 6.w),
            _showASRTTSActionButtons && !_showMicButton
                ? ASRAndTTSActions(
                    textToCopy: _textToCopy,
                    currentDuration: _currentDuration != null
                        ? DateTImeUtils().getTimeFromMilliseconds(
                            timeInMillisecond: _currentDuration!)
                        : '',
                    totalDuration: _totalDuration != null
                        ? DateTImeUtils().getTimeFromMilliseconds(
                            timeInMillisecond: _totalDuration!)
                        : '',
                    isRecordedAudio: _isRecordedAudio,
                    showFeedbackIcon: _showFeedbackIcon,
                    expandFeedbackIcon: _expandFeedbackIcon,
                    isShareButtonLoading: _isShareButtonLoading,
                    playerController: _playerController,
                    speakerStatus: _speakerStatus,
                    onMusicPlayOrStop: _onMusicPlayOrStop,
                    onFileShare: _onFileShare,
                    onFeedbackButtonTap: _onFeedbackButtonTap)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextAndMicLimit(
                        showMicButton: _showMicButton,
                        sourceCharLength: _sourceCharLength,
                        rawTimeStream: _rawTimeStream,
                      ),
                      if (_showTranslateButton)
                        CustomOutlineButton(
                          title: _translateButtonTitle,
                          isDisabled: _sourceCharLength > textCharMaxLength,
                          onTap: () => _onTranslateButtonTap != null
                              ? _onTranslateButtonTap!()
                              : null,
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
