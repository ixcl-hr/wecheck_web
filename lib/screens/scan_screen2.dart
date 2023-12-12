import 'dart:convert' as convert;
// import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../constants/config.dart';
import '../models/convert_date.dart';
import '../models/history.dart';
import '../models/location.dart';
import '../models/profile.dart';
import '../pages/map_view_page.dart';
import '../pages/scan_qrcode_page.dart';
import '../services/convert_time_service.dart';
import '../services/current_location_service.dart';
import '../services/history_service.dart';
import '../services/location_service.dart';
import '../services/scan_service.dart';
import '../services/type_scan_service.dart';
import '../services/util_service.dart';
import '../widgets/attach_file_web_widget.dart';
import '../widgets/attach_file_widget.dart';
import '../widgets/qrcode_scan_widget.dart';

class ScanScreen2 extends StatefulWidget {
  const ScanScreen2({super.key});
  static String id = 'Scan';
  @override
  ScanScreen2State createState() => ScanScreen2State();
}

class ScanScreen2State extends State<ScanScreen2> {
  Profile? profile;

  TextEditingController attachFileController = TextEditingController();

  dynamic attachedFile;
  dynamic dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
  bool isLoading = true;
  bool isLoadingHistory = true;
  bool isLoadingLocation = true;

  final _chooseLocationKey = GlobalKey();
  dynamic attachFileWidget;
  int? locationid;
  Location? selectLocation;
  int selectedLocationIndex = -1;

  List<History> historyList = [];
  List<Location> locationList = [];

  Position? position;
  String? routerIP;
  String? wifiName;
  String? typeNetwork;

  String typeScan = "";

