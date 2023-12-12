class AbsentApproverModel {
  bool? flag;
  String? message;
  List<AbsentApprover> objectresult = [];

  AbsentApproverModel({this.flag, this.message, required this.objectresult});

  AbsentApproverModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(AbsentApprover.fromJson(v));
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

class AbsentApprover {
  int? key;
  String? text;

  AbsentApprover({this.key, this.text});

  AbsentApprover.fromJson(Map<String, dynamic> json) {
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
