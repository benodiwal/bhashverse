import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../common/controller/language_model_controller.dart';
import '../../../localization/localization_keys.dart';
import '../../../services/dhruva_api_client.dart';
import '../../../services/transliteration_app_api_client.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/language_map_translated.dart';
import '../../../utils/snackbar_utils.dart';

class TextTranslateController extends GetxController {
  TextEditingController sourceLangTextController = TextEditingController(),
      targetLangTextController = TextEditingController();

  late DHRUVAAPIClient _dhruvaapiClient;
  late TransliterationAppAPIClient _transliterationAppAPIClient;
  late LanguageModelController _languageModelController;

  final ScrollController transliterationHintsScrollController =
      ScrollController();

  RxBool isTranslateCompleted = false.obs,
      isLoading = false.obs,
      isKeyboardVisible = false.obs,
      isScrolledTransliterationHints = false.obs,
      expandFeedbackIcon = true.obs;
  RxString selectedSourceLanguageCode = ''.obs,
      targetOutputText = ''.obs,
      selectedTargetLanguageCode = ''.obs;
  String? transliterationModelToUse = '';
  String currentlyTypedWordForTransliteration = '';
  RxInt sourceTextCharLimit = 0.obs;
  RxList transliterationWordHints = [].obs;
  int lastOffsetOfCursor = 0;

  List<dynamic> sourceLangListRegular = [],
      sourceLangListBeta = [],
      targetLangListRegular = [],
      targetLangListBeta = [];

  // TODO:  uncomment when TTS feature added

  /* RxBool isSourceShareLoading = false.obs, isTargetShareLoading = false.obs;

  RxInt maxDuration = 0.obs, currentDuration = 0.obs;

  RxString sourceLangTTSPath = ''.obs, targetLangTTSPath = ''.obs;

   File? ttsAudioFile;
  dynamic ttsResponse;
  Rx<SpeakerStatus> sourceSpeakerStatus = Rx(SpeakerStatus.disabled),
      targetSpeakerStatus = Rx(SpeakerStatus.disabled);
  late Directory appDirectory;
  late PlayerController playerController; */

  late final Box _hiveDBInstance;

// for sending payload in feedback API
  Map<String, dynamic> lastComputeRequest = {};
  Map<String, dynamic> lastComputeResponse = {};

  @override
  void onInit() {
    _dhruvaapiClient = Get.find();
    _transliterationAppAPIClient = Get.find();
    _languageModelController = Get.find();
    _hiveDBInstance = Hive.box(hiveDBName);

    sourceLangTextController
        .addListener(clearTransliterationHintsIfCursorMoved);

    // TODO:  uncomment when TTS feature added
    // playerController = PlayerController();

    /* playerController.onCurrentDurationChanged.listen((duration) {
      currentDuration.value = duration;
    });

    playerController.onPlayerStateChanged.listen((_) {
      switch (playerController.playerState) {
        case PlayerState.initialized:
          maxDuration.value = playerController.maxDuration;
          break;
        case PlayerState.paused:
          sourceSpeakerStatus.value = SpeakerStatus.stopped;
          targetSpeakerStatus.value = SpeakerStatus.stopped;
          currentDuration.value = 0;
          break;
        case PlayerState.stopped:
          currentDuration.value = 0;
          break;
        default:
      }
    }); */

    transliterationHintsScrollController.addListener(() {
      isScrolledTransliterationHints.value = true;
    });
    super.onInit();
  }

  @override
  void onClose() async {
    sourceLangTextController
        .removeListener(clearTransliterationHintsIfCursorMoved);
    sourceLangTextController.dispose();
    targetLangTextController.dispose();
    // TODO:  uncomment when TTS feature added
    // await disposePlayer();
    super.onClose();
  }

