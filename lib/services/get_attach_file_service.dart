import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:path/path.dart';
import '../models/profile.dart';

class GetAttachFileService {
  getAttachFile(Profile profile, payload, context) async {
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    String url = '${ApiMaster}GetAttachFile';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    var feedback = convert.jsonDecode(response.body);
    print('GetAttachFile');
    print(response.body);

    if (response.statusCode == 200) {
      if (feedback['flag'] == true) {
        String attachFileUrl = feedback['objectresult'];
        if (attachFileUrl.isNotEmpty) {
          // Download file
          http.Response res = await http.get(Uri.parse(attachFileUrl));

          Directory directory = await getTemporaryDirectory();
          String savePath = '${directory.path}/${basename(attachFileUrl)}';
          File file = File(savePath);
          await file.writeAsBytes(res.bodyBytes);
          Navigator.of(context).pop();
          OpenFilex.open(savePath);
        } else {
          createAlertDialog(context, 'ไม่สามารถดาวน์โหลดไฟล์แนบ').show();
        }
      } else {
        print(feedback['message']);
        createAlertDialog(
                context, feedback['message'] ?? 'ไม่สามารถดาวน์โหลดไฟล์แนบ')
            .show();
      }
    } else {
      print(feedback['approverid']);
      createAlertDialog(context, 'ไม่สามารถดาวน์โหลดไฟล์แนบ').show();
    }
  }

  Alert createAlertDialog(BuildContext context, String title) {
    return Alert(
      style: const AlertStyle(
        isCloseButton: false,
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
      ),
      context: context,
      type: AlertType.error,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }
}