  @override
  void initState() {
    super.initState();

    initPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initPrefs() async {
    profile = await UtilService.getProfile();
    //await document.documentElement!.requestFullscreen();
    await getCurrentLocation();
    await getTypeScan();
    await getHistoryScan();

    if (mounted) {
      setState(() {
        profile = profile;
        historyList = historyList;
        isLoadingHistory = false;
      });
    }
  }

  Alert buildAlertError(BuildContext context, String title, String message) {
    return Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.warning,
      title: title,
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }

//   void buildAttachFileWidget(BuildContext context) {
//     attachFileWidget = !kIsWeb
//         ? AttachFileWidget(
//             allowLocalImg: false,
//             onSelected: (file) {
//               attachedFile = file;
//             },
//             onError: (title, desc) {
//               buildAlertError(context, title, desc).show();
//             },
//             attachFileController: attachFileController,
//           )
//         : AttachFileWebWidget(
//             onSelected: (fileWeb) {
//               attachedFile = fileWeb;
//             },
//             onError: (title, desc) {
//               buildAlertError(context, title, desc).show();
//             },
//             withLabel: true,
//             allowLocalImg: false,
//             attachFileController: attachFileController,
//           );

//     setState(() {
//       attachFileWidget = attachFileWidget;
//     });
//   }

  @override
  Widget build(BuildContext context) {
//     buildAttachFileWidget(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFF8101),
          title: Text(
            UtilService.getTextFromLang("checkin", "ลงเวลา"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              constraints: const BoxConstraints(
                maxWidth: 100,
              ),
              icon: const Icon(
                Icons.map_outlined,
                //color: Color.fromRGBO(245, 157, 86, 1.0),
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(right: 10.0),
              onPressed: () async {
                print(position);
                if (position != null) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => MapViewPage(
                              lat: (position!).latitude,
                              lng: (position!).longitude)))
                      .then((value) {});
                } else {
                  buildAlertError(
                      context,
                      "พบข้อผิดพลาด",
                      UtilService.getTextFromLang("unable_request_location",
                          "ไม่สามารถหา Location ปัจจุบันของคุณได้"));
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Text(position == null
              ? "null"
              : ("position: " +
                  position!.latitude.toString() +
                  ", " +
                  position!.longitude.toString())),
//             child: (position == null) &&
//                     (profile == null || profile!.passcode != appstorePasscode)
//                 ? const Center(child: CircularProgressIndicator())
//                 : Padding(
//                     padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
//                     child: Column(children: <Widget>[
//                       buildHistory(),
//                       const SizedBox(height: 10),
//                       buildLocation(),
//                       attachFileWidget ?? Container(),
//                       position == null && profile!.passcode != appstorePasscode
//                           ? const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: CircularProgressIndicator(),
//                             )
//                           : Container(
//                               padding: const EdgeInsets.all(10),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   typeScan == 'I'
//                                       ? ButtonWidget(
//                                           title: UtilService.getTextFromLang(
//                                               "checkin_in", "สแกนเข้า"),
//                                           onPressed: () {
//                                             print("สแกนเข้า");
//                                             if (locationid == null) {
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                   backgroundColor:
//                                                       Colors.black87,
//                                                   content: Padding(
//                                                     padding:
//                                                         EdgeInsets.all(8.0),
//                                                     child: Text(
//                                                         'กรุณาเลือกสถานที่'),
//                                                   ),
//                                                 ),
//                                               );
//                                             } else {
//                                               onScan(
//                                                   typescan: 'I',
//                                                   typeScan: 'เข้า');
//                                             }
//                                           },
//                                           color: const Color(0xFFFF8101),
//                                           icon: Icons.arrow_circle_up_rounded,
//                                         )
//                                       : ButtonWidget(
//                                           title: UtilService.getTextFromLang(
//                                               "checkin_out", "สแกนออก"),
//                                           onPressed: () {
//                                             if (locationid == null) {
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                   backgroundColor:
//                                                       Colors.black87,
//                                                   content: Padding(
//                                                     padding:
//                                                         EdgeInsets.all(8.0),
//                                                     child: Text(
//                                                         'กรุณาเลือกสถานที่'),
//                                                   ),
//                                                 ),
//                                               );
//                                             } else {
//                                               onScan(
//                                                   typescan: 'O',
//                                                   typeScan: 'ออก');
//                                             }
//                                           },
//                                           color: Colors.black,
//                                           icon: Icons.arrow_circle_down_rounded,
//                                         ),
//                                 ],
//                               ),
//                             ),
//                     ]))
        ));
  }

//   Expanded buildHistory() {
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.4),
//               spreadRadius: 2,
//               blurRadius: 2,
//               offset: const Offset(1, 1), // changes position of shadow
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//           child: Column(
//             children: <Widget>[
//               const SizedBox(height: 5.0),
//               Center(
//                   child: Text(
//                 UtilService.getTextFromLang("date", "วันที่") + ' $dateNow',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               )),
//               const SizedBox(height: 10.0),
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       UtilService.getTextFromLang("date", "วัน"),
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       UtilService.getTextFromLang("time", "เวลา"),
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       UtilService.getTextFromLang("checkin", "เข้า/ออก"),
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10.0),
//               Expanded(
//                 // child: Scrollbar(
//                 child: isLoadingHistory
//                     ? const Center(child: CircularProgressIndicator())
//                     : ListView.separated(
//                         // reverse: true,
//                         separatorBuilder: (BuildContext bContext, int index) {
//                           return const SizedBox(height: 5.0);
//                         },
//                         itemCount: historyList.length,
//                         itemBuilder: (BuildContext bContext, int index) {
//                           return Row(
//                             crossAxisAlignment: CrossAxisAlignment.baseline,
//                             textBaseline: TextBaseline.alphabetic,
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: Center(
//                                   child: Text(
//                                     parseDate(
//                                         historyList[index].scandate ?? ""),
//                                     style: const TextStyle(fontSize: 14.0),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 1,
//                                 child: Center(
//                                   child: Text(
//                                     ConvertTime(historyList[index].scantime ??
//                                                 "")
//                                             .getTime() ??
//                                         "",
//                                     style: const TextStyle(fontSize: 14.0),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 1,
//                                 child: Center(
//                                   child: Text(
//                                     historyList[index].scantype == 'I'
//                                         ? UtilService.getTextFromLang(
//                                             "in", "เข้า")
//                                         : UtilService.getTextFromLang(
//                                             "out", "ออก"),
//                                     style: const TextStyle(fontSize: 14.0),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         }),
//               ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Expanded buildLocation() {
//     final bool hasLocation = locationList.isNotEmpty;
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         UtilService.getTextFromLang(
//                             "selectlocation", "เลือกสถานที่สแกน"),
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.w600),
//                       ),
//                       IconButton(
//                         color: Colors.black,
//                         onPressed: () async {
//                           CurrentLocationService currentLocationService =
//                               CurrentLocationService();
//                           position =
//                               await currentLocationService.determinePosition();
//                           if (position != null) {
//                             getLocation(position);
//                           }
//                         },
//                         icon: const Icon(Icons.refresh),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Visibility(
//                       visible: !hasLocation,
//                       maintainSize: true,
//                       maintainAnimation: true,
//                       maintainState: true,
//                       child: Container(
//                         alignment: Alignment.centerRight,
//                         child: OutlinedButton(
//                           key: _chooseLocationKey,
//                           onPressed: () {},
//                           child: const Text(
//                             '...',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               // child: Scrollbar(
//               child: isLoadingLocation
//                   ? const Center(child: CircularProgressIndicator())
//                   : ListView.builder(
//                       itemCount: locationList.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return LocationWidget(
//                           location: locationList[index],
//                           bgColor: index == selectedLocationIndex
//                               ? const Color.fromRGBO(245, 157, 86, 1.0)
//                               : null,
//                           onTap: () {
//                             setState(() {
//                               selectedLocationIndex = index;
//                               locationid = locationList[index].locationid;
//                               selectLocation = locationList[index];
//                               //print(convert.jsonEncode(selectLocation));
//                             });
//                           },
//                         );
//                       },
//                     ),
//             ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   onScan({typescan, typeScan, bool withTime = true}) async {
//     ScanService scanService = ScanService();
//     String? qrcode;

//     // Check last check time from history
//     if (historyList.isNotEmpty) {
//       DateTime ntpTime = DateTime.now();
//       //kIsWeb ? DateTime.now() : await NTP.now();
//       DateTime lastTime = historyList.first.toDateTime();
//       if (lastTime.year == ntpTime.year &&
//           lastTime.month == ntpTime.month &&
//           lastTime.day == ntpTime.day &&
//           lastTime.hour == ntpTime.hour &&
//           lastTime.minute == ntpTime.minute) {
//         // Same minute
//         // Navigator.of(context).pop();
//         buildAlertError(context, 'เกิดข้อผิดพลาด',
//                 'ไม่สามารถแสกนเข้าแสกนออกในนาทีเดียวกันได้')
//             .show();
//         return;
//       }
//     }

//     if (selectLocation != null) {
//       bool isCanGetLocation = true;

//       if (selectLocation!.needgps == "Y") {
//         isCanGetLocation = await getCurrentLocation();
//       }

//       if (isCanGetLocation) {
//         if (selectLocation!.needqrcode == "Y" && withTime) {
//           //Get QR Code only when scan with time
//           if (kIsWeb) {
//             qrcode = await Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => const ScanQrCodePage()));
//           } else {
//             qrcode = await Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => QrCodeScannerWidget.defaultStyle()));
//           }
//         }
//         if (kDebugMode) {
//           print("qrcode: $qrcode");
//           //print(Navigator.of(context).((ScanScreen.id) => false));
//         }

//         if (selectLocation!.needcameraimg == "Y" && withTime) {
//           //   // Get QR Code only when scan with time
//           //   XFile pickedFile = await _picker.pickImage(source: ImageSource.camera);
//           //   if (pickedFile == null) {
//           //     Navigator.of(context).pop();
//           //     buildAlertError(
//           //             context, 'เกิดข้อผิดพลาด', 'กรุณาถ่ายภาพเพื่อทำการแสกน')
//           //         .show();
//           //     return;
//           //   } else {
//           //     imgFromForceCamera = File(pickedFile.path);
//           //     typeFromForceCamera =
//           //         path.extension(imgFromForceCamera.path).substring(1);
//           //     dataFromForceCamera = await FlutterImageCompress.compressWithFile(
//           //       imgFromForceCamera.absolute.path,
//           //       minWidth: 2300,
//           //       minHeight: 1500,
//           //       quality: 94,
//           //       rotate: 90,
//           //     ); //file.readAsBytesSync();
//           //   }
//         }

//         String attachfiletype = '';
//         if (attachedFile != null) {
//           if (kIsWeb) {
//             attachfiletype =
//                 lookupMimeType('', headerBytes: attachedFile) ?? "";
//             if (attachfiletype.isNotEmpty) {
//               attachfiletype = attachfiletype.split('/')[1];
//             }
//           } else if (path.extension(attachedFile.path).isNotEmpty) {
//             attachfiletype = path.extension(attachedFile.path).substring(1);
//           }
//         }

//         showAlertLoading(context);
//         var result = await scanService.checkIn(
//             profile: profile!,
//             latitude: position == null ? 0 : (position as Position).latitude,
//             longitude: position == null ? 0 : (position as Position).longitude,
//             qrcode: qrcode,
//             locationid: locationid,
//             routerssid: wifiName,
//             routerip: routerIP,
//             typescan: typescan,
//             isactive: withTime ? 'Y' : 'N',
//             attachfile: attachedFile != null
//                 ? convert.base64Encode(
//                     kIsWeb ? attachedFile : (await attachedFile.readAsBytes()))
//                 : null,
//             attachfiletype: attachfiletype,
//             attachcameraimg: null, //convert.base64Encode(dataFromForceCamera),
//             attachcameraimgtype: null); //typeFromForceCamera);

//         Navigator.pop(context);
//         if (result != null && result.flag == true) {
//           print('ลงเวลาสำเร็จ');
//           print(result.message);
//           //Navigator.pop(context);
//           scanCheckInAlert(typeCheck: 'สแกนเวลา$typeScan');

//           getHistoryScan();
//           await getTypeScan();

//           setState(() {
//             attachFileController.text = "";
//             attachedFile = null;
//           });
//           //Navigator.popAndPushNamed(context, '/' + Dashboard.id);
//         } else {
//           print('ลงเวลาไม่สำเร็จ');
//           if (result != null) {
//             print(result.message);
//           }
//           //Navigator.pop(context);
//           buildAlertError(context, 'ลงเวลา$typeScanไม่สำเร็จ',
//                   result == null ? '' : result.message)
//               .show();
//         }
//       } else {
//         buildAlertError(context, '', 'ลงเวลา$typeScanไม่สำเร็จ').show();
//       }
//     }
//   }

  getHistoryScan() async {
    HistoryService historyService = HistoryService();
    historyList = await historyService.getScanHistory(profile: profile!);
    if (historyList.isNotEmpty) historyList = historyList.reversed.toList();
    if (mounted) {
      setState(() {
        historyList = historyList;
      });
    }
  }

  getLocation(Position? position) async {
    LocationService locationService = LocationService();
    locationList = await locationService.getLocation(
      profile: profile!,
      latitude: position == null ? 0 : position.latitude,
      longitude: position == null ? 0 : position.longitude,
    );

    //Prevent setState after disposed
    if (mounted) {
      setState(() {
        locationList = locationList;
        isLoadingLocation = false;
      });
    }
  }

  getCurrentLocation() async {
    String resultText = "";
    bool result = true;

    try {
      position = await UtilService.getCurrentLocation(profile);
    } catch (e) {
      resultText = e.toString();
      print(resultText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black54,
          content: Text(UtilService.getTextFromLang("unable_request_location",
              "ไม่สามารถหา Location ปัจจุบันของคุณได้")),
        ),
      );

      result = false;
    }

    getLocation(position);

    if (mounted) {
      setState(() {
        isLoading = false;
        position = position;
      });
    }

    return result;
  }