  void getSourceTargetLangFromDB() {
    String? selectedSourceLanguage =
        _hiveDBInstance.get(preferredSourceLangTextScreen);

    if (selectedSourceLanguage == null || selectedSourceLanguage.isEmpty) {
      selectedSourceLanguage = _hiveDBInstance.get(preferredAppLocale);
    }

    if (_languageModelController.translationLanguageMap.keys
            .toList()
            .contains(selectedSourceLanguage) &&
        !textSkipSourceLang.contains(selectedSourceLanguage)) {
      selectedSourceLanguageCode.value = selectedSourceLanguage ?? '';
      if (isTransliterationEnabled()) {
        setModelForTransliteration();
      }
    }

    String? selectedTargetLanguage =
        _hiveDBInstance.get(preferredTargetLangTextScreen);
    if (selectedTargetLanguage != null &&
        selectedTargetLanguage.isNotEmpty &&
        selectedSourceLanguageCode.value.isNotEmpty &&
        _languageModelController
            .translationLanguageMap[selectedSourceLanguageCode.value]!
            .toList()
            .contains(selectedTargetLanguage)) {
      selectedTargetLanguageCode.value = selectedTargetLanguage;
    }
  }

  void swapSourceAndTargetLanguage() {
    if (isSourceAndTargetLangSelected()) {
      bool isTargetLangSkippedInSource =
          textSkipTargetLang.contains(selectedSourceLanguageCode.value);

      bool isSourceLangSkippedInTarget =
          textSkipSourceLang.contains(selectedTargetLanguageCode.value);

      if (_languageModelController.translationLanguageMap.keys
              .contains(selectedTargetLanguageCode.value) &&
          _languageModelController
                  .translationLanguageMap[selectedTargetLanguageCode.value] !=
              null &&
          _languageModelController
              .translationLanguageMap[selectedTargetLanguageCode.value]!
              .contains(selectedSourceLanguageCode.value) &&
          !isTargetLangSkippedInSource &&
          !isSourceLangSkippedInTarget) {
        String tempSourceLanguage = selectedSourceLanguageCode.value;
        selectedSourceLanguageCode.value = selectedTargetLanguageCode.value;
        selectedTargetLanguageCode.value = tempSourceLanguage;
        _hiveDBInstance.put(
            preferredSourceLangTextScreen, selectedSourceLanguageCode.value);
        _hiveDBInstance.put(
            preferredTargetLangTextScreen, selectedTargetLanguageCode.value);
        setSourceLanguageList();
        setTargetLanguageList();
        resetAllValues();
      } else {
        String sourceLanguage = APIConstants.getLanguageNameFromCode(
            selectedSourceLanguageCode.value);
        String targetLanguage = APIConstants.getLanguageNameFromCode(
            selectedTargetLanguageCode.value);
        showDefaultSnackbar(
            message:
                '$targetLanguage - $sourceLanguage ${translationNotPossible.tr}');
      }
    } else {
      showDefaultSnackbar(message: kErrorSelectSourceAndTargetScreen.tr);
    }
  }

  bool isSourceAndTargetLangSelected() =>
      selectedSourceLanguageCode.value.isNotEmpty &&
      selectedTargetLanguageCode.value.isNotEmpty;

  Future<void> getTransliterationOutput(String sourceText) async {
    currentlyTypedWordForTransliteration = sourceText;
    if (transliterationModelToUse == null ||
        transliterationModelToUse!.isEmpty) {
      clearTransliterationHints();
      return;
    }
    var transliterationPayloadToSend = {};
    transliterationPayloadToSend['input'] = [
      {'source': sourceText}
    ];

    transliterationPayloadToSend['modelId'] = transliterationModelToUse;
    transliterationPayloadToSend['task'] = 'transliteration';
    transliterationPayloadToSend['userId'] = null;

    var response =
        await _transliterationAppAPIClient.sendTransliterationRequest(
            transliterationPayload: transliterationPayloadToSend);

    response?.when(
      success: (data) async {
        if (currentlyTypedWordForTransliteration ==
            data['output'][0]['source']) {
          transliterationWordHints.value = data['output'][0]['target'];
          if (!transliterationWordHints
              .contains(currentlyTypedWordForTransliteration)) {
            transliterationWordHints.add(currentlyTypedWordForTransliteration);
          }
        }
      },
      failure: (_) {},
    );
  }

