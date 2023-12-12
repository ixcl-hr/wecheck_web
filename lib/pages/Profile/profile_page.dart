import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../pages/Profile/contact_info_page.dart';
import '../../pages/Profile/personal_detail_page.dart';
import '../../services/util_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.profile}) : super(key: key);

  final Profile profile;
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  initPrefs() async {}

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = const BorderRadius.only(
        topRight: Radius.circular(32), bottomRight: Radius.circular(32));
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF8101),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            UtilService.getTextFromLang("profile", "ข้อมูลส่วนตัว"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              ListTile(
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  title: Text(
                    UtilService.getTextFromLang("profile", "ข้อมูลส่วนบุคคล"),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_sharp),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PersonalDetailPage(
                              profile: widget.profile,
                              title: UtilService.getTextFromLang(
                                  "profile", "ข้อมูลส่วนบุคคล"),
                            )));
                  },
                  leading: const Icon(
                    Icons.person_pin_rounded,
                    color: Colors.black,
                  )),
              const Divider(
                height: 20,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.grey,
              ),
              ListTile(
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  title: Text(
                    UtilService.getTextFromLang("contact", "ข้อมูลติดต่อ"),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_sharp),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ContactInfoPage(
                              profile: widget.profile,
                              title: UtilService.getTextFromLang(
                                  "contact", "ข้อมูลติดต่อ"),
                            )));
                  },
                  leading: const Icon(
                    Icons.home_work,
                    // color: Colors.orange[500],
                    color: Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
