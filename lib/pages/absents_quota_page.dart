import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/constant.dart';
import '../models/GetAbsentQuotaModel.dart';
import '../models/profile.dart';
import '../services/get_absent_quota_service.dart';
import '../services/util_service.dart';

class AbsentsQuotaPage extends StatefulWidget {
  const AbsentsQuotaPage({Key? key, required this.profile}) : super(key: key);
  final Profile profile;
  @override
  _AbsentsQuotaPageState createState() => _AbsentsQuotaPageState();
}

class _AbsentsQuotaPageState extends State<AbsentsQuotaPage> {
  var _selectedYear = DateTime.now().year;
  List<AbsentQuota> absentQuotaList = [];
  bool isLoading = false;

  @override
  void initState() {
    _selectedYear = DateTime.now().year;
    getData(_selectedYear);
    super.initState();
  }

  getData(selectedDate) async {
    setState(() {
      isLoading = true;
    });

    GetAbsentQuotaService getAbsentQuotaService =
        GetAbsentQuotaService(profile: widget.profile);
    absentQuotaList = await getAbsentQuotaService.getData(
        profile: widget.profile, selectedYear: selectedDate);

    if (absentQuotaList.isNotEmpty) {
      setState(() {
        isLoading = false;
        absentQuotaList = absentQuotaList;
      });
    } else {
      alertEmpty('ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Mobile',
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFF8101),
          title: Text(
            UtilService.getTextFromLang("absentquota", "สิทธิ์การลา"),
            style: TextStyle(color: Colors.white, fontFamily: fontFamilyCustom),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10.0,
              ),
              // const Center(
              //   child: Text(
              //     'สิทธิ์การลา',
              //     style: TextStyle(
              //       fontSize: 18.0,
              //     ),
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _selectedYear = _selectedYear - 1;
                        getData(_selectedYear);
                      });
                    },
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Select Year"),
                            content: SizedBox(
                              width: 300,
                              height: 300,
                              child: YearPicker(
                                firstDate:
                                    DateTime(DateTime.now().year - 100, 1),
                                lastDate:
                                    DateTime(DateTime.now().year + 100, 1),
                                initialDate: DateTime.now(),
                                selectedDate: DateTime.now(),
                                onChanged: (DateTime dateTime) {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedYear = dateTime.year;
                                    getData(_selectedYear);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      child: Text(
                        _selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _selectedYear = _selectedYear + 1;
                        getData(_selectedYear);
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      )
                    : ListView.builder(
                        itemCount: absentQuotaList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return createAbsentQuotaItem(absentQuotaList[index]);
                        },
                      ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: ElevatedButton(
              //     child: Container(
              //       padding: EdgeInsets.symmetric(
              //         horizontal: 30.0,
              //       ),
              //       child: Text(
              //         'ปิด',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //     ),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     style: ElevatedButton.styleFrom(
              //       primary: Color(0xFFFF8101),
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 15, vertical: 15),
              //       onPrimary: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30.0),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createAbsentQuotaItem(AbsentQuota quota) {
    //print(quota.absenttypename + " : " + quota.absentspent.toString());

    String quotaString = '';
    int quotaSpentDay = (quota.absentspent ?? 0).floor();
    double quotaSpentHour = (((quota.absentspent ?? 0) - quotaSpentDay) * 8);
    quotaString = '$quotaString$quotaSpentDay ' +
        UtilService.getTextFromLang("days", "วัน");
    if (quotaSpentHour > 0) {
      quotaString = '$quotaString ${quotaSpentHour.floor()} ชม.';
    }

    int quotaAllDay = (quota.absentquota ?? 0).floor();
    double quotaAllHour = (((quota.absentquota ?? 0) - quotaAllDay) * 8);
    quotaString = quotaString +
        ' / ' +
        quotaAllDay.toString() +
        UtilService.getTextFromLang("days", "วัน");
    if (quotaAllHour > 0) {
      quotaString = '$quotaString ${quotaAllHour.floor()} ชม.';
    }

    return InkWell(
      // onTap: () {
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => AbsentPage(
      //             profile: widget.profile,
      //             lockAbsentType: quota.absenttypeid,
      //             lockAbsentYear: _selectedYear,
      //           )));
      // },
      child: Column(
        children: [
          ListTile(
            title: Text(quota.absenttypename ?? ""),
            trailing: Text(quotaString),
          ),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                width: MediaQuery.of(context).size.width - 50,
                child: LinearProgressIndicator(
                  value: quota.absentquota == 0.0
                      ? 0.0
                      : (quota.absentspent ?? 0) / (quota.absentquota ?? 1),
                  semanticsLabel: 'Linear progress indicator',
                  backgroundColor: Colors.grey,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  alertEmpty(title) {
    Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.warning,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () => Navigator.pop(context, true),
          // onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }
}