  Future<void> getComputeResponseASRTrans() async {
    isLoading.value = true;
    String translationServiceId = '';

    translationServiceId = APIConstants.getTaskTypeServiceID(
            _languageModelController.translationConfigResponse,
            'translation',
            selectedSourceLanguageCode.value,
            selectedTargetLanguageCode.value) ??
        '';

    var asrPayloadToSend = APIConstants.createComputePayloadASRTrans(
        srcLanguage: selectedSourceLanguageCode.value,
        targetLanguage: selectedTargetLanguageCode.value,
        isRecorded: false,
        inputData: sourceLangTextController.text,
        translationServiceID: translationServiceId,
        preferredGender: _hiveDBInstance.get(preferredVoiceAssistantGender));

    var response = await _dhruvaapiClient.sendComputeRequest(
        baseUrl: _languageModelController.translationConfigResponse
            .pipelineInferenceAPIEndPoint?.callbackUrl,
        authorizationKey: _languageModelController.translationConfigResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.name,
        authorizationValue: _languageModelController.translationConfigResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.value,
        computePayload: asrPayloadToSend);

    lastComputeRequest = asrPayloadToSend;

    response.when(
      success: (taskResponse) async {
        lastComputeResponse = taskResponse.toJson();
        targetOutputText.value = taskResponse.pipelineResponse
                ?.firstWhere((element) => element.taskType == 'translation')
                .output
                ?.first
                .target
                ?.trim() ??
            '';
        if (targetOutputText.value.isEmpty) {
          isLoading.value = false;
          showDefaultSnackbar(message: responseNotReceived.tr);
          return;
        }
        targetLangTextController.text = targetOutputText.value;
        isTranslateCompleted.value = true;
        isLoading.value = false;
        Future.delayed(const Duration(seconds: 3))
            .then((value) => expandFeedbackIcon.value = false);

        // TODO:  uncomment when TTS feature added
        // sourceLangTTSPath.value = '';
        // targetLangTTSPath.value = '';
        // sourceSpeakerStatus.value = SpeakerStatus.stopped;
        // targetSpeakerStatus.value = SpeakerStatus.stopped;
      },
      failure: (error) {
        isLoading.value = false;
        showDefaultSnackbar(message: somethingWentWrong.tr);
      },
    );
  }

  // TODO:  uncomment when TTS feature added

