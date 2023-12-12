import 'dart:convert' as convert;

class GetContactInfoModel {
  bool? flag;
  String? message;
  List<ContactInfo> objectresult = [];

  GetContactInfoModel({this.flag, this.message, required this.objectresult});

  GetContactInfoModel.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    message = json['message'];
    if (json['objectresult'] != null) {
      var result = convert.jsonDecode(json['objectresult']);
      result.forEach((v) {
        objectresult.add(ContactInfo.fromJson(v));
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

class ContactInfo {
  String? email;
  String? addressLine1;
  String? addressLine2;
  String? startDate;
  String? provinceName;
  String? zipcode;

  ContactInfo(
      {this.email,
      this.addressLine1,
      this.addressLine2,
      this.startDate,
      this.provinceName,
      this.zipcode});

  ContactInfo.fromJson(Map<String, dynamic> json) {
    email = json['EMAIL'];
    addressLine1 = json['ADDRESS_LINE1'];
    addressLine2 = json['ADDRESS_LINE2'];
    startDate = json['ADDRESS_LINE2'];
    provinceName = json['PROVINCE_NAME'];
    zipcode = json['ZIP_CODE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['addressLine1'] = addressLine1;
    data['addressLine2'] = addressLine2;
    data['startDate'] = startDate;
    data['provinceName'] = provinceName;
    data['zipcode'] = zipcode;
    return data;
  }
}
