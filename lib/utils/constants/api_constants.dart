// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:get/get.dart';

import '../../enums/language_enum.dart';
import '../../models/task_sequence_response_model.dart';
import 'language_map_translated.dart';

class APIConstants {
  static const String ULCA_CONFIG_API_URL =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0';

  static const String TRANSLITERATION_BASE_URL =
      'https://meity-auth.ulcacontrib.org/ulca/apis';

  static const String FEEDBACK_BASE_URL_DEV =
      "https://dev-auth.ulcacontrib.org/ulca/mdms";

  static const String TASK_SEQUENCE_ENDPOINT = '/model/getModelsPipeline';
  static const String SEARCH_REQ_URL = '/v0/model/search';
  static const String TRANSLITERATION_REQ_URL = '/v0/model/compute';
  static const String ASR_REQ_URL = '/asr/v1/model/compute';
  static const String TRANS_REQ_URL = '/v0/model/compute';
  static const String TTS_REQ_URL = '/v0/model/compute';
  static const String FEEDBACK_REQ_URL = '/v0/pipelineQuestions';

  static const int kApiUnknownErrorCode = 0;
  static const int kApiCanceledCode = -1;
  static const int kApiConnectionTimeoutCode = -2;
  static const int kApiDefaultCode = -3;
  static const int kApiReceiveTimeoutCode = -4;
  static const int kApiSendTimeoutCode = -5;
  static const int kApiUnAuthorizedExceptionErrorCode = 401;
  static const int kApiDataConflictCode = 409;

  static const String kUserIdREST = 'userID';
  static const String kULCAAPIKeyREST = 'ulcaApiKey';
  static const String kAuthorizationKeyStreaming = 'authorization';
  static const String kApiUnknownError = 'UNKNOWN_ERROR';
  static const String kApiCanceled = 'API_CANCELED';
  static const String kApiConnectionTimeout = 'CONNECT_TIMEOUT';
  static const String kApiDefault = 'DEFAULT';
  static const String kApiReceiveTimeout = 'RECEIVE_TIMEOUT';
  static const String kApiSendTimeout = 'SEND_TIMEOUT';
  static const String kApiResponseError = 'RESPONSE_ERROR';
  static const String kApiDataConflict = 'DATA_CONFLICT';

  // Common masked error messages
  static const String kErrorMessageConnectionTimeout = 'Connection timed out';
  static const String kErrorMessageNetworkError = 'Network error';
  static const String kErrorMessageGenericError = 'Something went wrong';

  // HandshakeException
  static const String kApiAuthExceptionError = 'AUTH_EXCEPTION';
  static const String kErrorMessageUnAuthorizedException =
      'UnAuthorized. Please login again';

  // Payload for available Languages request

  static const String kTaskType = "taskType";
  static const String kASR = "asr";
  static const String kTranslation = "translation";
  static const String kTTS = "tts";

  static var payloadForLanguageConfig = {
    "pipelineTasks": [
      {kTaskType: kASR},
      {kTaskType: kTranslation},
      {kTaskType: kTTS}
    ],
    "pipelineRequestConfig": {"pipelineId": "64392f96daac500b55c543cd"}
  };

  // payload for Compute request
  static Map<String, dynamic> createComputePayloadASRTrans({
    required String srcLanguage,
    required String targetLanguage,
    required String preferredGender,
    required bool isRecorded,
    required String inputData,
    String audioFormat = 'wav',
    int samplingRate = 16000, // default
    String? asrServiceID,
    String? translationServiceID,
  }) {
    var computeRequestToSend = {
      "pipelineTasks": [
        if (isRecorded)
          {
            "taskType": "asr",
            "config": {
              "language": {"sourceLanguage": srcLanguage},
              "serviceId": asrServiceID ?? "",
              "audioFormat": audioFormat,
              "samplingRate": samplingRate,
            }
          },
        {
          "taskType": "translation",
          "config": {
            "language": {
              "sourceLanguage": srcLanguage,
              "targetLanguage": targetLanguage
            },
            "serviceId": translationServiceID ?? ""
          }
        },
      ],
      "inputData": {
        isRecorded ? 'audio' : 'input': [
          {
            isRecorded ? 'audioContent' : 'source': inputData,
          }
        ]
      }
    };

    return computeRequestToSend;
  }

  static Map<String, dynamic> createComputePayloadTTS({
    required String srcLanguage,
    required String preferredGender,
    required String inputData,
    required int samplingRate,
    String? ttsServiceID,
  }) {
    var computeRequestToSend = {
      "pipelineTasks": [
        {
          "taskType": "tts",
          "config": {
            "language": {"sourceLanguage": srcLanguage},
            "serviceId": ttsServiceID ?? "",
            "gender": preferredGender,
            "samplingRate": samplingRate
          }
        }
      ],
      "inputData": {
        'input': [
          {'source': inputData}
        ]
      }
    };

    return computeRequestToSend;
  }

