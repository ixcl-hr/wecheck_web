import '../constants/config.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class DeleteMyOTRequestService {
  Future<bool> deleteMyOTRequest({
    required Profile profile,
    required listRequest,
  }) async {
    print('DeleteMyOTRequest');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "OTRequestIdList": listRequest,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}DeleteMyOTRequest';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print(response.body);
    if (response.statusCode == 200) {
      print("DeleteMyOTRequest successfully");
      return true;
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
    }
    return false;
  }
}
