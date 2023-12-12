import '../constants/config.dart';
import 'package:http/http.dart' as http;
import '../models/GetConatctInfoModel.dart';
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetContactInfoService {
  final profile;
  GetContactInfoService({
    required this.profile,
  });

  Future<List<ContactInfo>> getData({required Profile profile}) async {
    List<ContactInfo> contactInfo = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "passcode": profile.passcode,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetEmployeeProfile/GetEmployeeContactInfo';

    try {
      var response0 =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print(response0.body);
      print(response0.statusCode);

      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        GetContactInfoModel feedback = GetContactInfoModel.fromJson(response);
        return contactInfo = feedback.objectresult;
      } else {
        print('Error Status : ${response0.body}');
        return contactInfo;
      }
    } catch (e) {
      print('Error: $e');
      return contactInfo;
    }
  }
}