//   setSelectedLocation(int val) {
//     print("Radio Tile pressed $val");
//     setState(() {
//       locationid = val;
//       print(convert.jsonEncode(selectLocation));
//     });
//   }

  getTypeScan() async {
    TypeScan typeScanClass = TypeScan();
    typeScan = await typeScanClass.getTypeScan(profile: profile!);

    if (mounted) {
      setState(() {
        typeScan = typeScan;
      });
    }
  }

//   scanCheckInAlert({required String typeCheck}) {
//     var timeNow = DateFormat('hh:mm').format(DateTime.now());
//     Alert(
//       style: const AlertStyle(
//           isCloseButton: false,
//           animationType: AnimationType.grow,
//           isOverlayTapDismiss: false),
//       context: context,
//       type: AlertType.success,
//       title: typeCheck,
//       desc: '$dateNow \n $timeNow \n สำเร็จ',
//       buttons: [
//         DialogButton(
//           color: const Color(0xFFFF8101),
//           onPressed: () => Navigator.pop(context),
//           width: 120,
//           child: const Text(
//             "ตกลง",
//             style: TextStyle(color: Colors.white, fontSize: 20),
//           ),
//         )
//       ],
//     ).show();
//   }

//   showAlertLoading(BuildContext context) {
//     AlertDialog alert = AlertDialog(
//       content: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(),
//           const SizedBox(
//             width: 10,
//           ),
//           Container(
//               margin: const EdgeInsets.only(left: 5),
//               child: const Text("กำลังบันทึกเวลา")),
//         ],
//       ),
//     );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   showScanWithoutTimeAlertDialog() {
//     return showDialog<void>(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: const Text(
//                 'เมื่อใช้แสกนไม่ลงเวลา โปรแกรมจะยังไม่นำเวลาแสกนไปคำนวณเป็นเวลาทำงาน กรุณาขอปรับเวลาเข้าออกงานในภายหลังที่หน้าประวัติทำงาน เลือกวันที่แล้วกดปุ่มรายละเอียดแสกน แล้วเลือกกดขอปรับเวลาเข้าออกงานของรายการแสกน'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   String tTypeScan;
//                   if (typeScan == 'I') {
//                     tTypeScan = 'เข้า';
//                   } else if (typeScan == 'O') {
//                     tTypeScan = 'ออก';
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         backgroundColor: Colors.black87,
//                         content: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text('Error'),
//                         ),
//                       ),
//                     );
//                     Navigator.of(context).pop();
//                     return;
//                   }

