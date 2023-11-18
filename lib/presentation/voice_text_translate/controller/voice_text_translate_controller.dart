import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:vibration/vibration.dart';

import '../../../common/controller/language_model_controller.dart';
import '../../../enums/speaker_status.dart';
import '../../../enums/mic_button_status.dart';
import '../../../localization/localization_keys.dart';
import '../../../services/dhruva_api_client.dart';
import '../../../services/socket_io_client.dart';
import '../../../services/transliteration_app_api_client.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/language_map_translated.dart';
import '../../../utils/file_helper.dart';
import '../../../utils/network_utils.dart';
import '../../../utils/permission_handler.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../utils/voice_recorder.dart';
import '../../../utils/waveform_style.dart';

class VoiceTextTranslateController extends GetxController {
  late DHRUVAAPIClient _dhruvaapiClient;
  late TransliterationAppAPIClient _translationAppAPIClient;
  late LanguageModelController _languageModelController;

  TextEditingController sourceLangTextController = TextEditingController(),
      targetLangTextController = TextEditingController();

  final ScrollController transliterationHintsScrollController =
      ScrollController();

  bool isMicPermissionGranted = false;
  RxBool isTranslateCompleted = false.obs,
      isLoading = false.obs,
      isKeyboardVisible = false.obs,
      isScrolledTransliterationHints = false.obs,
      isRecordedViaMic = false.obs,
      isSourceShareLoading = false.obs,
      isTargetShareLoading = false.obs,
      expandFeedbackIcon = true.obs;
  RxString selectedSourceLanguageCode = ''.obs,
      selectedTargetLanguageCode = ''.obs,
      targetOutputText = ''.obs,
      sourceLangTTSPath = ''.obs,
      targetLangTTSPath = ''.obs;
  String? sourceLangASRPath = '', transliterationModelToUse = '';
  RxInt maxDuration = 0.obs,
      currentDuration = 0.obs,
      sourceTextCharLimit = 0.obs;
  RxList transliterationWordHints = [].obs;
  String currentlyTypedWordForTransliteration = '', lastFinalOutput = '';
  Rx<MicButtonStatus> micButtonStatus = Rx(MicButtonStatus.released);
  Rx<SpeakerStatus> sourceSpeakerStatus = Rx(SpeakerStatus.disabled),
      targetSpeakerStatus = Rx(SpeakerStatus.disabled);

  List<dynamic> sourceLangListRegular = [],
      sourceLangListBeta = [],
      targetLangListRegular = [],
      targetLangListBeta = [];

  List<int> recordedData = [];
  final RecorderStream _recorder = RecorderStream();
  final VoiceRecorder _voiceRecorder = VoiceRecorder();
  final stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  late PlayerController playerController;
  StreamSubscription<Uint8List>? micStreamSubscription;
  DateTime? recordingStartTime;
  int samplingRate = 16000, lastOffsetOfCursor = 0;
  late Worker streamingResponseListener,
      socketIOErrorListener,
      socketConnectionListener;

  late SocketIOClient _socketIOClient;

  late final Box _hiveDBInstance;

  // for sending payload in feedback API
  Map<String, dynamic> lastComputeRequest = {};
  Map<String, dynamic> lastComputeResponse = {};

