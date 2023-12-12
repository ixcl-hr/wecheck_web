class AdjustApproverModel {
  bool? flag;
  String? message;
  List<AdjustApprover> objectresult = [];

  AdjustApproverModel({this.flag, this.message, required this.objectresult});

  AdjustApproverModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      json['objectresult'].forEach((v) {
        objectresult.add(AdjustApprover.fromJson(v));
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

class AdjustApprover {
  int? key;
  String? text;

  AdjustApprover(this.key, this.text);

  AdjustApprover.fromJson(Map<String, dynamic> json) {
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
