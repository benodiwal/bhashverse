class TaskSequenceResponse {
  List<Languages>? languages;
  List<PipelineResponseConfig>? pipelineResponseConfig;
  String? feedbackUrl;
  PipelineInferenceAPIEndPoint? pipelineInferenceAPIEndPoint;
  PipelineInferenceSocketAPIEndPoint? pipelineInferenceSocketAPIEndPoint;

  TaskSequenceResponse(
      {languages,
      pipelineResponseConfig,
      feedbackUrl,
      pipelineInferenceAPIEndPoint});

  TaskSequenceResponse.fromJson(Map<dynamic, dynamic> json) {
    if (json['languages'] != null) {
      languages = <Languages>[];
      json['languages'].forEach((v) {
        languages!.add(Languages.fromJson(v));
      });
    }
    if (json['pipelineResponseConfig'] != null) {
      pipelineResponseConfig = <PipelineResponseConfig>[];
      json['pipelineResponseConfig'].forEach((v) {
        pipelineResponseConfig!.add(PipelineResponseConfig.fromJson(v));
      });
    }
    feedbackUrl = json['feedbackUrl'];
    pipelineInferenceAPIEndPoint = json['pipelineInferenceAPIEndPoint'] != null
        ? PipelineInferenceAPIEndPoint.fromJson(
            json['pipelineInferenceAPIEndPoint'])
        : null;
    pipelineInferenceSocketAPIEndPoint =
        json['pipelineInferenceSocketEndPoint'] != null
            ? PipelineInferenceSocketAPIEndPoint.fromJson(
                json['pipelineInferenceSocketEndPoint'])
            : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    if (languages != null) {
      data['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    if (pipelineResponseConfig != null) {
      data['pipelineResponseConfig'] =
          pipelineResponseConfig!.map((v) => v.toJson()).toList();
    }
    data['feedbackUrl'] = feedbackUrl;
    if (pipelineInferenceAPIEndPoint != null) {
      data['pipelineInferenceAPIEndPoint'] =
          pipelineInferenceAPIEndPoint!.toJson();
    }
    if (pipelineInferenceSocketAPIEndPoint != null) {
      data['pipelineInferenceSocketEndPoint'] =
          pipelineInferenceSocketAPIEndPoint!.toJson();
    }
    return data;
  }
}

class Languages {
  String? sourceLanguage;
  List<dynamic>? targetLanguageList;

  Languages({sourceLanguage, targetLanguageList});

  Languages.fromJson(Map<dynamic, dynamic> json) {
    sourceLanguage = json['sourceLanguage'];
    targetLanguageList = json['targetLanguageList'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['sourceLanguage'] = sourceLanguage;
    data['targetLanguageList'] = targetLanguageList;
    return data;
  }
}

class PipelineResponseConfig {
  String? taskType;
  List<Config>? config;

  PipelineResponseConfig({taskType, config});

  PipelineResponseConfig.fromJson(Map<dynamic, dynamic> json) {
    taskType = json['taskType'];
    if (json['config'] != null) {
      config = <Config>[];
      json['config'].forEach((v) {
        config!.add(Config.fromJson(v));
      });
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['taskType'] = taskType;
    if (config != null) {
      data['config'] = config!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Config {
  String? serviceId;
  String? modelId;
  Language? language;
  List<dynamic>? domain;
  List<dynamic>? supportedVoices;

  Config({serviceId, modelId, language, domain, supportedVoices});

  Config.fromJson(Map<dynamic, dynamic> json) {
    serviceId = json['serviceId'];
    modelId = json['modelId'];
    language =
        json['language'] != null ? Language.fromJson(json['language']) : null;
    domain = json['domain'];
    supportedVoices = json['supportedVoices'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['serviceId'] = serviceId;
    data['modelId'] = modelId;
    if (language != null) {
      data['language'] = language!.toJson();
    }
    data['domain'] = domain;
    data['supportedVoices'] = supportedVoices;
    return data;
  }
}

class Language {
  String? sourceLanguage;
  String? targetLanguage;

  Language({sourceLanguage, targetLanguage});

  Language.fromJson(Map<dynamic, dynamic> json) {
    sourceLanguage = json['sourceLanguage'];
    targetLanguage = json['targetLanguage'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['sourceLanguage'] = sourceLanguage;
    data['targetLanguage'] = targetLanguage;
    return data;
  }
}

class PipelineInferenceAPIEndPoint {
  String? callbackUrl;
  InferenceApiKey? inferenceApiKey;
  bool? isMultilingualEnabled;
  bool? isSyncApi;

  PipelineInferenceAPIEndPoint(
      {callbackUrl, inferenceApiKey, isMultilingualEnabled, isSyncApi});

  PipelineInferenceAPIEndPoint.fromJson(Map<dynamic, dynamic> json) {
    callbackUrl = json['callbackUrl'];
    inferenceApiKey = json['inferenceApiKey'] != null
        ? InferenceApiKey.fromJson(json['inferenceApiKey'])
        : null;
    isMultilingualEnabled = json['isMultilingualEnabled'];
    isSyncApi = json['isSyncApi'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['callbackUrl'] = callbackUrl;
    if (inferenceApiKey != null) {
      data['inferenceApiKey'] = inferenceApiKey!.toJson();
    }
    data['isMultilingualEnabled'] = isMultilingualEnabled;
    data['isSyncApi'] = isSyncApi;
    return data;
  }
}

class InferenceApiKey {
  String? name;
  String? value;

  InferenceApiKey({name, value});

  InferenceApiKey.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class PipelineInferenceSocketAPIEndPoint {
  String? callbackUrl;
  InferenceApiKey? inferenceApiKey;
  bool? isMultilingualEnabled;
  bool? isSyncApi;

  PipelineInferenceSocketAPIEndPoint(
      {callbackUrl, inferenceApiKey, isMultilingualEnabled, isSyncApi});

  PipelineInferenceSocketAPIEndPoint.fromJson(Map<dynamic, dynamic> json) {
    callbackUrl = json['callbackUrl'];
    inferenceApiKey = json['inferenceApiKey'] != null
        ? InferenceApiKey.fromJson(json['inferenceApiKey'])
        : null;
    isMultilingualEnabled = json['isMultilingualEnabled'];
    isSyncApi = json['isSyncApi'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['callbackUrl'] = callbackUrl;
    if (inferenceApiKey != null) {
      data['inferenceApiKey'] = inferenceApiKey!.toJson();
    }
    data['isMultilingualEnabled'] = isMultilingualEnabled;
    data['isSyncApi'] = isSyncApi;
    return data;
  }
}
