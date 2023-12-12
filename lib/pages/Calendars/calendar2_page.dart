import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart';
import '../../models/GetWorkHistoryModel.dart';
import '../../pages/Calendars/calendar_detail_page.dart';
import '../../services/get_work_history_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../services/util_service.dart';

class Calendar2Page extends StatefulWidget {
  final profile;

  const Calendar2Page({Key? key, this.profile}) : super(key: key);
  @override
  _Calendar2PageState createState() => _Calendar2PageState();
}

class _Calendar2PageState extends State<Calendar2Page> {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _currentDate2 =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  int? _lastDayOfMonth;
  final EventList<Event> _scanDateMap = EventList<Event>(
    events: {},
  );

  CalendarCarousel? _calendarCarouselNoHeader;

  var len = min(absentDates.length, workDates.length);
  double cHeight = 0;

  @override
  void initState() {
    initDayAndMonth(DateTime.now());
    super.initState();
  }

  List<WorkHistory> workHistoryList = [];
  bool isLoading = false;
  String dateSelectedLabel = '';

  initDayAndMonth(DateTime daySelect) {
    //DateTime today = DateTime.now();

    // if (daySelect.compareTo(today) > 0) {
    //   daySelect = today;
    // }

    var firstDateConvert = daySelect.toString().substring(0, 10).split('-');
    firstDateConvert[2] = "1";
    var firstDate = List.from(firstDateConvert.reversed).join('/');
    print("_firstDate : $firstDate");

    DateTime lastDateOfNextMonthSelect = DateTime(
        daySelect.year,
        daySelect.month + 1,
        DateTime(daySelect.year, daySelect.month + 1, 0).day);
    // if (lastDateOfNextMonthSelect.compareTo(today) > 0) {
    //   lastDateOfNextMonthSelect = today;
    // }

    var dateLastConvert =
        lastDateOfNextMonthSelect.toString().substring(0, 10).split('-');
    var lastDate = List.from(dateLastConvert.reversed).join('/');
    print("_lastDate : $lastDate");

    getData(firstDate, lastDate);
  }

  getData(firstDate, lastDate) async {
    setState(() {
      isLoading = true;
    });

    GetWorkHistoryService getWorkHistoryService = GetWorkHistoryService();
    workHistoryList = await getWorkHistoryService.getData(
        profile: widget.profile, firstDay: firstDate, lastDay: lastDate);

    setState(() {
      isLoading = false;
      workHistoryList = workHistoryList;
    });

    if (workHistoryList.isEmpty) {
      // alertEmpty('Working List Null');
      return;
    }
    filterDataByDate(_currentDate2.toString());
    initDataToCalendar();
  }

  String convertDateLabel(String date) {
    if (date.isEmpty) {
      return '-';
    } else {
      var date0 = date.toString().substring(0, 10).split('-');
      return List.from(date0.reversed).join('/');
    }
  }

  String convertTimeLabel(String time) {
    return time.isEmpty ? '' : time.toString().substring(0, 5);
  }

  List<WorkHistory> listDateSelected = [];

  filterDataByDate(String dateSelected) {
    //print('dateSelected $dateSelected');
    var dateSelectedSpit =
        dateSelected.substring(0, dateSelected.length - 4).split(" ");
    dateSelectedSpit[1] = "00:00:00";
    var dateSelectConvertForUserFilter = List.from(dateSelectedSpit).join("T");
    //print('dateSelectConvertForUserFilter $dateSelectConvertForUserFilter');

    var dateSelectConvert = dateSelected.substring(0, 10).split('-');
    var selectDate = List.from(dateSelectConvert.reversed).join('/');
    //print("dateSelectedLabel : $_selectDate");
    setState(() {
      dateSelectedLabel = selectDate;
    });

    if (workHistoryList.isEmpty) {
      workType1Scan = [];
      workType2OT = [];
      workType3Absent = [];
      workType4Miss = [];
      return;
    }
    listDateSelected = workHistoryList
        .where((element) => element.workdate == dateSelectConvertForUserFilter)
        .toList();

    // listDateSelected.forEach((element) {
    //   print('${element.workdate}  ${element.worktype}  ${element.absenttype}');
    // });

    groupWorkType(listDateSelected);
  }

  List<WorkHistory> workType1Scan = [];
  List<WorkHistory> workType2OT = [];
  List<WorkHistory> workType3Absent = [];
  List<WorkHistory> workType4Miss = [];
  groupWorkType(List<WorkHistory> listDateSelected) {
    workType1Scan =
        listDateSelected.where((element) => element.worktype == 1).toList();
    //print(convert.jsonEncode(workType1Scan));
    workType2OT =
        listDateSelected.where((element) => element.worktype == 2).toList();
    //print(convert.jsonEncode(workType2OT));
    workType3Absent =
        listDateSelected.where((element) => element.worktype == 3).toList();
    //print(convert.jsonEncode(workType3Absent));
    workType4Miss =
        listDateSelected.where((element) => element.worktype == 4).toList();
    //print('>>>>>> miss list${convert.jsonEncode(workType4Miss)}');
  }

