// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../localization/localization_keys.dart';
import '../../../models/feedback_type_model.dart';
import '../../../services/dhruva_api_client.dart';
import '../../../services/transliteration_app_api_client.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../common/controller/language_model_controller.dart';
import '../../../utils/network_utils.dart';
import '../../../utils/snackbar_utils.dart';

class FeedbackController extends GetxController {
  RxDouble mainRating = 0.0.obs;
  RxList<Rx<FeedbackTypeModel>> feedbackTypeModels = RxList([]);
  RxBool isLoading = false.obs;
  String transliterationModelToUse = '', oldSourceText = '';
  dynamic feedbackReqResponse;

  late TransliterationAppAPIClient _translationAppAPIClient;
  late DHRUVAAPIClient _dhruvaapiClient;
  late LanguageModelController _languageModelController;
  final transliterationHints = RxList([]);
  Box? _hiveDBInstance;
  Map<String, dynamic>? computePayload = {},
      computeResponse = {},
      suggestedOutput = {};

  @override
  void onInit() {
    (Get.arguments['requestPayload'] as Map<String, dynamic>)
        .forEach((key, value) {
      computePayload?[key] = value;
    });

    // Fixes Dart shallow copy issue:

    Map<String, dynamic> responseCopyForSuggestedRes =
        json.decode(json.encode(Get.arguments['requestResponse']));

    (responseCopyForSuggestedRes).forEach((key, value) {
      suggestedOutput?[key] = [];
      for (Map<String, dynamic> task in value) {
        if (task['taskType'] != 'tts') {
          suggestedOutput?[key].add(task);
        }
      }
    });

    Map<String, dynamic> responseCopyForComputeRes =
        json.decode(json.encode(Get.arguments['requestResponse']));

    (responseCopyForComputeRes).forEach((key, value) {
      computeResponse?[key] = value;
    });

    _translationAppAPIClient = Get.find();
    _languageModelController = Get.find();
    _dhruvaapiClient = DHRUVAAPIClient.getAPIClientInstance();
    if (_hiveDBInstance == null || !_hiveDBInstance!.isOpen) {
      _hiveDBInstance = Hive.box(hiveDBName);
    }

    super.onInit();
    DateTime? feedbackCacheTime =
        _hiveDBInstance?.get(feedbackCacheLastUpdatedKey);
    dynamic feedbackResponseFromCache = _hiveDBInstance?.get(feedbackCacheKey);

    if (feedbackCacheTime != null &&
        feedbackResponseFromCache != null &&
        feedbackCacheTime.isAfter(DateTime.now())) {
      // load data from cache
      feedbackReqResponse = feedbackResponseFromCache;
      getFeedbackQuestions();
    } else {
      isLoading.value = true;
      // clear cache and get new data
      _hiveDBInstance?.put(configCacheLastUpdatedKey, null);
      _hiveDBInstance?.put(feedbackCacheKey, null);
      isNetworkConnected().then((isConnected) {
        if (isConnected) {
          getFeedbackPipelines();
        } else {
          isLoading.value = false;
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
        }
      });
    }
  }

  @override
  void onClose() {
    feedbackTypeModels.clear();
    computePayload?.clear();
    computeResponse?.clear();
    suggestedOutput?.clear();
    transliterationHints.clear();
    super.onClose();
  }

  bool isTransliterationEnabled() {
    return _hiveDBInstance?.get(enableTransliteration, defaultValue: true);
  }

