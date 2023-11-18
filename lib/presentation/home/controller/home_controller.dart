import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../common/controller/language_model_controller.dart';
import '../../../localization/localization_keys.dart';
import '../../../models/task_sequence_response_model.dart';
import '../../../services/dhruva_api_client.dart';
import '../../../services/transliteration_app_api_client.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/network_utils.dart';
import '../../../utils/snackbar_utils.dart';

class HomeController extends GetxController {
  RxBool isMainConfigCallLoading = false.obs,
      isTransConfigCallLoading = false.obs;

  late DHRUVAAPIClient _dhruvaapiClient;
  late TransliterationAppAPIClient _translationAppAPIClient;
  late LanguageModelController _languageModelController;
  StreamSubscription<ConnectivityResult>? subscription;
  late final Box _hiveDBInstance;

  @override
  void onInit() {
    _dhruvaapiClient = Get.find();
    _translationAppAPIClient = Get.find();
    _languageModelController = Get.find();
    _hiveDBInstance = Hive.box(hiveDBName);

    // Get main config call response from cache

    DateTime? configCacheTime = _hiveDBInstance.get(configCacheLastUpdatedKey);
    dynamic taskSequenceResponse = _hiveDBInstance.get(configCacheKey);

    if (configCacheTime != null &&
        taskSequenceResponse != null &&
        configCacheTime.isAfter(DateTime.now())) {
      // load data from cache
      _languageModelController.setTaskSequenceResponse(
          TaskSequenceResponse.fromJson(taskSequenceResponse));
      _languageModelController.populateLanguagePairs();
    } else {
      // clear cache and get new data
      _hiveDBInstance.put(configCacheLastUpdatedKey, null);
      _hiveDBInstance.put(configCacheKey, null);
      isNetworkConnected().then((isConnected) {
        if (isConnected) {
          getAvailableLanguagesInTask();
        } else {
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
        }
      });
      if (subscription == null) listenNetworkChange();
    }

    // Get translation config call response from cache

    DateTime? transConfigCacheTime =
        _hiveDBInstance.get(transConfigCacheLastUpdatedKey);
    dynamic transTaskSequenceResponse =
        _hiveDBInstance.get(transConfigCacheKey);

    if (transConfigCacheTime != null &&
        transTaskSequenceResponse != null &&
        transConfigCacheTime.isAfter(DateTime.now())) {
      // load data from cache
      _languageModelController.setTranslationConfigResponse(
          TaskSequenceResponse.fromJson(transTaskSequenceResponse));
      _languageModelController.populateTranslationLanguagePairs();
    } else {
      // clear cache and get new data
      _hiveDBInstance.put(transConfigCacheLastUpdatedKey, null);
      _hiveDBInstance.put(transConfigCacheKey, null);
      isNetworkConnected().then((isConnected) {
        if (isConnected) {
          getAvailableLangTranslation();
        } else {
          showDefaultSnackbar(message: errorNoInternetTitle.tr);
        }
      });
      if (subscription == null) listenNetworkChange();
    }

    isNetworkConnected().then((isConnected) {
      if (isConnected) {
        getTransliterationModels();
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    subscription?.cancel();
    super.onClose();
  }

  Future<void> getAvailableLanguagesInTask() async {
    isMainConfigCallLoading.value = true;
    var languageRequestResponse = await _dhruvaapiClient.getTaskSequence(
        requestPayload: APIConstants.payloadForLanguageConfig);
    languageRequestResponse.when(
      success: ((TaskSequenceResponse taskSequenceResponse) async {
        _languageModelController.setTaskSequenceResponse(taskSequenceResponse);
        await addMainConfigResponseInCache(taskSequenceResponse.toJson());
        _languageModelController.populateLanguagePairs();
        isMainConfigCallLoading.value = false;
      }),
      failure: (error) {
        isMainConfigCallLoading.value = false;
        showDefaultSnackbar(message: somethingWentWrong.tr);
      },
    );
  }

  Future<void> getAvailableLangTranslation() async {
    isTransConfigCallLoading.value = true;
    Map<String, dynamic> transPayload =
        json.decode(json.encode(APIConstants.payloadForLanguageConfig));

    (transPayload['pipelineTasks'])
        .removeWhere((element) => element['taskType'] != 'translation');
    var languageRequestResponse =
        await _dhruvaapiClient.getTaskSequence(requestPayload: transPayload);
    languageRequestResponse.when(
      success: ((TaskSequenceResponse taskSequenceResponse) async {
        _languageModelController
            .setTranslationConfigResponse(taskSequenceResponse);
        await addTransConfigResponseInCache(taskSequenceResponse.toJson());
        _languageModelController.populateTranslationLanguagePairs();
        isTransConfigCallLoading.value = false;
      }),
      failure: (error) {
        isTransConfigCallLoading.value = false;
        showDefaultSnackbar(message: somethingWentWrong.tr);
      },
    );
  }

  Future<void> getTransliterationModels() async {
    Map<String, dynamic> taskPayloads = {
      "task": APIConstants.TYPES_OF_MODELS_LIST[3],
      "sourceLanguage": "",
      "targetLanguage": "",
      "domain": "All",
      "submitter": "All",
      "userId": null
    };

    var transliterationResponse = await _translationAppAPIClient
        .getTransliterationModels(taskPayloads: taskPayloads);
    transliterationResponse.when(
      success: ((data) {
        _languageModelController.calcAvailableTransliterationModels(
            transliterationModel: data);
      }),
      failure: (error) {
        showDefaultSnackbar(message: somethingWentWrong.tr);
      },
    );
  }

  void listenNetworkChange() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none &&
          result != ConnectivityResult.vpn) {
        if (_languageModelController.sourceTargetLanguageMap.isEmpty &&
            !isMainConfigCallLoading.value) {
          getAvailableLanguagesInTask();
        }
      }
    });
  }

  Future<void> addMainConfigResponseInCache(responseData) async {
    await _hiveDBInstance.put(configCacheKey, responseData);
    await _hiveDBInstance.put(
      configCacheLastUpdatedKey,
      DateTime.now().add(
        const Duration(days: 1),
      ),
    );
  }

  Future<void> addTransConfigResponseInCache(responseData) async {
    await _hiveDBInstance.put(transConfigCacheKey, responseData);
    await _hiveDBInstance.put(
      transConfigCacheLastUpdatedKey,
      DateTime.now().add(
        const Duration(days: 1),
      ),
    );
  }
}
