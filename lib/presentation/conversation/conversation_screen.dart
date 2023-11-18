import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../animation/lottie_animation.dart';
import '../../common/controller/language_model_controller.dart';
import '../../common/widgets/common_app_bar.dart';
import '../../common/widgets/mic_button.dart';
import '../../common/widgets/text_field_with_actions.dart';
import '../../enums/current_mic.dart';
import '../../enums/mic_button_status.dart';
import '../../enums/speaker_status.dart';
import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../services/socket_io_client.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/network_utils.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/theme/app_theme_provider.dart';
import 'controller/conversation_controller.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationController _translationController;
  late SocketIOClient _socketIOClient;
  late LanguageModelController _languageModelController;
  late final Box _hiveDBInstance;

  @override
  void initState() {
    _translationController = Get.find();
    _languageModelController = Get.find();
    _socketIOClient = Get.find();
    _hiveDBInstance = Hive.box(hiveDBName);
    _translationController.getSourceTargetLangFromDB();
    _translationController.setSourceLanguageList();
    _translationController.setTargetLanguageList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Column(
                children: [
                  SizedBox(
                    height: 16.h,
                  ),
                  CommonAppBar(
                      title: converse.tr, onBackPress: () => Get.back()),
                  SizedBox(
                    height: 8.h,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 20.w),
                        _buildSourceTextField(),
                        _buildTargetTextField(),
                      ],
                    ),
                  ),
                  Obx(
                    () => SizedBox(
                        height: _translationController.isKeyboardVisible.value
                            ? 12.h
                            : 20.h),
                  ),
                  Obx(
                    () => _translationController.isKeyboardVisible.value
                        ? const SizedBox.shrink()
                        : _buildMicButton(),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          _buildLoadingAnimation()
        ],
      ),
    );
  }

  Widget _buildSourceTextField() {
    return Expanded(
      child: Obx(
        () => TextFieldWithActions(
            textController: _translationController.sourceLangTextController,
            focusNode: FocusNode(),
            backgroundColor: context.appTheme.normalTextFieldColor,
            borderColor: context.appTheme.disabledBGColor,
            hintText: isCurrentlyRecording()
                ? _translationController.currentMic.value ==
                        CurrentlySelectedMic.source
                    ? kListeningHintText.tr
                    : ''
                : _translationController.micButtonStatus.value ==
                        MicButtonStatus.pressed
                    ? connecting.tr
                    : converseHintText.tr,
            translateButtonTitle: kTranslate.tr,
            currentDuration: _translationController.currentDuration.value,
            totalDuration: _translationController.maxDuration.value,
            isRecordedAudio: !_hiveDBInstance.get(isStreamingPreferred),
            topBorderRadius: textFieldRadius,
            bottomBorderRadius: 0,
            showTranslateButton: false,
            showASRTTSActionButtons: true,
            showFeedbackIcon:
                _translationController.isTranslateCompleted.value &&
                    _translationController.currentMic.value ==
                        CurrentlySelectedMic.source &&
                    !_hiveDBInstance.get(isStreamingPreferred),
            expandFeedbackIcon: _translationController.expandFeedbackIcon.value,
            isReadOnly: true,
            isShareButtonLoading:
                _translationController.isTargetShareLoading.value,
            textToCopy: _translationController.sourceOutputText.value,
            onMusicPlayOrStop: () =>
                _translationController.playStopTTSOutput(true),
            onFileShare: () =>
                _translationController.shareAudioFile(isSourceLang: true),
            onFeedbackButtonTap: () {
              Get.toNamed(AppRoutes.feedbackRoute, arguments: {
                // Fixes Dart shallow copy issue:
                'requestPayload': json.decode(
                    json.encode(_translationController.lastComputeRequest)),
                'requestResponse': json.decode(
                    json.encode(_translationController.lastComputeResponse))
              });
            },
            playerController: _translationController.playerController,
            speakerStatus: _translationController.sourceSpeakerStatus.value,
            rawTimeStream: _translationController.stopWatchTimer.rawTime,
            showMicButton: isCurrentlyRecording() &&
                _translationController.currentMic.value ==
                    CurrentlySelectedMic.source),
      ),
    );
  }

  Widget _buildTargetTextField() {
    return Expanded(
      child: Obx(
        () => TextFieldWithActions(
          textController: _translationController.targetLangTextController,
          focusNode: FocusNode(),
          backgroundColor: context.appTheme.normalTextFieldColor,
          borderColor: context.appTheme.disabledBGColor,
          hintText: isCurrentlyRecording()
              ? _translationController.currentMic.value ==
                      CurrentlySelectedMic.target
                  ? kListeningHintText.tr
                  : ''
              : _translationController.micButtonStatus.value ==
                      MicButtonStatus.pressed
                  ? connecting.tr
                  : converseHintText.tr,
          translateButtonTitle: kTranslate.tr,
          currentDuration: _translationController.currentDuration.value,
          totalDuration: _translationController.maxDuration.value,
          isRecordedAudio: !_hiveDBInstance.get(isStreamingPreferred),
          topBorderRadius: 0,
          bottomBorderRadius: textFieldRadius,
          showTranslateButton: false,
          showFeedbackIcon: _translationController.isTranslateCompleted.value &&
              _translationController.currentMic.value ==
                  CurrentlySelectedMic.target &&
              !_hiveDBInstance.get(isStreamingPreferred),
          expandFeedbackIcon: _translationController.expandFeedbackIcon.value,
          showASRTTSActionButtons: true,
          isReadOnly: true,
          isShareButtonLoading:
              _translationController.isSourceShareLoading.value,
          textToCopy: _translationController.targetOutputText.value,
          onFileShare: () =>
              _translationController.shareAudioFile(isSourceLang: false),
          onMusicPlayOrStop: () =>
              _translationController.playStopTTSOutput(false),
          playerController: _translationController.playerController,
          speakerStatus: _translationController.targetSpeakerStatus.value,
          rawTimeStream: _translationController.stopWatchTimer.rawTime,
          showMicButton: isCurrentlyRecording() &&
              _translationController.currentMic.value ==
                  CurrentlySelectedMic.target,
          onFeedbackButtonTap: () {
            Get.toNamed(AppRoutes.feedbackRoute, arguments: {
              // Fixes Dart shallow copy issue:
              'requestPayload': json.decode(
                  json.encode(_translationController.lastComputeRequest)),
              'requestResponse': json.decode(
                  json.encode(_translationController.lastComputeResponse))
            });
          },
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 8.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedOpacity(
            opacity: isCurrentlyRecording() ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: LottieBuilder.asset(
              animationStaticWaveForRecording,
              fit: BoxFit.fitWidth,
              animate: isCurrentlyRecording(),
              repeat: true,
            ),
          ),
          Positioned(
            left: 20,
            child: Obx(() {
              String sourceLangCode =
                      _translationController.selectedSourceLanguageCode.value,
                  selectedSourceLang = "";

              selectedSourceLang = sourceLangCode.isNotEmpty &&
                      (_translationController.sourceLangListRegular
                              .contains(sourceLangCode) ||
                          _translationController.sourceLangListBeta
                              .contains(sourceLangCode))
                  ? APIConstants.getLanNameInAppLang(
                      _translationController.selectedSourceLanguageCode.value)
                  : kTranslateSourceTitle.tr;
              return MicButton(
                micButtonStatus: _translationController.currentMic.value ==
                        CurrentlySelectedMic.source
                    ? _translationController.micButtonStatus.value
                    : MicButtonStatus.released,
                showLanguage: true,
                languageName: selectedSourceLang,
                onMicButtonTap: (isPressed) {
                  if (_translationController.currentMic.value ==
                          CurrentlySelectedMic.target &&
                      isCurrentlyRecording()) return;
                  _translationController.currentMic.value =
                      CurrentlySelectedMic.source;
                  micButtonActions(startMicRecording: isPressed);
                },
                onLanguageTap: () async {
                  dynamic selectedSourceLangCode = await Get.toNamed(
                      AppRoutes.languageSelectionRoute,
                      arguments: {
                        kLanguageListRegular:
                            _translationController.sourceLangListRegular,
                        kLanguageListBeta:
                            _translationController.sourceLangListBeta,
                        kIsSourceLanguage: true,
                        selectedLanguage: _translationController
                            .selectedSourceLanguageCode.value,
                      });
                  if (selectedSourceLangCode != null) {
                    _translationController.selectedSourceLanguageCode.value =
                        selectedSourceLangCode;
                    _hiveDBInstance.put(
                        preferredSourceLanguage, selectedSourceLangCode);
                    String selectedTargetLangCode =
                        _translationController.selectedTargetLanguageCode.value;
                    if (selectedTargetLangCode.isNotEmpty) {
                      if (!_languageModelController
                          .sourceTargetLanguageMap[selectedSourceLangCode]!
                          .contains(selectedTargetLangCode)) {
                        _translationController
                            .selectedTargetLanguageCode.value = '';
                        _hiveDBInstance.put(preferredTargetLanguage, null);
                        await _translationController.resetAllValues();
                      } else if (_translationController.currentMic.value ==
                              CurrentlySelectedMic.target &&
                          _translationController
                              .selectedTargetLanguageCode.value.isNotEmpty &&
                          (_translationController.base64EncodedAudioContent ??
                                  '')
                              .isNotEmpty &&
                          await isNetworkConnected()) {
                        _translationController.getComputeResponseASRTrans(
                            isRecorded: true,
                            base64Value: _translationController
                                .base64EncodedAudioContent);
                      } else {
                        await _translationController.resetAllValues();
                      }
                    }
                  }
                },
              );
            }),
          ),
          Positioned(
            right: 20,
            child: Obx(() {
              String targetLangCode =
                      _translationController.selectedTargetLanguageCode.value,
                  selectedTargetLang = "";

              selectedTargetLang = targetLangCode.isNotEmpty &&
                      (_translationController.targetLangListRegular
                              .contains(targetLangCode) ||
                          _translationController.targetLangListBeta
                              .contains(targetLangCode))
                  ? APIConstants.getLanNameInAppLang(
                      _translationController.selectedTargetLanguageCode.value)
                  : kTranslateTargetTitle.tr;
              return MicButton(
                micButtonStatus: _translationController.currentMic.value ==
                        CurrentlySelectedMic.target
                    ? _translationController.micButtonStatus.value
                    : MicButtonStatus.released,
                showLanguage: true,
                languageName: selectedTargetLang,
                onMicButtonTap: (isPressed) {
                  if (_translationController.currentMic.value ==
                          CurrentlySelectedMic.source &&
                      isCurrentlyRecording()) return;
                  _translationController.currentMic.value =
                      CurrentlySelectedMic.target;
                  micButtonActions(startMicRecording: isPressed);
                },
                onLanguageTap: () async {
                  if (_translationController
                      .selectedSourceLanguageCode.value.isEmpty) {
                    showDefaultSnackbar(message: errorSelectSourceLangFirst.tr);
                    return;
                  }

                  _translationController.setTargetLanguageList();

                  dynamic selectedTargetLangCode = await Get.toNamed(
                      AppRoutes.languageSelectionRoute,
                      arguments: {
                        kLanguageListRegular:
                            _translationController.targetLangListRegular,
                        kLanguageListBeta:
                            _translationController.targetLangListBeta,
                        kIsSourceLanguage: false,
                        selectedLanguage: _translationController
                            .selectedTargetLanguageCode.value,
                      });
                  if (selectedTargetLangCode != null) {
                    _translationController.selectedTargetLanguageCode.value =
                        selectedTargetLangCode;
                    _hiveDBInstance.put(
                        preferredTargetLanguage, selectedTargetLangCode);

                    if (_translationController.currentMic.value ==
                            CurrentlySelectedMic.source &&
                        _translationController
                            .selectedSourceLanguageCode.value.isNotEmpty &&
                        (_translationController.base64EncodedAudioContent ?? '')
                            .isNotEmpty &&
                        await isNetworkConnected()) {
                      _translationController.getComputeResponseASRTrans(
                          isRecorded: true,
                          base64Value:
                              _translationController.base64EncodedAudioContent);
                    } else {
                      await _translationController.resetAllValues();
                    }
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Obx(() {
      if (_translationController.isLoading.value) {
        return LottieAnimation(
            context: context,
            lottieAsset: animationLoadingLine,
            footerText: _translationController.isLoading.value
                ? computeCallLoadingText.tr
                : kTranslationLoadingAnimationText.tr);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  bool isAudioPlaying() {
    return (_translationController.targetSpeakerStatus.value ==
            SpeakerStatus.playing ||
        _translationController.sourceSpeakerStatus.value ==
            SpeakerStatus.playing);
  }

  bool isCurrentlyRecording() {
    return _hiveDBInstance.get(isStreamingPreferred)
        ? _socketIOClient.isMicConnected.value &&
            _translationController.micButtonStatus.value ==
                MicButtonStatus.pressed
        : _translationController.micButtonStatus.value ==
            MicButtonStatus.pressed;
  }

  void micButtonActions({required bool startMicRecording}) async {
    if (!await isNetworkConnected()) {
      showDefaultSnackbar(message: errorNoInternetTitle.tr);
    } else if (_translationController.isSourceAndTargetLangSelected()) {
      if (startMicRecording) {
        _translationController.micButtonStatus.value = MicButtonStatus.pressed;
        _translationController.startVoiceRecording();
      } else {
        if (_translationController.micButtonStatus.value ==
            MicButtonStatus.pressed) {
          _translationController.micButtonStatus.value =
              MicButtonStatus.released;
          _translationController.stopVoiceRecordingAndGetResult();
        }
      }
    } else if (startMicRecording) {
      showDefaultSnackbar(message: kErrorSelectSourceAndTargetScreen.tr);
    }
  }
}
