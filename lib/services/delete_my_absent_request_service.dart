import '../constants/config.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class DeleteMyAbsentRequestService {
  deleteRequest({
    required Profile profile,
    required listRequest,
  }) async {
    print('deleteRequest');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "absentrequestidlist": listRequest,
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}DeleteMyAbsentRequest';
    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    //print(_response.body);
    var response = convert.jsonDecode(response0.body);
    if (response['flag'] == true) {
      print("DeleteMyAbsentRequest successfully");
    } else {
      print("wrong! Status Code is: ${response0.statusCode}");
    }
  }
}
