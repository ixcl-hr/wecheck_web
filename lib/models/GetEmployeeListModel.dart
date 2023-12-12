
class GetEmployeeListModel {
  bool? flag;
  String? message;
  List<EmployeeList> objectresult = [];

  GetEmployeeListModel({this.flag, this.message, required this.objectresult});

  GetEmployeeListModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      objectresult = [];
      json['objectresult'].forEach((v) {
        objectresult.add(EmployeeList.fromJson(v));
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

class EmployeeList {
  int? employeeId;
  String? employeeName;

  EmployeeList({this.employeeId, this.employeeName});

  EmployeeList.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee_id'] = employeeId;
    data['employee_name'] = employeeName;

    return data;
  }
}