//                   onScan(
//                       typescan: typeScan, typeScan: tTypeScan, withTime: false);
//                 },
//                 child: const Text('ยอมรับ'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('ไม่ยอมรับ'),
//               ),
//             ],
//           );
//         });
//   }
// }

// class ButtonWidget extends StatelessWidget {
//   const ButtonWidget({
//     Key? key,
//     required this.title,
//     required this.onPressed,
//     required this.icon,
//     required this.color,
//   }) : super(key: key);
//   final String title;
//   final void Function()? onPressed;
//   final IconData icon;
//   final Color color;
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: ElevatedButton.icon(
//         icon: icon != null ? Icon(icon) : const Text(''),
//         label: Text(title,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           foregroundColor: Colors.white,
//           backgroundColor: color,
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30.0),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LocationWidget extends StatelessWidget {
//   final String? caption;
//   final bool needGps;
//   final bool needWifi;
//   final bool needQrCode;
//   final bool checkGps;
//   final bool checkWifi;
//   final bool checkQrCode;
//   final Color? bgColor;
//   final void Function()? onTap;

//   LocationWidget({super.key, Location? location, this.bgColor, this.onTap})
//       : caption = location != null ? location.locationcaption : '',
//         needGps = location != null ? location.needgps == "Y" : false,
//         needWifi = location != null ? location.needwifi == "Y" : false,
//         needQrCode = location != null ? location.needqrcode == "Y" : false,
//         checkGps = location != null ? location.checkgps == "Y" : false,
//         checkWifi = location != null ? location.checkwifi == "Y" : false,
//         checkQrCode = location != null ? location.checkqrcode == "Y" : false;

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> children = [
//       Expanded(
//         child: Text(
//           caption ?? "",
//           style: const TextStyle(fontSize: 14),
//         ),
//       ),
//     ];
//     if (checkGps) {
//       children.add(const SizedBox(
//         width: 5,
//       ));
//       children.add(const Icon(
//         Icons.location_pin,
//         color: Color(0xFFFF8101),
//       ));
//     }
//     if (checkWifi) {
//       children.add(const SizedBox(
//         width: 5,
//       ));
//       children.add(const Icon(
//         Icons.wifi,
//         color: Color(0xFFFF8101),
//       ));
//     }
//     if (checkQrCode) {
//       children.add(const SizedBox(
//         width: 5,
//       ));
//       children.add(const Icon(
//         Icons.qr_code_scanner,
//         color: Color(0xFFFF8101),
//       ));
//     }
//     return InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(4, 15, 10, 15),
//           color: bgColor,
//           child: Row(
//             children: children,
//           ),
//         ));
//   }
}
