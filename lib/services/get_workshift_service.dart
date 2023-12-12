import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../models/GetWorkShiftModel.dart';
import '../models/profile.dart';

class GetWorkShiftService {
  List<WorkShift> workshiftList = [];

  Future getWorkShift({required Profile profile}) async {
    var payload = convert.jsonEncode({
      "employeecode": profile.employeecode,
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });

    print("payload");
    // print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetWorkShiftList';
    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);

      WorkShiftModel feedback =
          WorkShiftModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return workshiftList = feedback.objectresult;
      } else {
        return workshiftList;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
