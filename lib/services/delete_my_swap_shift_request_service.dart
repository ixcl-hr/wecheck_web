import '../constants/config.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class DeleteMySwapShiftRequestService {
  Future<bool> deleteMyRequest({
    required Profile profile,
    required listRequest,
  }) async {
    print('DeleteMySwapShiftRequest');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "requestidlist": listRequest,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}DeleteMySwapShiftRequest';
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
