class GetSlipModel {
  bool? flag;
  String? message;
  SlipModel? objectresult;

  GetSlipModel({this.flag, this.message, this.objectresult});

  GetSlipModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = SlipModel.fromJson(json['objectresult']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    if (objectresult != null) {
      data['objectresult'] = (objectresult as SlipModel).toJson();
    }
    return data;
  }
}

class SlipModel {
  String? filename;
  String? attachfile;

  SlipModel({this.filename, this.attachfile});

  SlipModel.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    attachfile = json['attachfile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filename'] = filename;
    data['attachfile'] = attachfile;
    return data;
  }
}