  Future<List<String>> getTransliterationOutput(
      String sourceText, String languageCode) async {
    if (languageCode == defaultLangCode) {
      return [];
    }
    transliterationModelToUse = _languageModelController
            .getAvailableTransliterationModelsForLanguage(languageCode) ??
        '';
    if (transliterationModelToUse.isEmpty) {
      return [];
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
        transliterationHints.value = [];
        transliterationHints.assignAll(data['output'][0]['target']);
        return transliterationHints;
      },
      failure: (_) {
        return [];
      },
    );
    return [];
  }

  Future<void> getFeedbackPipelines() async {
    Map<String, dynamic> requestConfig = {
      "feedbackLanguage": "en",
      "supportedTasks": ["asr", "translation", "tts"]
    };
    var languageRequestResponse = await _dhruvaapiClient.sendFeedbackRequest(
        requestPayload: requestConfig);
    languageRequestResponse.when(
      success: ((dynamic response) async {
        await addFeedbackResponseInCache(response);
        feedbackReqResponse = response;
        getFeedbackQuestions();
        isLoading.value = false;
      }),
      failure: (error) {
        showDefaultSnackbar(message: somethingWentWrong.tr);
        isLoading.value = false;
      },
    );
  }

  Future<void> submitFeedbackPayload() async {
    var feedbackSubmitResponse = await _dhruvaapiClient.submitFeedback(
      url: _languageModelController.taskSequenceResponse.feedbackUrl,
      authorizationKey: _languageModelController.taskSequenceResponse
          .pipelineInferenceAPIEndPoint?.inferenceApiKey?.name,
      authorizationValue: _languageModelController.taskSequenceResponse
          .pipelineInferenceAPIEndPoint?.inferenceApiKey?.value,
      requestPayload: createFeedbackSubmitPayload(),
    );
    feedbackSubmitResponse.when(
      success: ((dynamic response) async {
        showDefaultSnackbar(message: response['message']);
      }),
      failure: (error) {
        showDefaultSnackbar(message: somethingWentWrong.tr);
        isLoading.value = false;
      },
    );
  }

  void getFeedbackQuestions() {
    if (feedbackReqResponse['taskFeedback'] != null &&
        feedbackReqResponse['taskFeedback'] is List) {
      for (var taskFeedback in feedbackReqResponse['taskFeedback']) {
        List<GranularFeedback> granularFeedbacks = [];
        if (taskFeedback['granularFeedback'] != null &&
            taskFeedback['granularFeedback'].isNotEmpty) {
          for (var granularFeedback in taskFeedback['granularFeedback']) {
            granularFeedbacks.add(GranularFeedback(
              question: granularFeedback['question'],
              mainRating: null,
              supportedFeedbackTypes:
                  granularFeedback['supportedFeedbackTypes'],
              parameters: granularFeedback['parameters'] != null
                  ? granularFeedback['parameters']
                      .map((parameter) =>
                          Parameter(paramName: parameter, paramRating: null))
                      .toList()
                  : [],
            ));
          }
        }

        Map<String, dynamic>? task = (suggestedOutput?['pipelineResponse']
                as List<dynamic>)
            .firstWhereOrNull((e) => e['taskType'] == taskFeedback['taskType']);
        String pipelineTaskValue = '';
        String? suggestedOutputTitle;
        switch (task?['taskType']) {
          case 'asr':
            pipelineTaskValue = task?['output'][0]['source'];
            suggestedOutputTitle = suggestedOutputTextASR.tr;
            break;
          case 'translation':
            pipelineTaskValue = task?['output'][0]['target'];
            suggestedOutputTitle = suggestedOutputTextTranslate.tr;
            break;
        }
        TextEditingController feedbackTextController =
            TextEditingController(text: pipelineTaskValue);
        FocusNode feedbackFocusNode = FocusNode();
        feedbackFocusNode.addListener(() {
          oldSourceText = feedbackTextController.text;
        });
        feedbackTypeModels.add(FeedbackTypeModel(
                taskType: taskFeedback['taskType'],
                question: taskFeedback['commonFeedback'].length > 0
                    ? taskFeedback['commonFeedback'][0]['question']
                    : '',
                suggestedOutputTitle: suggestedOutputTitle,
                textController: feedbackTextController,
                focusNode: feedbackFocusNode,
                taskRating: Rxn<double>(),
                isExpanded: false.obs,
                granularFeedbacks: granularFeedbacks)
            .obs);
      }
    }
  }

  Future<void> addFeedbackResponseInCache(responseData) async {
    await _hiveDBInstance?.put(feedbackCacheKey, responseData);
    await _hiveDBInstance?.put(
      feedbackCacheLastUpdatedKey,
      DateTime.now().add(
        const Duration(days: 1),
      ),
    );
  }

  Map<String, dynamic> createFeedbackSubmitPayload() {
    Map<String, dynamic> submissionPayload = {};
    submissionPayload['feedbackTimeStamp'] =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    submissionPayload['feedbackLanguage'] =
        Get.locale?.languageCode ?? defaultLangCode;
    submissionPayload['pipelineInput'] = computePayload;
    submissionPayload['pipelineOutput'] = computeResponse;

    // Suggested Output

    bool isUserSuggestedOutput = false;

    for (Map<String, dynamic> task in suggestedOutput?['pipelineResponse']) {
      if (task['taskType'] == "asr") {
        String? outputTextSource = (computeResponse?['pipelineResponse']
                    as List<dynamic>)
                .firstWhere((e) => e['taskType'] == task['taskType'])['output']
            [0]['source'];
        String? userSuggestedOutputText = task['output'][0]['source'];
        isUserSuggestedOutput = outputTextSource != userSuggestedOutputText;

        // update in translation as well
        if (isUserSuggestedOutput) {
          (suggestedOutput?['pipelineResponse'] as List<dynamic>).firstWhere(
                  (task) => task['taskType'] == 'translation')['output'][0]
              ['source'] = userSuggestedOutputText;
        }
      }
      if (!isUserSuggestedOutput && task['taskType'] == "translation") {
        String outputTextSource = (computeResponse?['pipelineResponse']
                    as List<dynamic>)
                .firstWhere((e) => e['taskType'] == task['taskType'])['output']
            [0]['target'];
        String userSuggestedOutputText = task['output'][0]['target'];
        isUserSuggestedOutput = outputTextSource != userSuggestedOutputText;
      }
    }
    if (isUserSuggestedOutput) {
      submissionPayload['suggestedPipelineOutput'] = suggestedOutput;
    }

    // Pipeline Feedback

    submissionPayload['pipelineFeedback'] = {
      'commonFeedback': [
        {
          'question': feedbackReqResponse['pipelineFeedback']['commonFeedback']
              [0]['question'],
          "feedbackType": "rating",
          "rating": mainRating.value
        }
      ]
    };

    // Task Feedback

    List<Map<String, dynamic>> taskFeedback = [];

    for (var task in feedbackTypeModels.value) {
      if (task.value.taskRating.value != null) {
        // Granular Feedback

        List<Map<String, dynamic>> granularFeedback = [];
        if (task.value.taskRating.value! < 4) {
          for (var feedback in task.value.granularFeedbacks) {
            bool isRating = feedback.supportedFeedbackTypes.contains("rating");

            // Granular Feedback Rating questions

            Map<String, dynamic> question = {
              "question": feedback.question,
              "feedbackType": isRating ? "rating" : "rating-list",
            };

            if (isRating && feedback.mainRating != null) {
              question["rating"] = feedback.mainRating;
            } else {
              // Granular Feedback questions parameter

              List<Map<String, dynamic>> parameters = [];

              for (var parameter in feedback.parameters) {
                if (parameter.paramRating != null) {
                  Map<String, dynamic> singleParameter = {
                    "parameterName": parameter.paramName,
                    "rating": parameter.paramRating,
                  };
                  parameters.add(singleParameter);
                }
              }

              if (parameters.isNotEmpty) {
                question["rating-list"] = parameters;
              }
            }
            if (question["rating"] != null || question["rating-list"] != null) {
              granularFeedback.add(question);
            }
          }
        }

        taskFeedback.add({
          "taskType": task.value.taskType,
          "commonFeedback": [
            {
              "question": task.value.question,
              "feedbackType": "rating",
              "rating": task.value.taskRating.value,
            }
          ],
          if (granularFeedback.isNotEmpty) "granularFeedback": granularFeedback,
        });
      }
    }

    if (taskFeedback.isNotEmpty) {
      submissionPayload['taskFeedback'] = taskFeedback;
    }
    return submissionPayload;
  }
}
