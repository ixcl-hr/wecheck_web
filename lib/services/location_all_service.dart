import '../constants/config.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/locationAll.dart';
import '../models/profile.dart';

class LocationAllService {
  static List<LocationAll> locationList = [];

  Future<List<LocationAll>> getLocationAll({
    required Profile profile,
  }) async {
    print('===>  LocationAllService');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });

    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}GetLocationAll';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    if (response.statusCode == 200) {
      print("Data posted successfully");
      var feedback = convert.jsonDecode(response.body);
      print(feedback['objectresult']);
      final LocationAllModel location =
          LocationAllModel.fromJson(convert.jsonDecode(response.body));
      locationList = location.objectresult;
      return locationList;
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
      return locationList = [];
    }
  }
}
