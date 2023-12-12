class OTApproverModel {
  bool? flag;
  String? message;
  List<OTApprover> objectresult = [];

  OTApproverModel({this.flag, this.message, required this.objectresult});

  OTApproverModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(OTApprover.fromJson(v));
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

class OTApprover {
  int? key;
  String? text;

  OTApprover({this.key, this.text});

  OTApprover.fromJson(Map<String, dynamic> json) {
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
