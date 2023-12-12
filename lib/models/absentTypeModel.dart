class AbsentTypeModel {
  bool? flag;
  String? message;
  List<AbsentType> objectresult = [];

  AbsentTypeModel({this.flag, this.message, required this.objectresult});

  AbsentTypeModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = []; //new List<AbsentType>();
      json['objectresult'].forEach((v) {
        objectresult.add(AbsentType.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    data['objectresult'] = objectresult.map((v) => v.toJson()).toList();
      return data;
  }
}

class AbsentType {
  int? key;
  String? text;

  AbsentType({this.key, this.text});

  AbsentType.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['text'] = text;
    return data;
  }
}