  /* Future<void> getComputeResTTS({
    required String sourceText,
    required String languageCode,
    required bool isTargetLanguage,
  }) async {
    String ttsServiceId = APIConstants.getTaskTypeServiceID(
            _languageModelController.taskSequenceResponse,
            'tts',
            languageCode) ??
        '';

    var asrPayloadToSend = APIConstants.createComputePayloadTTS(
        srcLanguage: languageCode,
        inputData: sourceText,
        ttsServiceID: ttsServiceId,
        preferredGender: _hiveDBInstance.get(preferredVoiceAssistantGender));

    var response = await _dhruvaapiClient.sendComputeRequest(
        baseUrl: _languageModelController
            .taskSequenceResponse.pipelineInferenceAPIEndPoint?.callbackUrl,
        authorizationKey: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.name,
        authorizationValue: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.value,
        computePayload: asrPayloadToSend);

    if (lastComputeRequest['pipelineTasks'] != null &&
        lastComputeRequest['pipelineTasks'].isNotEmpty) {
      (lastComputeRequest['pipelineTasks'])
          .removeWhere((element) => element['taskType'] == 'tts');
    }

    lastComputeRequest['pipelineTasks']
        .addAll(asrPayloadToSend['pipelineTasks']);

    await response.when(
      success: (taskResponse) async {
        lastComputeResponse['pipelineResponse']
            .removeWhere((element) => element['taskType'] == 'tts');
        lastComputeResponse['pipelineResponse']
            .addAll(taskResponse.toJson()['pipelineResponse']);

        ttsResponse = taskResponse.pipelineResponse
            ?.firstWhere((element) => element.taskType == 'tts')
            .audio?[0]
            .audioContent;

        // Save TTS audio to file
        if (ttsResponse != null) {
          String ttsFilePath = await createTTSAudioFIle(ttsResponse);
          isTargetLanguage
              ? targetLangTTSPath.value = ttsFilePath
              : sourceLangTTSPath.value = ttsFilePath;
        } else {
          showDefaultSnackbar(message: noVoiceAssistantAvailable.tr);
          return;
        }
      },
      failure: (error) {
        isTargetLanguage
            ? targetSpeakerStatus.value = SpeakerStatus.stopped
            : sourceSpeakerStatus.value = SpeakerStatus.stopped;
        showDefaultSnackbar(
            message: somethingWentWrong.tr);
        return;
      },
    );
  } 
  
   void playStopTTSOutput(bool isPlayingSource) async {
    if (playerController.playerState.isPlaying) {
      await stopPlayer();
      return;
    }

    String? audioPath = '';

    if (isPlayingSource) {
      if (sourceLangTTSPath.value.isEmpty) {
        if (!await isNetworkConnected()) {
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
          return;
        }
        sourceSpeakerStatus.value = SpeakerStatus.loading;
        await getComputeResTTS(
          sourceText: sourceLangTextController.text,
          languageCode: selectedSourceLanguageCode.value,
          isTargetLanguage: false,
        );
      }
      audioPath = sourceLangTTSPath.value;
      sourceSpeakerStatus.value = SpeakerStatus.playing;
    } else {
      if (targetLangTTSPath.value.isEmpty) {
        if (!await isNetworkConnected()) {
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
          return;
        }
        targetSpeakerStatus.value = SpeakerStatus.loading;
        await getComputeResTTS(
          sourceText: targetOutputText.value,
          languageCode: selectedTargetLanguageCode.value,
          isTargetLanguage: true,
        );
      }
      audioPath = targetLangTTSPath.value;
      targetSpeakerStatus.value = SpeakerStatus.playing;
    }

    if (audioPath.isNotEmpty) {
      isPlayingSource
          ? sourceSpeakerStatus.value = SpeakerStatus.playing
          : targetSpeakerStatus.value = SpeakerStatus.playing;

      await preparePlayerAndWaveforms(audioPath,
          isRecordedAudio: false, isTargetLanguage: !isPlayingSource);
    }
  } 

   void shareAudioFile({required bool isSourceLang}) async {
    if (isTranslateCompleted.value) {
       String? audioPathToShare =
          isSourceLang ? sourceLangTTSPath.value : targetLangTTSPath.value; 

      if (audioPathToShare.isEmpty) {
        if (!await isNetworkConnected()) {
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
          return;
        }
        String sourceText = isSourceLang
            ? sourceLangTextController.text
            : targetLangTextController.text;

        String languageCode = isSourceLang
            ? selectedSourceLanguageCode.value
            : selectedTargetLanguageCode.value;

        if (sourceText.isEmpty) {
          showDefaultSnackbar(message: noAudioFoundToShare.tr);
          return;
        }

        isSourceLang
            ? isSourceShareLoading.value = true
            : isTargetShareLoading.value = true;

        await getComputeResTTS(
          sourceText: sourceText,
          languageCode: languageCode,
          isTargetLanguage: !isSourceLang,
        );
        audioPathToShare =
            isSourceLang ? sourceLangTTSPath.value : targetLangTTSPath.value;
        isSourceLang
            ? isSourceShareLoading.value = false
            : isTargetShareLoading.value = false; 
      }

      await Share.shareXFiles(
        [XFile(audioPathToShare)],
        sharePositionOrigin: Rect.fromLTWH(
            0, 0, ScreenUtil.screenWidth, ScreenUtil.screenHeight / 2),
      );
    } else {
      showDefaultSnackbar(message: noAudioFoundToShare.tr);
    }
  }
  
  Future<void> preparePlayerAndWaveforms(
    String filePath, {
    required bool isRecordedAudio,
    required bool isTargetLanguage,
  }) async {
    await stopPlayer();
    if (isTargetLanguage) {
      targetSpeakerStatus.value = SpeakerStatus.playing;
    } else {
      sourceSpeakerStatus.value = SpeakerStatus.playing;
    }
    await playerController.preparePlayer(
        path: filePath,
        noOfSamples: WaveformStyle.getDefaultPlayerStyle(
                isRecordedAudio: isRecordedAudio)
            .getSamplesForWidth(WaveformStyle.getDefaultWidth));
    maxDuration.value = playerController.maxDuration;
    startOrPausePlayer();
  }

  void startOrPausePlayer() async {
    playerController.playerState.isPlaying
        ? await playerController.pausePlayer()
        : await playerController.startPlayer(
            finishMode: FinishMode.pause,
          );
  }

  Future<void> stopPlayer() async {
    if (playerController.playerState.isPlaying ||
        playerController.playerState == PlayerState.paused) {
      await playerController.stopPlayer();
    }
    targetSpeakerStatus.value = SpeakerStatus.stopped;
    sourceSpeakerStatus.value = SpeakerStatus.stopped;
  }

  Future<void> disposePlayer() async {
    await stopPlayer();
    playerController.dispose();
  }
  
  */

