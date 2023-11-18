import 'dart:collection';
import 'dart:math';
import 'package:get/get.dart';

import '../../models/search_model.dart';
import '../../models/task_sequence_response_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/constants/app_constants.dart';

class LanguageModelController extends GetxController {
  final SplayTreeMap<String, SplayTreeSet<String>> sourceTargetLanguageMap =
      SplayTreeMap<String, SplayTreeSet<String>>();

  final SplayTreeMap<String, SplayTreeSet<String>> translationLanguageMap =
      SplayTreeMap<String, SplayTreeSet<String>>();

  late final TaskSequenceResponse _taskSequenceResponse;
  late final TaskSequenceResponse _translationConfigResponse;

  TaskSequenceResponse get taskSequenceResponse => _taskSequenceResponse;
  void setTaskSequenceResponse(TaskSequenceResponse taskSequenceResponse) =>
      _taskSequenceResponse = taskSequenceResponse;

  TaskSequenceResponse get translationConfigResponse =>
      _translationConfigResponse;
  void setTranslationConfigResponse(TaskSequenceResponse translationResponse) =>
      _translationConfigResponse = translationResponse;

  void populateLanguagePairs() {
    taskSequenceResponse.languages?.forEach((languagePair) {
      if (languagePair.sourceLanguage != null &&
          languagePair.targetLanguageList != null &&
          languagePair.targetLanguageList!.isNotEmpty) {
        sourceTargetLanguageMap[languagePair.sourceLanguage!] =
            SplayTreeSet.from(languagePair.targetLanguageList!);
      }
    });
  }

  void populateTranslationLanguagePairs() {
    translationConfigResponse.languages?.forEach((languagePair) {
      if (languagePair.sourceLanguage != null &&
          languagePair.targetLanguageList != null &&
          languagePair.targetLanguageList!.isNotEmpty) {
        translationLanguageMap[languagePair.sourceLanguage!] =
            SplayTreeSet.from(languagePair.targetLanguageList!);
      }
    });
  }

  SearchModel? _availableTransliterationModels;
  SearchModel? get availableTransliterationModels =>
      _availableTransliterationModels;

  void calcAvailableTransliterationModels(
      {required SearchModel transliterationModel}) {
    _availableTransliterationModels = transliterationModel;

    Set<String> availableTransliterationModelLanguagesSet = {};
    if (_availableTransliterationModels != null) {
      for (SearchModelData eachTransliterationModel
          in _availableTransliterationModels!.data) {
        availableTransliterationModelLanguagesSet.add(
            eachTransliterationModel.languages[0].sourceLanguage.toString());
      }
    }
  }

  String? getAvailableTransliterationModelsForLanguage(String languageCode) {
    List<String> availableTransliterationModelsForSelectedLangInUIDefault = [];
    List<String> availableTransliterationModelsForSelectedLangInUI = [];
    bool isAtLeastOneDefaultModelTypeFound = false;

    List<String> availableSubmittersList = [];
    if (_availableTransliterationModels != null) {
      for (var eachAvailableTransliterationModelData
          in availableTransliterationModels!.data) {
        //using English as source language for now
        if (eachAvailableTransliterationModelData.languages[0].sourceLanguage ==
                defaultLangCode &&
            eachAvailableTransliterationModelData.languages[0].targetLanguage ==
                languageCode) {
          if (!availableSubmittersList.contains(
              eachAvailableTransliterationModelData.name.toLowerCase())) {
            availableSubmittersList
                .add(eachAvailableTransliterationModelData.name.toLowerCase());
          }
        }
      }
    }
    availableSubmittersList = availableSubmittersList.toSet().toList();

    //Check any AI4Bharat model availability
    String ai4BharatModelName = '';
    for (var eachSubmitter in availableSubmittersList) {
      if (eachSubmitter.toLowerCase().contains(APIConstants
          .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[3]]!
          .split(',')[1]
          .toLowerCase())) {
        ai4BharatModelName = eachSubmitter;
      }
    }
    if (_availableTransliterationModels != null) {
      if (ai4BharatModelName.isNotEmpty) {
        for (var eachAvailableTransliterationModelData
            in availableTransliterationModels!.data) {
          if (eachAvailableTransliterationModelData.name.toLowerCase() ==
              ai4BharatModelName.toLowerCase()) {
            availableTransliterationModelsForSelectedLangInUIDefault
                .add(eachAvailableTransliterationModelData.modelId);
            isAtLeastOneDefaultModelTypeFound = true;
          }
        }
      } else {
        for (var eachAvailableTransliterationModelData
            in availableTransliterationModels!.data) {
          if (eachAvailableTransliterationModelData
                      .languages[0].sourceLanguage ==
                  defaultLangCode &&
              eachAvailableTransliterationModelData
                      .languages[0].targetLanguage ==
                  languageCode) {
            availableTransliterationModelsForSelectedLangInUI
                .add(eachAvailableTransliterationModelData.modelId);
          }
        }
      }
    }

    //Either select default model (vakyansh for now) or any random model from the available list.
    String? transliterationModelIDToUse = isAtLeastOneDefaultModelTypeFound
        ? availableTransliterationModelsForSelectedLangInUIDefault[Random()
            .nextInt(availableTransliterationModelsForSelectedLangInUIDefault
                .length)]
        : availableTransliterationModelsForSelectedLangInUI.isNotEmpty
            ? availableTransliterationModelsForSelectedLangInUI[Random()
                .nextInt(
                    availableTransliterationModelsForSelectedLangInUI.length)]
            : null;
    return transliterationModelIDToUse;
  }
}
