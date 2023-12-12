class GetPersonalDetailModel {
  bool? flag;
  String? message;
  List<PersonalDetail> objectresult = [];

  GetPersonalDetailModel({this.flag, this.message, required this.objectresult});

  GetPersonalDetailModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      json['objectresult'].forEach((v) {
        objectresult.add(PersonalDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag'] = flag;
    data['message'] = message;
    if (objectresult.isNotEmpty) {
      data['objectresult'] = objectresult.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PersonalDetail {
  String? employeeCode;
  String? firstNameTh;
  String? lastNameTh;
  String? firstNameEn;
  String? lastNameEn;
  String? startDate;
  String? gender;

  PersonalDetail(
      {this.employeeCode,
      this.firstNameTh,
      this.lastNameTh,
      this.firstNameEn,
      this.lastNameEn,
      this.startDate,
      this.gender});

  PersonalDetail.fromJson(Map<String, dynamic> json) {
    employeeCode = json['EMPLOYEE_CODE'];
    firstNameTh = json['FIRST_NAME_TH'];
    lastNameTh = json['LAST_NAME_TH'];
    firstNameEn = json['FIRST_NAME_EN'];
    lastNameEn = json['LAST_NAME_EN'];
    startDate = json['START_DATE'];
    gender = json['GENDER'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeeCode'] = employeeCode;
    data['firstNameTh'] = firstNameTh;
    data['lastNameTh'] = lastNameTh;
    data['firstNameEn'] = firstNameEn;
    data['lastNameEn'] = lastNameEn;
    data['startDate'] = startDate;
    data['gender'] = gender;
    return data;
  }
}
