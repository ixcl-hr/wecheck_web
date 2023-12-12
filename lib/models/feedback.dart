class Feedback {
  bool? flag;
  String? message;
  String? objectresult;

  Feedback({this.flag, this.message, this.objectresult});

  Feedback.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    objectresult = json['objectresult'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    data['objectresult'] = objectresult;
    return data;
  }
}
