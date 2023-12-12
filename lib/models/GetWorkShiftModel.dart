class WorkShiftModel {
  bool? flag;
  String? message;
  List<WorkShift> objectresult = [];

  WorkShiftModel({this.flag, this.message, required this.objectresult});

  WorkShiftModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(WorkShift.fromJson(v));
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

class WorkShift {
  int? workshift_id;
  String? name_th;
  String? name_en;

  WorkShift({this.workshift_id, this.name_th, this.name_en});

  WorkShift.fromJson(Map<String, dynamic> json) {
    workshift_id = json['workshift_id'];
    name_th = json['name_th'];
    name_en = json['name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workshift_id'] = workshift_id;
    data['name_th'] = name_th;
    data['name_en'] = name_en;
    return data;
  }
}