  static List<Map<String, dynamic>> createSocketIOComputePayload({
    required String srcLanguage,
    required String targetLanguage,
    required String preferredGender,
  }) {
    return [
      {
        "taskType": "asr",
        "config": {
          "language": {"sourceLanguage": srcLanguage},
          "samplingRate": 16000,
        }
      },
      {
        "taskType": "translation",
        "config": {
          "language": {
            "sourceLanguage": srcLanguage,
            "targetLanguage": targetLanguage
          }
        }
      },
      {
        "taskType": "tts",
        "config": {
          "language": {"sourceLanguage": targetLanguage},
          "gender": preferredGender
        }
      }
    ];
  }

  static String? getTaskTypeServiceID(TaskSequenceResponse sequenceResponse,
      String taskType, String sourceLanguageCode,
      [String? targetLanguageCode]) {
    List<Config>? configs = sequenceResponse.pipelineResponseConfig
        ?.firstWhere((element) => element.taskType == taskType)
        .config;
    for (var config in configs!) {
      if (config.language?.sourceLanguage == sourceLanguageCode) {
        // sends translation service id
        if (targetLanguageCode != null) {
          if (config.language?.targetLanguage == targetLanguageCode) {
            return config.serviceId;
          }
        } else {
          return config.serviceId; // sends ASR, TTS service id
        }
      }
    }
    return '';
  }

// This shall be same as keys in DEFAULT_MODEL_ID, DEFAULT_MODEL_TYPES
  static final List<String> TYPES_OF_MODELS_LIST = [
    'asr',
    'translation',
    'tts',
    'transliteration',
  ];

  // Keys shall be same as values in TYPES_OF_MODELS_LIST
  static final DEFAULT_MODEL_TYPES = {
    TYPES_OF_MODELS_LIST[0]: 'OpenAI,AI4Bharat,batch,stream',
    TYPES_OF_MODELS_LIST[1]: 'AI4Bharat,',
    TYPES_OF_MODELS_LIST[2]: 'AI4Bharat,',
    TYPES_OF_MODELS_LIST[3]: 'AI4Bharat,',
  };

  static final ASR_MODEL_TYPES = [
    'streaming',
    'batch',
  ];

  static const kNativeName = 'native_name';
  static const kEnglishName = 'english_name';
  static const kLanguageCode = 'language_code';
  static const kLanguageCodeList = 'language_code_list';

  static final LANGUAGE_CODE_MAP = {
    kLanguageCodeList: [
      {
        kNativeName: 'English',
        kLanguageCode: languagesCodeList[0],
        kEnglishName: 'English'
      },
      {
        kNativeName: 'हिन्दी',
        kLanguageCode: languagesCodeList[1],
        kEnglishName: 'Hindi'
      },
      {
        kNativeName: 'मराठी',
        kLanguageCode: languagesCodeList[2],
        kEnglishName: 'Marathi'
      },
      {
        kNativeName: 'বাংলা',
        kLanguageCode: languagesCodeList[3],
        kEnglishName: 'Bangla'
      },
      {
        kNativeName: 'ਪੰਜਾਬੀ',
        kLanguageCode: languagesCodeList[4],
        kEnglishName: 'Punjabi'
      },
      {
        kNativeName: 'ગુજરાતી',
        kLanguageCode: languagesCodeList[5],
        kEnglishName: 'Gujarati'
      },
      {
        kNativeName: 'ଓଡିଆ',
        kLanguageCode: languagesCodeList[6],
        kEnglishName: 'Oriya'
      },
      {
        kNativeName: 'தமிழ்',
        kLanguageCode: languagesCodeList[7],
        kEnglishName: 'Tamil'
      },
      {
        kNativeName: 'తెలుగు',
        kLanguageCode: languagesCodeList[8],
        kEnglishName: 'Telugu'
      },
      {
        kNativeName: 'ಕನ್ನಡ',
        kLanguageCode: languagesCodeList[9],
        kEnglishName: 'Kannada'
      },
      {
        kNativeName: 'اردو',
        kLanguageCode: languagesCodeList[10],
        kEnglishName: 'Urdu'
      },
      {
        kNativeName: 'डोगरी',
        kLanguageCode: languagesCodeList[11],
        kEnglishName: 'Dogri'
      },
      {
        kNativeName: 'नेपाली',
        kLanguageCode: languagesCodeList[12],
        kEnglishName: 'Nepali'
      },
      // {
      //   kNativeName: 'සිංහල',
      //   kLanguageCode: languagesCodeList[13],
      //   kEnglishName: 'Sinhala'
      // },
      {
        kNativeName: 'संस्कृत',
        kLanguageCode: languagesCodeList[14],
        kEnglishName: 'Sanskrit'
      },
      {
        kNativeName: 'অসমীয়া',
        kLanguageCode: languagesCodeList[15],
        kEnglishName: 'Assamese'
      },
      {
        kNativeName: 'मैथिली',
        kLanguageCode: languagesCodeList[16],
        kEnglishName: 'Maithili'
      },
      {
        kNativeName: 'भोजपुरी',
        kLanguageCode: languagesCodeList[17],
        kEnglishName: 'Bhojpuri'
      },
      {
        kNativeName: 'മലയാളം',
        kLanguageCode: languagesCodeList[18],
        kEnglishName: 'Malayalam'
      },
      // {
      //   kNativeName: 'राजस्थानी',
      //   kLanguageCode: languagesCodeList[19],
      //   kEnglishName: 'Rajasthani'
      // },
      {
        kNativeName: 'बड़ो',
        kLanguageCode: languagesCodeList[20],
        kEnglishName: 'Bodo'
      },
      {
        kNativeName: 'ꯃꯩꯇꯩꯂꯣꯟ',
        kLanguageCode: languagesCodeList[21],
        kEnglishName: 'Manipuri'
      },
      {
        kNativeName: 'كٲشُر',
        kLanguageCode: languagesCodeList[22],
        kEnglishName: 'Kashmiri'
      },
      {
        kNativeName: 'कोंकणी',
        kLanguageCode: languagesCodeList[23],
        kEnglishName: 'Konkani'
      },
      {
        kNativeName: 'सिंधी',
        kLanguageCode: languagesCodeList[24],
        kEnglishName: 'Sindhi'
      },
      {
        kNativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
        kLanguageCode: languagesCodeList[25],
        kEnglishName: 'Santali'
      },
    ]
  };