  @override
  void onInit() {
    _dhruvaapiClient = Get.find();
    _socketIOClient = Get.find();
    _translationAppAPIClient = Get.find();
    _languageModelController = Get.find();
    _hiveDBInstance = Hive.box(hiveDBName);
    _recorder.initialize();
    playerController = PlayerController();

//  Connectivity listener
    Connectivity()
        .checkConnectivity()
        .then((newConnectivity) => updateSamplingRate(newConnectivity));

    Connectivity().onConnectivityChanged.listen(
          (newConnectivity) => updateSamplingRate(newConnectivity),
        );

// Audio player listener

    playerController.onCompletion.listen((event) {
      sourceSpeakerStatus.value = SpeakerStatus.stopped;
      targetSpeakerStatus.value = SpeakerStatus.stopped;
    });

    playerController.onCurrentDurationChanged.listen((duration) {
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
    });

// Transliteration listener

    sourceLangTextController
        .addListener(clearTransliterationHintsIfCursorMoved);

    transliterationHintsScrollController.addListener(() {
      isScrolledTransliterationHints.value = true;
    });

// Stopwatch listener for mic recording time

    stopWatchTimer.rawTime.listen((event) {
      if (micButtonStatus.value == MicButtonStatus.pressed &&
          (event + 1) >= recordingMaxTimeLimit) {
        stopWatchTimer.onStopTimer();
        micButtonStatus.value = MicButtonStatus.released;
        stopVoiceRecordingAndGetResult();
      }
    });

// Init method call

    super.onInit();

// Socket IO connection listeners

    socketConnectionListener =
        ever(_socketIOClient.isMicConnected, (isConnected) async {
      if (isConnected) {
        stopWatchTimer.onStartTimer();
      }
    }, condition: () => _socketIOClient.isMicConnected.value);

// Socket IO response listeners

    streamingResponseListener =
        ever(_socketIOClient.socketResponse, (response) async {
      await displaySocketIOResponse(response);
      if (!isRecordedViaMic.value) isRecordedViaMic.value = true;
      if (!_socketIOClient.isMicConnected.value) {
        isRecordedViaMic.value = true;
        sourceSpeakerStatus.value = SpeakerStatus.stopped;
        sourceLangASRPath =
            await saveStreamAudioToFile(recordedData, samplingRate);
      }
    }, condition: () => _socketIOClient.isMicConnected.value);

// Socket IO error listeners

    socketIOErrorListener = ever(_socketIOClient.hasError, (isAborted) {
      if (isAborted && micButtonStatus.value == MicButtonStatus.pressed) {
        micButtonStatus.value = MicButtonStatus.released;
        showDefaultSnackbar(
            message: _socketIOClient.socketError ?? somethingWentWrong.tr);
      }
    }, condition: !_socketIOClient.isConnected());
  }

  @override
  void onClose() async {
    sourceLangTextController
        .removeListener(clearTransliterationHintsIfCursorMoved);
    streamingResponseListener.dispose();
    socketIOErrorListener.dispose();
    socketConnectionListener.dispose();
    _socketIOClient.disconnect();
    sourceLangTextController.dispose();
    targetLangTextController.dispose();
    await stopWatchTimer.dispose();
    disposePlayer();
    super.onClose();
  }

  void getSourceTargetLangFromDB() {
    String? selectedSourceLanguage =
        _hiveDBInstance.get(preferredSourceLanguage);

    if (selectedSourceLanguage == null || selectedSourceLanguage.isEmpty) {
      selectedSourceLanguage = _hiveDBInstance.get(preferredAppLocale);
    }

    if (_languageModelController.sourceTargetLanguageMap.keys
            .toList()
            .contains(selectedSourceLanguage) &&
        !voiceSkipSourceLang.contains(selectedSourceLanguage)) {
      selectedSourceLanguageCode.value = selectedSourceLanguage ?? '';
      if (isTransliterationEnabled()) {
        setModelForTransliteration();
      }
    }

    String? selectedTargetLanguage =
        _hiveDBInstance.get(preferredTargetLanguage);
    if (selectedTargetLanguage != null &&
        selectedTargetLanguage.isNotEmpty &&
        selectedSourceLanguageCode.value.isNotEmpty &&
        _languageModelController
            .sourceTargetLanguageMap[selectedSourceLanguageCode.value]!
            .toList()
            .contains(selectedTargetLanguage) &&
        !voiceSkipTargetLang.contains(selectedTargetLanguage)) {
      selectedTargetLanguageCode.value = selectedTargetLanguage;
    }
  }

  void swapSourceAndTargetLanguage() {
    bool isTargetLangSkippedInSource =
        voiceSkipTargetLang.contains(selectedSourceLanguageCode.value);

    bool isSourceLangSkippedInTarget =
        voiceSkipSourceLang.contains(selectedTargetLanguageCode.value);

    if (isSourceAndTargetLangSelected()) {
      if (_languageModelController.sourceTargetLanguageMap.keys
              .contains(selectedTargetLanguageCode.value) &&
          _languageModelController
                  .sourceTargetLanguageMap[selectedTargetLanguageCode.value] !=
              null &&
          _languageModelController
              .sourceTargetLanguageMap[selectedTargetLanguageCode.value]!
              .contains(selectedSourceLanguageCode.value) &&
          !isTargetLangSkippedInSource &&
          !isSourceLangSkippedInTarget) {
        String tempSourceLanguage = selectedSourceLanguageCode.value;
        selectedSourceLanguageCode.value = selectedTargetLanguageCode.value;
        selectedTargetLanguageCode.value = tempSourceLanguage;
        _hiveDBInstance.put(
            preferredSourceLanguage, selectedSourceLanguageCode.value);
        _hiveDBInstance.put(
            preferredTargetLanguage, selectedTargetLanguageCode.value);
        setSourceLanguageList();
        setTargetLanguageList();
        resetAllValues();
      } else {
        showDefaultSnackbar(
            message:
                '${APIConstants.getLanNameInAppLang(selectedTargetLanguageCode.value)} - ${APIConstants.getLanNameInAppLang(selectedSourceLanguageCode.value)} ${translationNotPossible.tr}');
      }
    } else {
      showDefaultSnackbar(message: kErrorSelectSourceAndTargetScreen.tr);
    }
  }

