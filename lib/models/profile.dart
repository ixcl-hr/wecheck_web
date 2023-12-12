class Profile {
  String? token;
  String? passcode;
  String? companyname;
  String? companycaption;
  String? companylinegroup;
  int? employeeid;
  String? employeeprefix;
  String? employeename;
  String? employeesurname;
  String? employeeclass;
  String? employeecode;
  String? employeepicture;

  bool? isApprover;
  bool? isUseAttachFile;
  bool? isForceAttachPicture;
  double? minAbsentHour;
  String? customerURL;
  String? lineGroupChannelId;
  String? app_name;
  String? app_version;
  int? build_number;
  String? language;

  Profile({
    this.token,
    this.passcode,
    this.companyname,
    this.companycaption,
    this.companylinegroup,
    this.employeeid,
    this.employeeprefix,
    this.employeename,
    this.employeesurname,
    this.employeeclass,
    this.employeecode,
    this.employeepicture,
    this.isApprover,
    this.isUseAttachFile,
    this.isForceAttachPicture,
    this.minAbsentHour,
    this.customerURL,
    this.lineGroupChannelId,
    this.app_name,
    this.app_version,
    this.build_number,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    passcode = json['passcode'];
    companyname = json['companyname'];
    companycaption = json['companycaption'];
    companylinegroup = json['companylinegroup'];
    employeeid = json['employeeid'];
    employeeprefix = json['employeeprefix'];
    employeename = json['employeename'];
    employeesurname = json['employeesurname'];
    employeeclass = json['employeeclass'];
    employeecode = json['employeecode'];
    employeepicture = json['employeepicture'];
    isApprover = json['isapprover'] ?? false;
    isUseAttachFile = json['isuseattachfile'] ?? false;
    isForceAttachPicture = json['isforceattachpicture'] ?? false;
    minAbsentHour = json['minabsenthour'];
    customerURL = json['customerURL'];
    lineGroupChannelId = json['linegroupchannelid'];
    app_name = json['app_name'];
    app_version = json['app_version'];
    build_number = json['build_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['passcode'] = passcode;
    data['companyname'] = companyname;
    data['companycaption'] = companycaption;
    data['companylinegroup'] = companylinegroup;
    data['employeeid'] = employeeid;
    data['employeeprefix'] = employeeprefix;
    data['employeename'] = employeename;
    data['employeesurname'] = employeesurname;
    data['employeeclass'] = employeeclass;
    data['employeecode'] = employeecode;
    data['employeepicture'] = employeepicture;
    data['isapprover'] = isApprover ?? false;
    data['isuseattachfile'] = isUseAttachFile ?? false;
    data['isforceattachpicture'] = isForceAttachPicture ?? false;
    data['minabsenthour'] = minAbsentHour;
    data['customerURL'] = customerURL;
    data['linegroupchannelid'] = lineGroupChannelId;
    data['app_name'] = app_name;
    data['app_version'] = app_version;
    data['build_number'] = build_number;
    return data;
  }
}
