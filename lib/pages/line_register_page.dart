import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../constants/constant.dart';
import '../models/profile.dart';
import '../services/util_service.dart';

// import 'dart:js' as js;

class LineRegisterPage extends StatefulWidget {
  const LineRegisterPage({super.key, required this.profile});
  final Profile profile;
  @override
  _LineRegisterPageState createState() => _LineRegisterPageState();
}

class _LineRegisterPageState extends State<LineRegisterPage> {
  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  initPrefs() async {
    LineSDK.instance
        .setup(widget.profile.lineGroupChannelId ?? "")
        .then((_) async {
      print('LineSDK Prepared');

      String? lineToken0 = await UtilService.getLineToken();

      if (lineToken0 != null && lineToken0.isNotEmpty) {
        dynamic lineToken = convert.jsonDecode(lineToken0);
        setState(() {
          accesstoken = lineToken['accesstoken'];
          displayname = lineToken['displayname'];
          imgUrl = lineToken['imgUrl'];
          userId = lineToken['userId'];
        });
      }
    });
  }

  printData() {
    setState(() {
      accesstoken = accesstoken;
    });
    // print("AccessToken> " + accesstoken.toString());
    // print("DisplayName> " + displayname.toString());
    // print("ProfileURL> " + imgUrl.toString());
    // print("userId> " + userId.toString());
  }

  showDialogBox(String str, String str2) {}

  Future<String?> getAccessToken() async {
    try {
      final result = await LineSDK.instance.currentAccessToken;
      if (result != null) {
        return result.value;
      } else {
        return "";
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
    return null;
  }

  var accesstoken, displayname, imgUrl, userId;

  void startLineLogin() async {
    try {
      // var parameters = LoginOption(false, "aggressive",)
      final result = await LineSDK.instance.login(scopes: ["profile"]);
      //print(result.toString());

      var accesstoken = await getAccessToken();
      var displayname = result.userProfile!.displayName;
      var imgUrl = result.userProfile!.pictureUrl;
      var userId = result.userProfile!.userId;

      //print("AccessToken> " + (_accesstoken ?? ""));
      print("DisplayName> $displayname");
      // print("ProfileURL> " + _imgUrl);
      // print("userId> " + _userId);

      var jsonLine = convert.jsonEncode({
        'accesstoken': accesstoken,
        'displayname': displayname,
        'imgUrl': imgUrl,
        'userId': userId,
      });

      await UtilService.setSharedPreferences('line_token', jsonLine);
      var lineToken0 = jsonLine; //await prefs.getString('line_token');
      var lineToken = convert.jsonDecode(lineToken0);

      setState(() {
        accesstoken = lineToken['accesstoken'];
        displayname = lineToken['displayname'];
        imgUrl = lineToken['imgUrl'];
        userId = lineToken['userId'];
        accesstoken = accesstoken;
      });

      pushLineKeyToServer(userId);
    } on PlatformException catch (e) {
      print(e);
      switch (e.code.toString()) {
        // case "CANCEL":
        //   _scaffoldKey.currentState?.showSnackBar(
        //     const SnackBar(
        //       backgroundColor: Colors.grey,
        //       content: Text(
        //           'เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง'),
        //     ),
        //   );
        //   break;
        // case "AUTHENTICATION_AGENT_ERROR":
        //   print("คุณไม่อนุญาติการเข้าสู่ระบบด้วย LINE");
        //   _scaffoldKey.currentState?.showSnackBar(
        //     const SnackBar(
        //       backgroundColor: Colors.grey,
        //       content: Text(
        //           'เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง'),
        //     ),
        //   );
        //   break;
        default:
          print("เกิดข้อผิดพลาด");
          // _scaffoldKey.currentState?.showSnackBar(
          //   const SnackBar(
          //     backgroundColor: Colors.orange,
          //     content: Text(
          //         'เกิดข้อผิดพลาดไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง'),
          //   ),
          // );
          break;
      }
    }
  }

  void pushLineKeyToServer(userId) async {
    var url = '$ApiMaster/RegisterEmployeeLine';
    var payload = convert.jsonEncode({
      "companyname": widget.profile.companyname,
      "employeeid": widget.profile.employeeid,
      "lineuserid": userId
    });
    //print({payload: payload});
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.profile.token}'
    };

    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print('response pushLineKeyToServer');
    //print(response.body);

    // _scaffoldKey.currentState?.showSnackBar(
    //   const SnackBar(
    //     backgroundColor: Colors.orange,
    //     content: Text('บันทึก User ID Line เรียบร้อย'),
    //   ),
    // );
  }

  void logoutLine() async {
    try {
      await LineSDK.instance.logout();

      setState(() {
        accesstoken = null;
        displayname = null;
        imgUrl = 'assets/images/user (6).png';
        userId = null;
      });

      await UtilService.setSharedPreferences('line_token', null);

      print('ออกจากระบบ');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8101),
        title: Text(
          'ลงทะเบียนผ่าน Line',
          style: TextStyle(color: Colors.white, fontFamily: fontFamilyCustom),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          accesstoken == null
              ? const Text('')
              : Padding(
                  padding: const EdgeInsets.all(26.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          image: DecorationImage(
                            image: NetworkImage(imgUrl),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Text('Name :',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Text(' $displayname', style: kProfile),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Line Group :',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.profile.companylinegroup ?? "",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'UserId :',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$userId',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
          const SizedBox(
            height: 30,
          ),
          Container(
            child: accesstoken == null
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    // child: FlatButton.icon(
                    //   icon: Image.asset(
                    //     'assets/images/line.png',
                    //     width: 50,
                    //     height: 50,
                    //   ),
                    //   label: Text('เข้าสู่ระบบด้วย LINE'),
                    //   onPressed: () {
                    //     startLineLogin();
                    //   },
                    // ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(10.0),
                    // child: FlatButton.icon(
                    //   icon: Image.asset(
                    //     'assets/images/line.png',
                    //     width: 50,
                    //     height: 50,
                    //   ),
                    //   label: Text('ออกจากระบบ Line'),
                    //   onPressed: () {
                    //     logoutLine();
                    //   },
                    // ),
                  ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

const kProfile = TextStyle(fontSize: 16);