  initDataToCalendar() {
    if (workHistoryList.isEmpty) {
      return;
    }

    for (var element in workHistoryList) {
      if (element.worktype == 3) {
        var parsedDate = DateTime.parse(element.workdate ?? "");
        _scanDateMap.add(
          parsedDate,
          Event(
            date: parsedDate,
            title: 'Event ลางาน  ${element.worktype}',
            icon: _absentIcon(
              parsedDate.day.toString(),
            ),
          ),
        );
      }

      if (element.worktype == 4) {
        var parsedDate = DateTime.parse(element.workdate ?? "");
        _scanDateMap.add(
          parsedDate,
          Event(
            date: parsedDate,
            title: 'Event ขาดงาน ${element.worktype}',
            icon: _missIcon(
              parsedDate.day.toString(),
            ),
          ),
        );
      }

      if (element.worktype == 2) {
        var parsedDate = DateTime.parse(element.workdate ?? "");
        _scanDateMap.add(
          parsedDate,
          Event(
            date: parsedDate,
            title: 'Event ทำล่วงเวลา ${element.worktype}',
            icon: _oTIcon(
              parsedDate.day.toString(),
            ),
          ),
        );
      }
      if (element.worktype == 1) {
        var parsedDate = DateTime.parse(element.workdate ?? "");
        _scanDateMap.add(
          parsedDate,
          Event(
            date: parsedDate,
            title: 'Event ทำงานปกติ ${element.worktype}',
            icon: _workIcon(
              parsedDate.day.toString(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      height: 390.0,
      weekendTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      isScrollable: false,
      headerMargin: const EdgeInsets.all(5),
      daysHaveCircularBorder: true,
      todayButtonColor: Colors.transparent,
      todayTextStyle:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
      todayBorderColor: Colors.grey,
      selectedDayButtonColor: Colors.orange,
      selectedDayBorderColor: Colors.black,
      selectedDayTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      // markedDatesMap: _markedDateMap,
      markedDatesMap: _scanDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      selectedDateTime: _currentDate2,
      onDayPressed: (DateTime date, List<Event> events) {
        //print('press date =>  $date');
        filterDataByDate(date.toString());
        setState(() => _currentDate2 = date);
      },
      onDayLongPressed: (DateTime date) {
        // print('long pressed date $date');
      },
      targetDateTime: _currentDate2,
      // onCalendarChanged: (DateTime date) {
      //   this.setState(() {
      //     _targetDateTime = date;
      //     print('_targetDateTime $_targetDateTime');
      //
      //     _currentMonth = DateFormat.yMMM().format(_targetDateTime);
      //     print('เดือน : $_currentMonth');
      //
      //     initDayAndMonth(_targetDateTime);
      //   });
      // },
      onLeftArrowPressed: () {
        //print('===>>>>> onLeftArrowPressed');
        setState(() {
          _targetDateTime =
              DateTime(_targetDateTime.year, _targetDateTime.month, 0);
          _currentDate2 = _targetDateTime;
          initDayAndMonth(_currentDate2);
          filterDataByDate(_currentDate2.toString());
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onRightArrowPressed: () {
        //print('===>>>>> onRightArrowPressed');
        setState(() {
          _targetDateTime =
              DateTime(_targetDateTime.year, _targetDateTime.month + 1);
          _currentDate2 = _targetDateTime;
          initDayAndMonth(_currentDate2);
          filterDataByDate(_currentDate2.toString());
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      markedDateMoreShowTotal:
          null, // null for not showing hidden events indicator
      markedDateIconBuilder: (event) {
        //print("event: " + event.date.toString());
        if (today.compareTo(event.date) > 0) return event.icon;
        return null;
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          UtilService.getTextFromLang("timehistory", "ประวัติลงเวลา"),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: const [
          // IconButton(
          //   icon: Icon(Icons.access_alarm_outlined),
          //   onPressed: () {
          //     oTDates = oTDates2;
          //     initDataToCalendar();
          //     setState(() {
          //       _scanDateMap = _scanDateMap;
          //     });
          //     DateTime now = DateTime.now();
          //     int _lastDay = DateTime(now.year, now.month + 1, 0).day;
          //     print("Last day in month : $_lastDay");
          //     print("_currentMonth : $_currentMonth");
          //
          //   },
          // )
        ],
      ),
      bottomNavigationBar: buildBottomButton(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      // AspectRatio(
                      //   aspectRatio: 4 / 4.3,
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //     child: _calendarCarouselNoHeader,
                      //   ),
                      // ),
                      Container(
                        child: _calendarCarouselNoHeader,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            markerRepresent(
                                Colors.lightBlueAccent,
                                UtilService.getTextFromLang(
                                    "present", "ทำงาน")),
                            markerRepresent(Colors.yellow,
                                UtilService.getTextFromLang("ot", "ทำโอที")),
                            markerRepresent(Colors.lightGreenAccent,
                                UtilService.getTextFromLang("absent", "ลางาน")),
                            markerRepresent(
                                Colors.redAccent,
                                UtilService.getTextFromLang(
                                    "missing", "ขาดงาน")),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            color: Colors.black87,
                          ),
                          child: Text(
                            UtilService.getTextFromLang("date", "วันที่") +
                                ' $dateSelectedLabel',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Column(
                            children: [
                              workType1Scan.isEmpty
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            UtilService.getTextFromLang(
                                                "timeshift", "เวลาตามกะงาน"),
                                            style: TextStyle(fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 0, 0, 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' ${convertTimeLabel(workType1Scan[0].wsstarttime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      workType1Scan.isEmpty ||
                                                              workType1Scan[0]
                                                                      .wsstarttime2 ==
                                                                  null
                                                          ? ''
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' ${convertTimeLabel(workType1Scan[0].wsstarttime2 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' ${convertTimeLabel(workType1Scan[0].wsendtime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      workType1Scan.isEmpty ||
                                                              workType1Scan[0]
                                                                      .wsendtime2 ==
                                                                  null
                                                          ? ''
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' ${convertTimeLabel(workType1Scan[0].wsendtime2 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                            UtilService.getTextFromLang(
                                                "working", "ทำงานปกติ"),
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 0, 0, 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' ${convertDateLabel(workType1Scan[0].startdate1 ?? "")} ${convertTimeLabel(workType1Scan[0].starttime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "in",
                                                                      "เข้า") +
                                                              ' ${convertDateLabel(workType1Scan[0].startdate2 ?? "")} ${convertTimeLabel(workType1Scan[0].starttime2 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' ${convertDateLabel(workType1Scan[0].enddate1 ?? "")} ${convertTimeLabel(workType1Scan[0].endtime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      workType1Scan.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "out",
                                                                      "ออก") +
                                                              ' ${convertDateLabel(workType1Scan[0].enddate2 ?? "")} ${convertTimeLabel(workType1Scan[0].endtime2 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                              workType2OT.isEmpty
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            UtilService.getTextFromLang(
                                                "ot", "ทำล่วงเวลา"),
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 0, 0, 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType2OT.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "start",
                                                                      "เริ่ม") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "start",
                                                                      "เริ่ม") +
                                                              ' ${convertDateLabel(workType2OT[0].startdate1 ?? "")} ${convertTimeLabel(workType2OT[0].starttime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType2OT.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "end",
                                                                      "สิ้นสุด") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "end",
                                                                      "สิ้นสุด") +
                                                              ' ${convertDateLabel(workType2OT[0].enddate1 ?? "")} ${convertTimeLabel(workType2OT[0].endtime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                              workType3Absent.isEmpty
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${workType3Absent[0].absenttype}',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 0, 0, 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType3Absent.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "start",
                                                                      "เริ่ม") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "start",
                                                                      "เริ่ม") +
                                                              ' ${convertDateLabel(workType3Absent[0].startdate1 ?? "")} ${convertTimeLabel(workType3Absent[0].starttime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workType3Absent.isEmpty
                                                          ? UtilService
                                                                  .getTextFromLang(
                                                                      "end",
                                                                      "สิ้นสุด") +
                                                              ' -'
                                                          : UtilService
                                                                  .getTextFromLang(
                                                                      "end",
                                                                      "สิ้นสุด") +
                                                              ' ${convertDateLabel(workType3Absent[0].enddate1 ?? "")} ${convertTimeLabel(workType3Absent[0].endtime1 ?? "")}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                              workType4Miss.isEmpty || workType1Scan.isNotEmpty
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Text(
                                              UtilService.getTextFromLang(
                                                  "timeshift", "เวลาตามกะงาน"),
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 0, 0, 6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        workType4Miss.isEmpty
                                                            ? ''
                                                            : UtilService
                                                                    .getTextFromLang(
                                                                        "in",
                                                                        "เข้า") +
                                                                ' ${convertTimeLabel(workType4Miss[0].wsstarttime1 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        workType4Miss.isEmpty ||
                                                                workType4Miss[0]
                                                                        .wsstarttime2 ==
                                                                    null
                                                            ? ''
                                                            : UtilService
                                                                    .getTextFromLang(
                                                                        "in",
                                                                        "เข้า") +
                                                                ' ${convertTimeLabel(workType4Miss[0].wsstarttime2 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        workType4Miss.isEmpty
                                                            ? ''
                                                            : UtilService
                                                                    .getTextFromLang(
                                                                        "out",
                                                                        "ออก") +
                                                                ' ${convertTimeLabel(workType4Miss[0].wsendtime1 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        workType4Miss.isEmpty ||
                                                                workType4Miss[0]
                                                                        .wsendtime2 ==
                                                                    null
                                                            ? ''
                                                            : UtilService
                                                                    .getTextFromLang(
                                                                        "out",
                                                                        "ออก") +
                                                                ' ${convertTimeLabel(workType4Miss[0].wsendtime2 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ]),
                              workType4Miss.isEmpty ||
                                      today.compareTo(DateTime.parse(
                                              workType4Miss[0].workdate ??
                                                  "")) <=
                                          0
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            UtilService.getTextFromLang(
                                                "missing", "ขาดงาน"),
                                            style: TextStyle(fontSize: 16)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 0, 0, 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        workType4Miss.isEmpty
                                                            ? '- ' +
                                                                UtilService
                                                                    .getTextFromLang(
                                                                        "hour_short_type",
                                                                        "ชม.")
                                                            : '${workType4Miss[0].missinghour} ' +
                                                                UtilService
                                                                    .getTextFromLang(
                                                                        "hour_short_type",
                                                                        "ชม."),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget markerRepresent(Color color, String data) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundColor: color,
            radius: cHeight * 0.012,
          ),
        ),
        Text(
          data,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
    // return Flexible(
    //   child: ListTile(
    //     contentPadding: const EdgeInsets.all(0),
    //     // minLeadingWidth: 0,
    //     leading: CircleAvatar(
    //       backgroundColor: color,
    //       radius: cHeight * 0.022,
    //     ),
    //     title: Text(
    //       data,
    //       style: const TextStyle(
    //         fontSize: 16,
    //         fontWeight: FontWeight.bold,
    //         color: Colors.white,
    //       ),
    //     ),
    //   ),
    // );
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
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  Container buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWidget(
            title:
                UtilService.getTextFromLang("timework_detail", "รายละเอียดงาน"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarDetailPage(
                    dateSelected: dateSelectedLabel,
                    profile: widget.profile,
                  ),
                ),
              );
            },
            color: Colors.orange,
            icon: Icons.sticky_note_2_outlined,
          ),
        ],
      ),
    );
  }

  static Widget _workIcon(String day) => CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
  static Widget _absentIcon(String day) => CircleAvatar(
        backgroundColor: Colors.lightGreenAccent,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
  static Widget _oTIcon(String day) => CircleAvatar(
        backgroundColor: Colors.yellow,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
  static Widget _missIcon(String day) => CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.icon,
    required this.color,
  }) : super(key: key);
  final String title;
  final void Function() onPressed;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }
}

List<DateTime> workDates = [
  DateTime(2021, 2, 1),
  DateTime(2021, 2, 3),
  DateTime(2021, 2, 4),
  DateTime(2021, 2, 5),
  DateTime(2021, 2, 6),
  DateTime(2021, 2, 9),
];
List<DateTime> absentDates = [
  DateTime(2021, 2, 2),
  DateTime(2021, 2, 7),
  DateTime(2021, 2, 8),
  DateTime(2021, 2, 12),
  DateTime(2021, 2, 13),
];

List<DateTime> oTDates = [
  DateTime(2021, 2, 8),
  DateTime(2021, 2, 10),
  DateTime(2021, 2, 11),
  DateTime(2021, 2, 15),
  DateTime(2021, 2, 22),
  DateTime(2021, 2, 23),
];

List<DateTime> oTDates2 = [
  DateTime(2021, 2, 16),
  DateTime(2021, 2, 17),
  DateTime(2021, 2, 18),
  DateTime(2021, 2, 19),
  DateTime(2021, 2, 20),
  DateTime(2021, 2, 21),
];

// initDataMock() {
//   for (int i = 0; i < len; i++) {
//     _scanDateMap.add(
//       workDates[i],
//       new Event(
//         date: workDates[i],
//         title: 'Event presentDates ${workDates[i]}',
//         icon: _workIcon(
//           workDates[i].day.toString(),
//         ),
//       ),
//     );
//   }
//
//   for (int i = 0; i < len; i++) {
//     _scanDateMap.add(
//       absentDates[i],
//       new Event(
//         date: absentDates[i],
//         title: 'Event absentDates ${absentDates[i]}',
//         icon: _absentIcon(
//           absentDates[i].day.toString(),
//         ),
//       ),
//     );
//   }
//   for (int i = 0; i < len; i++) {
//     _scanDateMap.add(
//       oTDates[i],
//       new Event(
//         date: oTDates[i],
//         title: 'Event oTDates ${oTDates[i]}',
//         icon: _oTIcon(
//           oTDates[i].day.toString(),
//         ),
//       ),
//     );
//   }
// }