  static String getLanguageCodeOrName({
    required String value,
    required LanguageMap returnWhat,
    required Map<String, List<Map<String, String>>> lang_code_map,
    String? langCode,
  }) {
    // If Language Code is to be returned that means the value received is a language name
    try {
      switch (returnWhat) {
        case LanguageMap.nativeName:
          var returningLangPair = lang_code_map[kLanguageCodeList]!.firstWhere(
              (eachLanguageCodeNamePair) =>
                  eachLanguageCodeNamePair[kLanguageCode]!.toLowerCase() ==
                  value.toLowerCase());
          return returningLangPair[kNativeName] ?? '';

        case LanguageMap.englishName:
          var returningLangPair = lang_code_map[kLanguageCodeList]!.firstWhere(
              (eachLanguageCodeNamePair) =>
                  eachLanguageCodeNamePair[kLanguageCode]!.toLowerCase() ==
                  value.toLowerCase());
          return returningLangPair[kEnglishName] ?? '';

        case LanguageMap.languageCode:
          var returningLangPair = lang_code_map[kLanguageCodeList]!.firstWhere(
              (eachLanguageCodeNamePair) =>
                  eachLanguageCodeNamePair[kNativeName]!.toLowerCase() ==
                  value.toLowerCase());
          return returningLangPair[kLanguageCode] ?? '';
        case LanguageMap.languageNameInAppLanguage:
          String languageNameInAppLanguage = '';

          Map<String, String>? selectedLanguageMap =
              TranslatedLanguagesMap.language[langCode];

          if (selectedLanguageMap != null &&
              selectedLanguageMap[value] != null &&
              selectedLanguageMap[value]!.isNotEmpty) {
            languageNameInAppLanguage = selectedLanguageMap[value]!;
          } else {
            languageNameInAppLanguage = APIConstants.getLanguageCodeOrName(
                value: value,
                returnWhat: LanguageMap.englishName,
                lang_code_map: APIConstants.LANGUAGE_CODE_MAP);
          }
          return languageNameInAppLanguage;
      }
    } catch (e) {
      return '';
    }
  }

  static String getLanguageNameFromCode(String languageCode) {
    return getLanguageCodeOrName(
        value: languageCode,
        returnWhat: LanguageMap.languageNameInAppLanguage,
        lang_code_map: LANGUAGE_CODE_MAP);
  }

  static String getLanNameInAppLang(String languageCode) {
    return getLanguageCodeOrName(
        value: languageCode,
        returnWhat: LanguageMap.languageNameInAppLanguage,
        lang_code_map: LANGUAGE_CODE_MAP,
        langCode: Get.locale?.languageCode);
  }
}
