
class GetDepartmentListModel {
  bool? flag;
  String? message;
  List<DepartmentList> objectresult = [];

  GetDepartmentListModel({this.flag, this.message, required this.objectresult});

  GetDepartmentListModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(DepartmentList.fromJson(v));
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

class DepartmentList {
  int? masterId;
  String? masterNameTH;
  String? masterNameEN;

  DepartmentList({this.masterId, this.masterNameTH, this.masterNameEN});

  DepartmentList.fromJson(Map<String, dynamic> json) {
    masterId = json['master_id'];
    masterNameTH = json['master_name_th'];
    masterNameEN = json['master_name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['master_id'] = masterId;
    data['master_name_th'] = masterNameTH;
    data['master_name_en'] = masterNameEN;
    return data;
  }
}