  void setModelForTransliteration() {
    transliterationModelToUse =
        _languageModelController.getAvailableTransliterationModelsForLanguage(
            selectedSourceLanguageCode.value);
  }

  void clearTransliterationHintsIfCursorMoved() {
    int difference =
        lastOffsetOfCursor - sourceLangTextController.selection.base.offset;
    if (difference > 0 || difference < -1) {
      clearTransliterationHints();
    }
    lastOffsetOfCursor = sourceLangTextController.selection.base.offset;
  }

  void clearTransliterationHints() {
    transliterationWordHints.clear();
    currentlyTypedWordForTransliteration = '';
  }

  setSourceLanguageList() {
    sourceLangListRegular.clear();
    sourceLangListBeta.clear();

    sourceLangListRegular =
        _languageModelController.translationLanguageMap.keys.toList();

    for (int i = 0; i < sourceLangListRegular.length; i++) {
      var language = sourceLangListRegular[i];
      if (textSkipSourceLang.contains(language)) {
        sourceLangListRegular.removeAt(i);
        i--;
      } else if (textBetaSourceLang.contains(language)) {
        sourceLangListBeta.add(sourceLangListRegular[i]);
        sourceLangListRegular.removeAt(i);
        i--;
      }
    }
  }

  void setTargetLanguageList() {
    if (selectedSourceLanguageCode.value.isEmpty) {
      return;
    }

    targetLangListRegular.clear();
    targetLangListBeta.clear();

    targetLangListRegular = _languageModelController
        .translationLanguageMap[selectedSourceLanguageCode.value]!
        .toList();

    for (int i = 0; i < targetLangListRegular.length; i++) {
      var language = targetLangListRegular[i];
      if (textSkipTargetLang.contains(language)) {
        targetLangListRegular.removeAt(i);
        i--;
      } else if (textBetaTargetLang.contains(language)) {
        targetLangListBeta.add(targetLangListRegular[i]);
        targetLangListRegular.removeAt(i);
        i--;
      }
    }
  }

  Future<void> resetAllValues() async {
    sourceLangTextController.clear();
    targetLangTextController.clear();
    isTranslateCompleted.value = false;
    sourceTextCharLimit.value = 0;
    // TODO:  uncomment when TTS feature added
    // maxDuration.value = 0;
    // currentDuration.value = 0;
    // ttsResponse = null;
    // await stopPlayer();
    // sourceSpeakerStatus.value = SpeakerStatus.disabled;
    // targetSpeakerStatus.value = SpeakerStatus.disabled;
    // sourceLangTTSPath.value = '';
    // targetLangTTSPath.value = '';
    // isSourceShareLoading.value = false;
    // isTargetShareLoading.value = false;
    targetOutputText.value = '';
    lastComputeRequest.clear();
    lastComputeResponse.clear();
    if (isTransliterationEnabled()) {
      setModelForTransliteration();
      clearTransliterationHints();
    }
  }

  bool isTransliterationEnabled() {
    return _hiveDBInstance.get(enableTransliteration, defaultValue: true) &&
        selectedSourceLanguageCode.value != defaultLangCode;
  }
}
