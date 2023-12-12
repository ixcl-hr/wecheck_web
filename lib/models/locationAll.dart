class LocationAllModel {
  bool? flag;
  String? message;
  List<LocationAll> objectresult = [];

  LocationAllModel({this.flag, this.message, required this.objectresult});

  LocationAllModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(LocationAll.fromJson(v));
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

class LocationAll {
  int? key;
  String? text;

  LocationAll({
    this.key,
    this.text,
  });

  LocationAll.fromJson(Map<String, dynamic> json) {
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