  bool isSourceAndTargetLangSelected() =>
      selectedSourceLanguageCode.value.isNotEmpty &&
      selectedTargetLanguageCode.value.isNotEmpty;

  void startVoiceRecording() async {
    await PermissionHandler.requestPermissions().then((isPermissionGranted) {
      isMicPermissionGranted = isPermissionGranted;
    });
    if (isMicPermissionGranted) {
      // clear previous recording files and
      // update state
      resetAllValues();

      //if user quickly released tap than Socket continue emit the data
      //So need to check before starting mic streaming
      if (micButtonStatus.value == MicButtonStatus.pressed) {
        await vibrateDevice();

        recordingStartTime = DateTime.now();
        if (_hiveDBInstance.get(isStreamingPreferred)) {
          connectToSocket();

          _socketIOClient.socketEmit(
            emittingStatus: 'start',
            emittingData: [
              APIConstants.createSocketIOComputePayload(
                  srcLanguage: selectedSourceLanguageCode.value,
                  targetLanguage: selectedTargetLanguageCode.value,
                  preferredGender:
                      _hiveDBInstance.get(preferredVoiceAssistantGender)),
              {'responseFrequencyInSecs': 1}
            ],
            isDataToSend: true,
          );

          _recorder.start();
          micStreamSubscription = _recorder.audioStream.listen((value) {
            _socketIOClient.socketEmit(
                emittingStatus: 'data',
                emittingData: [
                  {
                    "audio": [
                      {"audioContent": value.sublist(0)}
                    ]
                  },
                  {"responseTaskSequenceDepth": 2},
                  false,
                  false
                ],
                isDataToSend: true);
            recordedData.addAll(value.sublist(0));
          });
        } else {
          stopWatchTimer.onStartTimer();
          await _voiceRecorder.startRecordingVoice(samplingRate);
        }
      }
    } else {
      showDefaultSnackbar(message: errorMicPermission.tr);
    }
  }

  void stopVoiceRecordingAndGetResult() async {
    await vibrateDevice();

    int timeTakenForLastRecording = stopWatchTimer.rawTime.value;
    stopWatchTimer.onResetTimer();

    if (timeTakenForLastRecording < tapAndHoldMinDuration &&
        isMicPermissionGranted) {
      showDefaultSnackbar(message: tapAndHoldForRecording.tr);
      if (!_hiveDBInstance.get(isStreamingPreferred)) {
        return;
      }
    }

    recordingStartTime = null;

    if (_hiveDBInstance.get(isStreamingPreferred)) {
      micStreamSubscription?.cancel();
      if (_socketIOClient.isMicConnected.value) {
        _socketIOClient.socketEmit(
            emittingStatus: 'data',
            emittingData: [
              null,
              {"responseTaskSequenceDepth": 2},
              true,
              true
            ],
            isDataToSend: true);
        micButtonStatus.value = MicButtonStatus.loading;
      }
    } else {
      if (await _voiceRecorder.isVoiceRecording()) {
        String? base64EncodedAudioContent =
            await _voiceRecorder.stopRecordingVoiceAndGetOutput();
        sourceLangASRPath = _voiceRecorder.getAudioFilePath()!;
        if (base64EncodedAudioContent == null ||
            base64EncodedAudioContent.isEmpty) {
          showDefaultSnackbar(message: errorInRecording.tr);
          return;
        } else {
          await getComputeResponseASRTrans(
              isRecorded: true, base64Value: base64EncodedAudioContent);
          isRecordedViaMic.value = true;
        }
      }
    }
  }

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

