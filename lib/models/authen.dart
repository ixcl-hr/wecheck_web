class Authen {
  String? token;
  String? passcode;
  String? companyname;
  int? employeeid;

  Authen({
    this.token,
    this.passcode,
    this.companyname,
    this.employeeid,
  });

  Authen.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    passcode = json['passcode'];
    companyname = json['companyname'];
    employeeid = json['employeeid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['passcode'] = passcode;
    data['companyname'] = companyname;
    data['employeeid'] = employeeid;

    return data;
  }
}
