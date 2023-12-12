import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../pages/Report/report_absent_page.dart';
import '../pages/Report/salary_slip_page.dart';
import '../services/util_service.dart';
// import '../pages/Report/salary_slip_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, required this.profile}) : super(key: key);

  final Profile profile;
  @override
  State<StatefulWidget> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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
            UtilService.getTextFromLang("document", 'เอกสาร/รายงาน'),
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
                    UtilService.getTextFromLang("payslip", 'ใบรับรองเงินเดือน'),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_sharp),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            SalarySlipPage(profile: widget.profile)));
                  },
                  leading: const Icon(
                    Icons.summarize,
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
                    UtilService.getTextFromLang(
                        "rpt_missing_absent_late", 'รายงาน ขาด/ลา/สาย'),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_sharp),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ReportAbsentPage(profile: widget.profile)));
                  },
                  leading: const Icon(
                    Icons.receipt_long,
                    // color: Colors.orange[500],
                    color: Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // GestureDetector createMenu(
  //     {String? caption, IconData? icon, void Function()? ontab}) {
  //   return GestureDetector(
  //     onTap: ontab,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.5),
  //             spreadRadius: 2,
  //             blurRadius: 2,
  //             offset: const Offset(1, 1), // changes position of shadow
  //           ),
  //         ],
  //       ),
  //       padding: const EdgeInsets.all(10),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           Icon(
  //             icon,
  //             color: Colors.orange[500],
  //             size: 40,
  //           ), // icon
  //           Text(
  //             caption ?? "",
  //             style: const TextStyle(
  //                 color: Colors.black54,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14),
  //           ), // text
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