    var response = await _translationAppAPIClient.sendTransliterationRequest(
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

  Future<void> getComputeResponseASRTrans({
    required bool isRecorded,
    String? base64Value,
    bool clearSourceTTS = true,
  }) async {
    isLoading.value = true;
    String asrServiceId = '';
    String translationServiceId = '';

    asrServiceId = APIConstants.getTaskTypeServiceID(
            _languageModelController.taskSequenceResponse,
            'asr',
            selectedSourceLanguageCode.value) ??
        '';
    translationServiceId = APIConstants.getTaskTypeServiceID(
            _languageModelController.taskSequenceResponse,
            'translation',
            selectedSourceLanguageCode.value,
            selectedTargetLanguageCode.value) ??
        '';

    var asrPayloadToSend = APIConstants.createComputePayloadASRTrans(
        srcLanguage: selectedSourceLanguageCode.value,
        targetLanguage: selectedTargetLanguageCode.value,
        isRecorded: isRecorded,
        inputData: isRecorded ? base64Value! : sourceLangTextController.text,
        audioFormat: Platform.isIOS ? 'flac' : 'wav',
        asrServiceID: asrServiceId,
        translationServiceID: translationServiceId,
        preferredGender: _hiveDBInstance.get(preferredVoiceAssistantGender),
        samplingRate: samplingRate);

    lastComputeRequest = asrPayloadToSend;

    var response = await _dhruvaapiClient.sendComputeRequest(
        baseUrl: _languageModelController
            .taskSequenceResponse.pipelineInferenceAPIEndPoint?.callbackUrl,
        authorizationKey: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.name,
        authorizationValue: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.value,
        computePayload: asrPayloadToSend);
    json.encode(asrPayloadToSend);
    response.when(
      success: (taskResponse) async {
        lastComputeResponse = taskResponse.toJson();
        if (isRecorded) {
          sourceLangTextController.text = taskResponse.pipelineResponse
                  ?.firstWhere((element) => element.taskType == 'asr')
                  .output
                  ?.first
                  .source
                  ?.trim() ??
              '';
        }
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
        if (clearSourceTTS) sourceLangTTSPath.value = '';
        targetLangTTSPath.value = '';
        sourceSpeakerStatus.value = SpeakerStatus.stopped;
        targetSpeakerStatus.value = SpeakerStatus.stopped;
      },
      failure: (error) {
        isLoading.value = false;
        showDefaultSnackbar(message: somethingWentWrong.tr);
      },
    );
  }

  Future<void> getComputeResTTS({
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
      preferredGender: _hiveDBInstance.get(preferredVoiceAssistantGender),
      samplingRate: samplingRate,
    );

    lastComputeRequest['pipelineTasks']
        .addAll(asrPayloadToSend['pipelineTasks']);

    var response = await _dhruvaapiClient.sendComputeRequest(
        baseUrl: _languageModelController
            .taskSequenceResponse.pipelineInferenceAPIEndPoint?.callbackUrl,
        authorizationKey: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.name,
        authorizationValue: _languageModelController.taskSequenceResponse
            .pipelineInferenceAPIEndPoint?.inferenceApiKey?.value,
        computePayload: asrPayloadToSend);

    await response.when(
      success: (taskResponse) async {
        lastComputeResponse['pipelineResponse']
            .addAll(taskResponse.toJson()['pipelineResponse']);
        dynamic ttsResponse = taskResponse.pipelineResponse
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
        showDefaultSnackbar(message: somethingWentWrong.tr);
        return;
      },
    );
  }

  bool isTransliterationEnabled() {
    return _hiveDBInstance.get(enableTransliteration, defaultValue: true);
  }

  void setModelForTransliteration() {
    transliterationModelToUse =
        _languageModelController.getAvailableTransliterationModelsForLanguage(
            selectedSourceLanguageCode.value);
  }

  void clearTransliterationHints() {
    transliterationWordHints.clear();
    currentlyTypedWordForTransliteration = '';
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

  void clearTransliterationHintsIfCursorMoved() {
    int difference =
        lastOffsetOfCursor - sourceLangTextController.selection.base.offset;
    if (difference > 0 || difference < -1) {
      clearTransliterationHints();
    }
    lastOffsetOfCursor = sourceLangTextController.selection.base.offset;
  }

  void shareAudioFile({required bool isSourceLang}) async {
    if (isTranslateCompleted.value) {
      String? audioPathToShare = isSourceLang
          ? isRecordedViaMic.value
              ? sourceLangASRPath
              : sourceLangTTSPath.value
          : targetLangTTSPath.value;

      if (audioPathToShare == null || audioPathToShare.isEmpty) {
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
            0, 0, ScreenUtil().screenWidth, ScreenUtil().screenHeight / 2),
      );
    } else {
      showDefaultSnackbar(message: noAudioFoundToShare.tr);
    }
  }

  void connectToSocket() {
    if (_socketIOClient.isConnected()) {
      _socketIOClient.disconnect();
    }
    _socketIOClient.socketConnect();
  }

  Future<void> displaySocketIOResponse(response) async {
    if (response != null) {
      //  used for get ASR
      sourceLangTextController.text =
          response[0]['pipelineResponse']?[0]['output']?[0]['source'] ?? '';

      // used for get Translation
      if ((response[0]['pipelineResponse'].length ?? 0) > 1) {
        String targetText =
            response[0]['pipelineResponse'][1]['output']?[0]['target'] ?? '';
        targetLangTextController.text = targetText;
        targetOutputText.value = targetText;

        //  used for get TTS
        if ((response[0]['pipelineResponse'].length ?? 0) > 2) {
          String ttsResponse =
              response[0]['pipelineResponse'][2]['audio'][0]['audioContent'];
          isTranslateCompleted.value = true;
          isLoading.value = false;
          Future.delayed(const Duration(seconds: 3))
              .then((value) => expandFeedbackIcon.value = false);
          sourceLangTTSPath.value = '';
          targetLangTTSPath.value = '';
          sourceSpeakerStatus.value = SpeakerStatus.stopped;
          targetSpeakerStatus.value = SpeakerStatus.stopped;
          if (ttsResponse.isNotEmpty) {
            targetLangTTSPath.value = '';
            String ttsFilePath = await createTTSAudioFIle(ttsResponse);
            targetLangTTSPath.value = ttsFilePath;
          }
          // disconnect socket io after final response received
          micButtonStatus.value = MicButtonStatus.released;
          _socketIOClient.disconnect();
        }
      }
    }
  }

  void updateSamplingRate(ConnectivityResult newConnectivity) {
    if (newConnectivity == ConnectivityResult.mobile) {
      samplingRate = 8000;
    } else {
      samplingRate = 16000;
    }
  }

  Future<void> vibrateDevice() async {
    await Vibration.cancel();
    if (await Vibration.hasVibrator() ?? false) {
      if (await Vibration.hasCustomVibrationsSupport() ?? false) {
        await Vibration.vibrate(duration: 130);
      } else {
        await Vibration.vibrate();
      }
    }
  }

  void playStopTTSOutput(bool isPlayingSource) async {
    if (playerController.playerState.isPlaying) {
      await stopPlayer();
      return;
    }

    String? audioPath = '';

    if (isPlayingSource && isRecordedViaMic.value) {
      audioPath = sourceLangASRPath;
    } else {
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
    }

    if (audioPath != null && audioPath.isNotEmpty) {
      isPlayingSource
          ? sourceSpeakerStatus.value = SpeakerStatus.playing
          : targetSpeakerStatus.value = SpeakerStatus.playing;

      await preparePlayerAndWaveforms(audioPath,
          isRecordedAudio: isPlayingSource && isRecordedViaMic.value,
          isTargetLanguage: !isPlayingSource);
    }
  }

  setSourceLanguageList() {
    sourceLangListRegular.clear();
    sourceLangListBeta.clear();

    sourceLangListRegular =
        _languageModelController.sourceTargetLanguageMap.keys.toList();

    for (int i = 0; i < sourceLangListRegular.length; i++) {
      var language = sourceLangListRegular[i];
      if (voiceSkipSourceLang.contains(language)) {
        sourceLangListRegular.removeAt(i);
        i--;
      } else if (voiceBetaSourceLang.contains(language)) {
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
        .sourceTargetLanguageMap[selectedSourceLanguageCode.value]!
        .toList();

    for (int i = 0; i < targetLangListRegular.length; i++) {
      var language = targetLangListRegular[i];
      if (voiceSkipTargetLang.contains(language)) {
        targetLangListRegular.removeAt(i);
        i--;
      } else if (voiceBetaTargetLang.contains(language)) {
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
    isRecordedViaMic.value = false;
    sourceTextCharLimit.value = 0;
    maxDuration.value = 0;
    currentDuration.value = 0;
    sourceLangASRPath = '';
    await stopPlayer();
    sourceSpeakerStatus.value = SpeakerStatus.disabled;
    targetSpeakerStatus.value = SpeakerStatus.disabled;
    targetOutputText.value = '';
    sourceLangASRPath = '';
    sourceLangTTSPath.value = '';
    targetLangTTSPath.value = '';
    recordedData = [];
    isSourceShareLoading.value = false;
    isTargetShareLoading.value = false;
    lastComputeRequest.clear();
    lastComputeResponse.clear();
    _socketIOClient.disconnect();
    if (isTransliterationEnabled()) {
      setModelForTransliteration();
      clearTransliterationHints();
    }
  }

  disposePlayer() async {
    await stopPlayer();
    playerController.dispose();
  }
}
