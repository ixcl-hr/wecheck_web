import 'dart:typed_data';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../../models/GetConatctInfoModel.dart';
import '../../models/profile.dart';
import '../../services/get_contact_info_service.dart';
import '../../services/util_service.dart';

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({Key? key, required this.profile, this.title})
      : super(key: key);
  final Profile profile;
  final String? title;
  @override
  ContactInfoPageState createState() => ContactInfoPageState();
}

class ContactInfoPageState extends State<ContactInfoPage> {
  bool isLoading = false;
  Uint8List? bytesImage;
  bool isHasImage = false;

  List<ContactInfo> contactInfo = [];

  @override
  void initState() {
    getData(widget.profile);

    setState(() {
      String? imgString = widget.profile.employeepicture;

      if (imgString != null) {
        isHasImage = true;
        bytesImage = const convert.Base64Decoder().convert(imgString);
      } else {
        isHasImage = false;
      }
    });

    super.initState();
  }

  getData(Profile profile) async {
    setState(() {
      isLoading = true;
    });

    GetContactInfoService getContactInfoService =
        GetContactInfoService(profile: widget.profile);
    contactInfo = await getContactInfoService.getData(profile: widget.profile);

    if (contactInfo != null) {
      setState(() {
        isLoading = false;
        contactInfo = contactInfo;
      });
    } else {
      UtilService.alertEmpty(context, 'ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8101),
        title: Text(
          widget.title ?? '',
          style: TextStyle(color: Colors.white, fontFamily: fontFamilyCustom),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            !isHasImage || bytesImage == null
                ? const CircleAvatar(
                    minRadius: 25,
                    maxRadius: 40,
                    backgroundImage: AssetImage('assets/images/unknown.jpeg'),
                    backgroundColor: Colors.transparent,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: MemoryImage(bytesImage!)),
                    ),
                  ),
            Expanded(
                child: Center(
                    child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white, // Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(1, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Column(children: <Widget>[
                    buildUserInfoDisplay(
                        contactInfo.isNotEmpty ? contactInfo[0].email! : '-',
                        'Email',
                        null),
                    buildUserInfoDisplay(
                        contactInfo.isNotEmpty
                            ? '${contactInfo[0].addressLine1 ?? ''}\r\n${contactInfo[0].addressLine2 ?? ''}\r\n${contactInfo[0].provinceName ?? ''}\r\n${contactInfo[0].zipcode ?? ''}'
                            : '',
                        UtilService.getTextFromLang("address", "ที่อยู่"),
                        null),
                  ])),
            ))),
          ],
        ),
      ),
    );
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(
          String getValue, String title, Widget? editPage) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Container(
                  width: 350,
                  // height: 40,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ))),
                  child: Row(children: [
                    Expanded(
                        // child: TextButton(
                        //     onPressed: () {
                        //       navigateSecondPage(editPage);
                        //     },
                        child: Text(
                      getValue,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 16, height: 1.4),
                    )),
                    //),
                    // const Icon(
                    //   Icons.keyboard_arrow_right,
                    //   color: Colors.grey,
                    //   size: 40.0,
                    // )
                  ]))
            ],
          ));
}
