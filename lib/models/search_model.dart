class SearchModel {
  late String message;
  late List<SearchModelData> data;
  late int count;

  SearchModel({
    required this.message,
    required this.data,
    required this.count,
  });

  SearchModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <SearchModelData>[];
      json['data'].forEach((v) {
        data.add(SearchModelData.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['data'] = this.data.map((v) => v.toJson()).toList();
    data['count'] = count;
    return data;
  }
}

class SearchModelData {
  SearchModelData({
    required this.name,
    required this.description,
    required this.refUrl,
    required this.task,
    required this.languages,
    required this.submitter,
    required this.inferenceEndPoint,
    required this.modelId,
    required this.userId,
  });
  late final String name;

  late final String description;
  late final String refUrl;
  late final Task task;
  late final List<Languages> languages;

  late final Submitter submitter;
  late final InferenceEndPoint inferenceEndPoint;

  late final String modelId;
  late final String userId;

  SearchModelData.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    description = json['description'];
    refUrl = json['refUrl'];
    task = Task.fromJson(json['task']);
    languages =
        List.from(json['languages']).map((e) => Languages.fromJson(e)).toList();

    submitter = Submitter.fromJson(json['submitter']);
    inferenceEndPoint = InferenceEndPoint.fromJson(json['inferenceEndPoint']);

    modelId = json['modelId'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;

    data['description'] = description;
    data['refUrl'] = refUrl;
    data['task'] = task.toJson();
    data['languages'] = languages.map((e) => e.toJson()).toList();

    data['submitter'] = submitter.toJson();
    data['inferenceEndPoint'] = inferenceEndPoint.toJson();

    data['modelId'] = modelId;
    data['userId'] = userId;

    return data;
  }
}

class Task {
  Task({
    required this.type,
  });
  late final String type;

  Task.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    return data;
  }
}

class Languages {
  Languages({
    this.sourceLanguageName,
    required this.sourceLanguage,
    this.targetLanguageName,
    this.targetLanguage,
  });
  late final String? sourceLanguageName;
  late final String sourceLanguage;
  late final String? targetLanguageName;
  late final String? targetLanguage;

  Languages.fromJson(Map<String, dynamic> json) {
    sourceLanguageName = json['sourceLanguageName'];
    sourceLanguage = json['sourceLanguage'];
    targetLanguageName = json['targetLanguageName'];
    targetLanguage = json['targetLanguage'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sourceLanguageName'] = sourceLanguageName;
    data['sourceLanguage'] = sourceLanguage;
    data['targetLanguageName'] = targetLanguageName;
    data['targetLanguage'] = targetLanguage;
    return data;
  }
}

class Submitter {
  Submitter({
    required this.name,
    this.aboutMe,
  });
  late final String name;
  late final String? aboutMe;

  Submitter.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    aboutMe = null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['aboutMe'] = aboutMe;
    return data;
  }
}

class InferenceEndPoint {
  InferenceEndPoint({
    required this.callbackUrl,
    required this.modelProcessingType,
  });
  late final String? callbackUrl;
  late final String? modelProcessingType;

  InferenceEndPoint.fromJson(Map<String, dynamic> json) {
    callbackUrl = json['callbackUrl'];
    if (json['schema']['modelProcessingType'] != null) {
      modelProcessingType = json['schema']['modelProcessingType']['type'];
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['callbackUrl'] = callbackUrl;
    data['schema']['type'] = modelProcessingType;

    return data;
  }
}
