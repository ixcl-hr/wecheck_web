class GetReportAbsentModel {
  bool? flag;
  String? message;
  ReportAbsentModel? objectresult;

  GetReportAbsentModel({this.flag, this.message, this.objectresult});

  GetReportAbsentModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = ReportAbsentModel.fromJson(json['objectresult']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    if (objectresult != null) {
      data['objectresult'] = (objectresult as ReportAbsentModel).toJson();
    }
    return data;
  }
}

class ReportAbsentModel {
  String? filename;
  String? attachfile;

  ReportAbsentModel({this.filename, this.attachfile});

  ReportAbsentModel.fromJson(Map<String, dynamic> json) {
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
