class ASRResponseModel {
  late int count;
  late Data data;
  late String message;

  ASRResponseModel({required this.count, required this.data, required this.message});

  ASRResponseModel.fromJson(Map<String, dynamic> json) {
    count = json['count'] ?? 0;
    data = Data.fromJson(json['data'] ?? {'source': ''});
    message = json['message'] ?? 'No Message received';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['data'] = this.data.toJson();
    data['message'] = message;
    return data;
  }
}

class Data {
  late String source;

  Data({required this.source});

  Data.fromJson(Map<String, dynamic> json) {
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['source'] = source;
    return data;
  }
}
