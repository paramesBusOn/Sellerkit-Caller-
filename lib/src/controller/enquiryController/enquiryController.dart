// ignore_for_file: unnecessary_new, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sellerkitcalllog/helpers/constantApiUrl.dart';
import 'package:sellerkitcalllog/helpers/constantRoutes.dart';
import 'package:sellerkitcalllog/helpers/helper.dart';
import 'package:sellerkitcalllog/src/api/ItemCategoryApi.dart/ItemCategoryApi.dart';
import 'package:sellerkitcalllog/src/api/checkEnqDetailsApi/checkEnqDetailsApi.dart';
import 'package:sellerkitcalllog/src/api/customerTagApi/customerTagApi.dart';
import 'package:sellerkitcalllog/src/api/enqTypeApi/enqTypeApi.dart';
import 'package:sellerkitcalllog/src/api/enquiryPostApi/postEnqApi.dart';
import 'package:sellerkitcalllog/src/api/getCustomerApi/getCustomerApi.dart';
import 'package:sellerkitcalllog/src/api/getUserListApi/getUserListApi.dart';
import 'package:sellerkitcalllog/src/api/levelOfApi/levelOfApi.dart';
import 'package:sellerkitcalllog/src/api/ordertypeApi/ordertypeApi.dart';
import 'package:sellerkitcalllog/src/api/stateApi/stateApi.dart';
import 'package:sellerkitcalllog/src/dBHelper/dBHelper.dart';
import 'package:sellerkitcalllog/src/dBHelper/dBOperation.dart';
import 'package:sellerkitcalllog/src/pages/enquiries/widgets/warningDialof.dart';
import 'package:sellerkitcalllog/src/widgets/AlertDilog.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite/sqflite.dart';
import '../../../helpers/Configuration.dart';
import '../../../helpers/Utils.dart';
import '../../api/getRefferalApi/getRefferalApi.dart';

class NewEnqController extends ChangeNotifier {
  final formkey = GlobalKey<FormState>();
  List<TextEditingController> mycontroller =
      List.generate(25, (i) => TextEditingController());

  Config config = new Config();

  String isSelectedenquirytype = '';
  String get getisSelectedenquirytype => isSelectedenquirytype;

  String isSelectedenquiryReffers = '';
  String get getisSelectedenquiryReffers => isSelectedenquiryReffers;

  String isSelectedCsTag = '';
  String get getisSelectedCsTag => isSelectedCsTag;
  bool? sitevisitreq = false;
  bool? get getsitevisitreq => sitevisitreq;
  bool isText1Correct = false;

  String? hinttextforOpenLead = 'Select Interest*: '; //cl
  String? get gethinttextforOpenLead => hinttextforOpenLead;

  String? hinttextforcustype = 'Select Customer Type*: '; //cl
  String? get gethinttextforcustype => hinttextforcustype;
  List<UserListData> userLtData = [];
  List<UserListData> get getuserLtData => userLtData;
  List<UserListData> filteruserLtData = [];
  List<UserListData> get getfiltergetuserLtData => filteruserLtData;
  init() async {
    await getUserAssingData();

    await setdefaultUserName();
    await getEnqType();
    await getCusTagType();
    await getEnqRefferes();
    // await getDivisionValue();
    await mapValuesFormEnq();

    await stateApicallfromDB();
    await catagoryApi();
    await getLeveofType();
    notifyListeners();
  }

  selectEnqMeida(String selected, String enqtypecode) {
    isSelectedenquirytype = selected;
    EnqTypeCode = enqtypecode;
    notifyListeners();
  }

  bool visittimebool = false;
  bool visitDatebool = false;
  bool remindertimebool = false;
  bool reminderDatebool = false;
  clearbool() {
    mycontroller[14].clear();
    mycontroller[15].clear();
    visittimebool = false;
    visitDatebool = false;
    istimevalid = false;
    notifyListeners();
  }

  clearbool2() {
    mycontroller[16].clear();
    mycontroller[17].clear();
    remindertimebool = false;
    reminderDatebool = false;
    notifyListeners();
  }

//  List<FocusNode> focusNodes = List.generate(20, (index) => FocusNode());
  FocusNode focusNode1 = FocusNode();
  autovalidation(BuildContext context) {
    FocusScope.of(context).unfocus();

    methidstate(mycontroller[12].text);
    FocusScope.of(context).requestFocus(focusNode1);
    Future.microtask(() {
      statebool = false;
    });
  }

  String? apiNdate = '';
  String? apiFdate = '';
  bool checkdata = false;
  bool checkretime = false;
  getDate(BuildContext context) async {
    errorTime = "";

    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
//  firstDate: DateTime.now().subtract(Duration(days: 1)),
//   lastDate: DateTime(2100),
    if (pickedDate != null) {
      mycontroller[15].text = "";
      //  var date = DateTime.parse(pickedDate);
      apiNdate = pickedDate.toString();
      // apiNdate =
      //     "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      // print(apiNdate);
      var datetype = DateFormat('dd-MM-yyyy').format(pickedDate);
      mycontroller[14].text = datetype;
      if (mycontroller[16].text.isNotEmpty) {
        DateTime planPurDate;
        DateTime Nextfdate;
        log("apiNdate::" + apiNdate.toString());

        log("pickedDate::" + pickedDate.toString());
        planPurDate = DateTime.parse(pickedDate.toString());
        Nextfdate = DateTime.parse(apiFdate.toString());
        log("Nextfdate::" + Nextfdate.toString());
        log("planPurDate::" + planPurDate.toString());
        if (Nextfdate.isAfter(planPurDate)) {
          mycontroller[16].text = '';
          checkdata = true;
          notifyListeners();
        } else {
          checkdata = false;
          mycontroller[16].text = datetype;
          notifyListeners();
        }
        notifyListeners();
      }

      // mycontroller[44].text = datetype!;
      // print(datetype);
    } else {}
    notifyListeners();
  }

  getDate2(BuildContext context) async {
    log("sitevisitreq:::" + sitevisitreq.toString());
    errorTime = "";

    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
//  firstDate: DateTime.now().subtract(Duration(days: 1)),
//   lastDate: DateTime(2100),
    if (pickedDate != null) {
      mycontroller[17].text = "";
      apiFdate = pickedDate.toString();
      var datetype = DateFormat('dd-MM-yyyy').format(pickedDate);

      if (sitevisitreq == true || mycontroller[14].text.isNotEmpty) {
        DateTime planPurDate;
        DateTime Nextfdate;
        log("apiNdate::" + apiNdate.toString());

        log("pickedDate::" + pickedDate.toString());
        planPurDate = DateTime.parse(apiNdate!);
        Nextfdate = DateTime.parse(pickedDate.toString());
        log("Nextfdate::" + Nextfdate.toString());
        log("planPurDate::" + planPurDate.toString());
        if (Nextfdate.isAfter(planPurDate)) {
          mycontroller[16].text = '';
          checkdata = true;
          notifyListeners();
        } else {
          checkdata = false;
          mycontroller[16].text = datetype;
          reyear = pickedDate.year;
          remonth = pickedDate.month;
          reday = pickedDate.day;
          log("::" + reyear.toString());
          notifyListeners();
        }
      } else {
        mycontroller[16].text = datetype;
        reyear = pickedDate.year;
        remonth = pickedDate.month;
        reday = pickedDate.day;
        log("::" + reyear.toString());
        notifyListeners();
      }
    } else {}
    notifyListeners();
  }

  String errorTime2 = "";
  bool istimevalid = false;
  void selectTime2(BuildContext context) async {
    TimeOfDay timee = TimeOfDay.now();

    if (mycontroller[16].text.isNotEmpty) {
      errorTime2 = "";
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: timee,
      );
      // if (mycontroller[10].text ==
      //     DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      //   print(newTime!.hour);
      //   print(TimeOfDay.now().hour);
      //   print(newTime.minute);
      //   print(TimeOfDay.now().minute);
      //   if (timee.hour < TimeOfDay.now().hour ||
      //       timee.minute < TimeOfDay.now().minute) {
      //     print("error");
      //   } else if (timee.hour >= TimeOfDay.now().hour &&
      //       timee.minute >= TimeOfDay.now().minute) {
      //     print("correct");
      //   }
      // } else {

      if (newTime != null) {
        timee = newTime;
        remaindercheck = timee;
        if (mycontroller[16].text ==
            DateFormat('dd-MM-yyyy').format(DateTime.now())) {
          // log("ffff" +
          //     timee.hour.toString() +
          //     "TimeOfDay.now().hour::" +
          //     TimeOfDay.now().hour.toString());
          // log("ffff" +
          //     timee.hour.toString() +
          //     "TimeOfDay.now().hour::" +
          //     TimeOfDay.now().minute.toString());
          if (mycontroller[15].text.isNotEmpty && visittomecheck != null) {
            DateTime planPurDate;
            DateTime Nextfdate;
            log("visittomecheck::" + visittomecheck.toString());
            planPurDate = DateTime.parse(apiNdate!);
            Nextfdate = DateTime.parse(apiFdate.toString());
            if (Nextfdate.isBefore(planPurDate)) {
              // if (timee.hour < TimeOfDay.now().hour) {
              //     errorTime = "Please Choose Correct Time";
              //     mycontroller[17].text = "";
              //     notifyListeners();
              //     print("error");
              //   } else {
              errorTime = "";

              mycontroller[17].text = timee.format(context).toString();
              checkretime = false;

              notifyListeners();
              // }
            } else if (timee.hour > visittomecheck!.hour ||
                (timee.hour == visittomecheck!.hour &&
                    timee.minute > visittomecheck!.minute)) {
              errorTime = "Please Choose Correct Time";
              mycontroller[17].text = "";
              checkretime = true;
              notifyListeners();
            } else {
              if (timee.hour < TimeOfDay.now().hour) {
                errorTime = "Please Choose Correct Time";
                mycontroller[17].text = "";
                notifyListeners();
              } else {
                errorTime = "";

                mycontroller[17].text = timee.format(context).toString();
                checkretime = false;

                notifyListeners();
              }
            }
          } else {
            if (timee.hour < TimeOfDay.now().hour ||
                (timee.hour == TimeOfDay.now().hour &&
                    timee.minute < TimeOfDay.now().minute)) {
              errorTime = "Please Choose Correct Time";
              mycontroller[17].text = "";
              notifyListeners();
            } else {
              errorTime = "";

              mycontroller[17].text = timee.format(context).toString();
              checkretime = false;

              notifyListeners();
            }
          }
        } else {
          errorTime = "";
          if (mycontroller[15].text.isNotEmpty && visittomecheck != null) {
            log("visittomecheck::" + visittomecheck.toString());
            DateTime planPurDate;
            DateTime Nextfdate;
            log("visittomecheck::" + visittomecheck.toString());
            planPurDate = DateTime.parse(apiNdate!);
            Nextfdate = DateTime.parse(apiFdate.toString());
            if (Nextfdate.isBefore(planPurDate)) {
              // if (timee.hour < TimeOfDay.now().hour) {
              //     errorTime = "Please Choose Correct Time";
              //     mycontroller[17].text = "";
              //     notifyListeners();
              //     print("error");
              //   } else {
              errorTime = "";

              mycontroller[17].text = timee.format(context).toString();
              checkretime = false;

              notifyListeners();
              // }
            } else if (timee.hour > visittomecheck!.hour ||
                (timee.hour == visittomecheck!.hour &&
                    timee.minute > visittomecheck!.minute)) {
              errorTime = "Please Choose Correct Time";
              mycontroller[17].text = "";
              checkretime = true;
              notifyListeners();
            } else {
              // if (timee.hour < TimeOfDay.now().hour) {
              //   errorTime = "Please Choose Correct Time";
              //   mycontroller[17].text = "";
              //   notifyListeners();
              //   print("error");
              // } else {
              errorTime = "";

              mycontroller[17].text = timee.format(context).toString();
              checkretime = false;

              notifyListeners();
              // }
            }
          } else {
            // if (timee.hour < TimeOfDay.now().hour) {
            //   errorTime = "Please Choose Correct Time";
            //   mycontroller[17].text = "";
            //   notifyListeners();
            //   print("error");
            // } else {
            errorTime = "";

            mycontroller[17].text = timee.format(context).toString();
            checkretime = false;

            notifyListeners();
            // }
          }

//           timee = newTime;

//           print("correct22::" + timee.toString());
//           mycontroller[17].text = timee.format(context).toString();
// checkretime = false;
//           notifyListeners();
//           print("correct11::" + mycontroller[17].text.toString());
        }

        notifyListeners();
      }
      notifyListeners();
    } else {
      mycontroller[17].text = "";
      errorTime = "Please Choose First Date";
      notifyListeners();
    }
    notifyListeners();
  }

  String errorTime = "";
  TimeOfDay? visittomecheck;
  TimeOfDay? remaindercheck;
  void selectTime(BuildContext context) async {
    TimeOfDay timee = TimeOfDay.now();
    TimeOfDay startTime = TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 22, minute: 0);
    if (mycontroller[14].text.isNotEmpty) {
      errorTime = "";
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: timee,
      );
      // if (mycontroller[10].text ==
      //     DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      //   print(newTime!.hour);
      //   print(TimeOfDay.now().hour);
      //   print(newTime.minute);
      //   print(TimeOfDay.now().minute);
      //   if (timee.hour < TimeOfDay.now().hour ||
      //       timee.minute < TimeOfDay.now().minute) {
      //     print("error");
      //   } else if (timee.hour >= TimeOfDay.now().hour &&
      //       timee.minute >= TimeOfDay.now().minute) {
      //     print("correct");
      //   }
      // } else {

      if (newTime != null) {
        timee = newTime;
        visittomecheck = timee;
        log("timee.hour::" +
            timee.hour.toString() +
            "aaa" +
            startTime.hour.toString() +
            "bbb" +
            endTime.minute.toString());
        if (mycontroller[17].text.isNotEmpty && remaindercheck != null) {
          if (timee.hour < remaindercheck!.hour ||
              (timee.hour == remaindercheck!.hour &&
                  timee.minute < remaindercheck!.minute)) {
            mycontroller[17].text = '';
            checkretime = true;
            notifyListeners();
            // if (timee.hour < startTime.hour ||
            //     timee.hour > endTime.hour ||
            //     (timee.hour == endTime.hour && timee.minute > endTime.minute)) {
            //   istimevalid = true;
            //   mycontroller[15].text = "";
            //   errorTime = "Schedule Time between 7AM to 10PM*";

            //   notifyListeners();
            // } else {
            if (mycontroller[14].text ==
                DateFormat('dd-MM-yyyy').format(DateTime.now())) {
              if (timee.hour < TimeOfDay.now().hour ||
                  (timee.hour == TimeOfDay.now().hour &&
                      timee.minute < TimeOfDay.now().minute)) {
                errorTime = "Please Choose Correct Time";
                mycontroller[15].text = "";
                notifyListeners();
              } else {
                errorTime = "";
                mycontroller[15].text = timee.format(context).toString();
              }
            } else {
              errorTime = "";
              timee = newTime;
              mycontroller[15].text = timee.format(context).toString();
            }
            istimevalid = false;
            notifyListeners();
            // }
          } else {
            // if (timee.hour < startTime.hour ||
            //     timee.hour > endTime.hour ||
            //     (timee.hour == endTime.hour && timee.minute > endTime.minute)) {
            //   istimevalid = true;
            //   mycontroller[15].text = "";
            //   errorTime = "Schedule Time between 7AM to 10PM*";

            //   notifyListeners();
            // } else {
            if (mycontroller[14].text ==
                DateFormat('dd-MM-yyyy').format(DateTime.now())) {
              if (timee.hour < TimeOfDay.now().hour ||
                  (timee.hour == TimeOfDay.now().hour &&
                      timee.minute < TimeOfDay.now().minute)) {
                errorTime = "Please Choose Correct Time";
                mycontroller[15].text = "";
                notifyListeners();
              } else {
                errorTime = "";
                mycontroller[15].text = timee.format(context).toString();
              }
            } else {
              errorTime = "";
              timee = newTime;
              mycontroller[15].text = timee.format(context).toString();
            }
            istimevalid = false;
            notifyListeners();
            // }
          }
        } else {
          // if (timee.hour < startTime.hour ||
          //     timee.hour > endTime.hour ||
          //     (timee.hour == endTime.hour && timee.minute > endTime.minute)) {
          //   istimevalid = true;
          //   mycontroller[15].text = "";
          //   errorTime = "Schedule Time between 7AM to 10PM*";

          //   notifyListeners();
          // } else {
          if (mycontroller[14].text ==
              DateFormat('dd-MM-yyyy').format(DateTime.now())) {
            if (timee.hour < TimeOfDay.now().hour ||
                (timee.hour == TimeOfDay.now().hour &&
                    timee.minute < TimeOfDay.now().minute)) {
              errorTime = "Please Choose Correct Time";
              mycontroller[15].text = "";
              notifyListeners();
            } else {
              errorTime = "";
              mycontroller[15].text = timee.format(context).toString();
            }
          } else {
            errorTime = "";
            timee = newTime;
            mycontroller[15].text = timee.format(context).toString();
          }
          istimevalid = false;
          notifyListeners();
          // }
        }
      }
      notifyListeners();
    } else {
      mycontroller[15].text = "";
      errorTime = "Please Choose First Date";
      notifyListeners();
    }
    notifyListeners();
  }

  checksitevisit(bool val) {
    istimevalid = false;
    mycontroller[14].text = '';
    mycontroller[15].text = '';
    checkdata = false;
    checkretime = false;
    notifyListeners();
    if (val == true) {
      log("DONE");
      clearbool();

      notifyListeners();
    }
    sitevisitreq = val;
    log("message::" + sitevisitreq.toString());
    notifyListeners();
  }

  selectEnqReffers(String selected, String refercode) {
    isSelectedenquiryReffers = selected;
    EnqRefer = refercode;
    notifyListeners();
  }

  selectCsTag(String selected) {
    if (isSelectedCsTag == selected) {
      isSelectedCsTag = '';
    } else {
      isSelectedCsTag = selected;
    }
    notifyListeners();
  }

// List<GetCustomerData> itemdata =[];

// List<GetCustomerData> get getitemdata =>itemdata;
  bool customerapicalled = false;
  bool get getcustomerapicalled => customerapicalled;

  bool customerapicLoading = false;
  bool get getcustomerapicLoading => customerapicLoading;

  String exceptionOnApiCall = '';
  String get getexceptionOnApiCall => exceptionOnApiCall;

  List<EnquiryTypeData> enqList = [];
  List<EnquiryTypeData> get getEnqList => enqList;

  List<EnqRefferesData> enqReffList = [];
  List<EnqRefferesData> get getenqReffList => enqReffList;

  List<CustomerTagTypeData2> cusTagList = [];
  List<CustomerTagTypeData2> get getCusTagList => cusTagList;

  bool visibleEnqType = false;
  bool get getvisibleEnqType => visibleEnqType;

  bool visibleRefferal = false;
  bool get getvisibleRefferal => visibleRefferal;
  bool visibleremainder = false;
  bool get getvisibleremainder => visibleremainder;

  bool oldcutomer = false;
  bool get getoldcutomer => oldcutomer;

  String? EnqTypeCode;

  String? EnqRefer;

  bool isloadingBtn = false;

  bool get getisloadingBtn => isloadingBtn;
  setUserdata() {
//   for(int i=0;i<userLtData.length;i++){
// userLtData[i].color=0;
//   }
    filteruserLtData = userLtData;

    notifyListeners();
  }

  setcatagorydata() {
//   for(int i=0;i<userLtData.length;i++){
// userLtData[i].color=0;
//   }
    filtercatagorydata = catagorydata;

    notifyListeners();
  }

  setdefaultUserName() async {
    mycontroller[8].text = Utils.firstName.toString();
    for (int i = 0; i < filteruserLtData.length; i++) {
      // print(
      //     "object::${filteruserLtData[i].UserName.toString()}==${Utils.firstName.toString()}");
      if (filteruserLtData[i].UserName.toString() ==
          Utils.firstName.toString()) {
        // selectedIdxFUser = i;
        mycontroller[8].text = filteruserLtData[i].UserName.toString();
        selectedIdxFUser = i;
        await selectUser(i);
        notifyListeners();
      }
    }
    notifyListeners();

// selectedIdxFUser = ind;
//           context.read<NewEnqController>().selectUser(ind);
  }

  assignDefaultUser() {
    for (int i = 0; i < userLtData.length; i++) {
      if (Utils.firstName == userLtData[i].UserName) {
        selectedIdxFUser = i;
        // mycontroller[8].text=Utils.firstName.toString();
        selectUser(i);
        selectedAssignedUser();
      }
    }
  }

  List<StateHeaderData> stateData = [];
  List<StateHeaderData> filterstateData = [];
  bool statebool = false;
  stateApicallfromDB() async {
    stateData.clear();
    filterstateData.clear();

    final Database db = (await DBHelper.getInstance())!;
    stateData = await DBOperation.getstateData(db);
    filterstateData = stateData;
    log("getCustomerListFromDB length::" + filterstateData.length.toString());
    notifyListeners();
    // await stateApiNew.getData().then((value) {
    //   if (value.stcode! >= 200 && value.stcode! <= 210) {
    //     if (value.itemdata != null) {
    //       for (int i = 0; i <= value.itemdata!.datadetail!.length; i++) {
    //         stateData= value.itemdata!.datadetail!;
    //         filterstateData = stateData;
    //         log("fil"+filterstateData.length.toString());
    //         notifyListeners();
    //         log("stateData::" + stateData.length.toString());
    //       }
    //     } else if (value.itemdata == null) {
    //       customerapicLoading = false;
    //       exceptionOnApiCall = 'No Data Found..State..!!';
    //       notifyListeners();
    //     }
    //   } else if (value.stcode! >= 400 && value.stcode! <= 410) {
    //     customerapicLoading = false;
    //     exceptionOnApiCall =
    //         '${value.message}..! \n${value.exception}..!!${value.stcode}';
    //     notifyListeners();
    //   } else if (value.stcode == 500) {
    //     customerapicLoading = false;
    //     exceptionOnApiCall =
    //         '${value.message}..! \n${value.exception}..!!${value.stcode}';
    //     notifyListeners();
    //   }
    // });
  }

  String statecode = '';
  String countrycode = '';
  String statename = '';

  stateontap(int i) {
    log("AAAA::" + i.toString());
    statebool = false;
    mycontroller[12].text = filterstateData[i].stateName.toString();
    statecode = filterstateData[i].statecode.toString();
    statename = filterstateData[i].stateName.toString();
    countrycode = filterstateData[i].countrycode.toString();
    log("statecode::" + statecode.toString());
    log("statecode::" + countrycode.toString());
    notifyListeners();
  }

  filterListState2(String v) {
    if (v.isNotEmpty) {
      filterstateData = stateData
          .where((e) => e.stateName!.toLowerCase().contains(v.toLowerCase())
              // ||
              // e.name!.toLowerCase().contains(v.toLowerCase())
              )
          .toList();
      notifyListeners();
    } else if (v.isEmpty) {
      filterstateData = filterstateData;
      notifyListeners();
    }
  }

  getUserAssingData() async {
    final Database db = (await DBHelper.getInstance())!;

    userLtData = await DBOperation.getUserList(db);
    filteruserLtData = userLtData;

    notifyListeners();
  }

  defaultSelectAssignto(String usercode) async {
    String? getUsername = await HelperFunctions.getUserName();
    for (int i = 0; i < filteruserLtData.length; i++) {
      if (filteruserLtData[i].userCode == getUsername) {
        filteruserLtData[i].color = 1;
        getslpID = filteruserLtData[i].userCode!.isEmpty
            ? "0"
            : filteruserLtData[i].userCode.toString();
        managerSlpCode = filteruserLtData[i].mngSlpcode;
        mycontroller[8].text = filteruserLtData[i].UserName!;
        selectedIdxFUser = i;
      } else {
        filteruserLtData[i].color = 0;
      }
    }
    // filteruserLtData=userLtData;
    notifyListeners();
  }

  int? selectedIdxFUser = null;
  String? getslpID;
  String? managerSlpCode;
  selectUser(int ij) async {
    log("IJJJ::" + ij.toString());
    for (int i = 0; i < filteruserLtData.length; i++) {
      log("filteruserLtData[i].slpcode == filteruserLtData[ij].slpcode:::" +
          filteruserLtData[ij].userCode.toString());
      if (filteruserLtData[i].userCode == filteruserLtData[ij].userCode) {
        filteruserLtData[i].color = 1;
        getslpID = filteruserLtData[ij].userCode!.isEmpty
            ? "0"
            : filteruserLtData[ij].userCode.toString();
        managerSlpCode = filteruserLtData[ij].mngSlpcode;
        log("User:" + getslpID.toString());
        // log("Manager" + managerSlpCode.toString());
        selectedIdxFUser = ij;
      } else {
        filteruserLtData[i].color = 0;
      }
    }
    // filteruserLtData=userLtData;
    notifyListeners();
  }

  filterListcatagoryData(String v) {
    // for (int i = 0; i < catagorydata.length; i++) {
    //   catagorydata[i].color = 0;
    // }
    if (v.isNotEmpty) {
      filtercatagorydata = catagorydata
          .where((e) => e.toLowerCase().contains(v.toLowerCase())
              // ||
              // e.s!.toLowerCase().contains(v.toLowerCase())
              )
          .toList();
      notifyListeners();
    } else if (v.isEmpty) {
      filtercatagorydata = catagorydata;
      notifyListeners();
    }
  }

  filterListAssignData(String v) {
    for (int i = 0; i < filteruserLtData.length; i++) {
      filteruserLtData[i].color = 0;
    }
    if (v.isNotEmpty) {
      filteruserLtData = userLtData
          .where((e) => e.UserName!.toLowerCase().contains(v.toLowerCase())
              // ||
              // e.s!.toLowerCase().contains(v.toLowerCase())
              )
          .toList();
      notifyListeners();
    } else if (v.isEmpty) {
      filteruserLtData = userLtData;
      notifyListeners();
    }
  }

  selectedAssignedUser() {
    mycontroller[8].text = filteruserLtData[selectedIdxFUser!].UserName!;
    notifyListeners();
  }

  List<CheckEnqDetailsData>? checkEnqDetailsData = [];

  List<GetCustomerData>? customerdetails;
  List<GetenquiryData> enquirydetails = [];
  List<GetenquiryData> leaddetails = [];
  List<GetenquiryData>? quotationdetails;
  List<GetenquiryData>? orderdetails;

  callApi(BuildContext context) {
    //
    //fs
    customerapicLoading = true;
    notifyListeners();
    GetCutomerpost reqpost =
        GetCutomerpost(customermobile: mycontroller[0].text);
    String meth = ConstantApiUrl.getCustomerApi!;
    GetCustomerDetailsApi.getData(meth, reqpost).then((value) {
      if (value.stcode! >= 200 && value.stcode! <= 210) {
        if (value.itemdata != null) {
          if (value.itemdata!.customerdetails!.isNotEmpty &&
              value.itemdata!.customerdetails != null) {
            customerdetails = value.itemdata!.customerdetails;
            mapValues(value.itemdata!.customerdetails![0]);
            oldcutomer = true;
            notifyListeners();

            if (value.itemdata!.enquirydetails!.isNotEmpty &&
                value.itemdata!.enquirydetails != null) {
              log("Anbulead");
              for (int i = 0; i < value.itemdata!.enquirydetails!.length; i++) {
                if (value.itemdata!.enquirydetails![i].DocType == "Lead") {
                  leaddetails.add(GetenquiryData(
                      DocType: value.itemdata!.enquirydetails![i].DocType,
                      AssignedTo: value.itemdata!.enquirydetails![i].AssignedTo,
                      BusinessValue:
                          value.itemdata!.enquirydetails![i].BusinessValue,
                      CurrentStatus:
                          value.itemdata!.enquirydetails![i].CurrentStatus,
                      DocDate: value.itemdata!.enquirydetails![i].DocDate,
                      DocNum: value.itemdata!.enquirydetails![i].DocNum,
                      Status: value.itemdata!.enquirydetails![i].Status,
                      Store: value.itemdata!.enquirydetails![i].Store));
                } else if (value.itemdata!.enquirydetails![i].DocType ==
                    "Enquiry") {
                  enquirydetails.add(GetenquiryData(
                      DocType: value.itemdata!.enquirydetails![i].DocType,
                      AssignedTo: value.itemdata!.enquirydetails![i].AssignedTo,
                      BusinessValue:
                          value.itemdata!.enquirydetails![i].BusinessValue,
                      CurrentStatus:
                          value.itemdata!.enquirydetails![i].CurrentStatus,
                      DocDate: value.itemdata!.enquirydetails![i].DocDate,
                      DocNum: value.itemdata!.enquirydetails![i].DocNum,
                      Status: value.itemdata!.enquirydetails![i].Status,
                      Store: value.itemdata!.enquirydetails![i].Store));
                }
              }
              if (leaddetails.isNotEmpty) {
                AssignedToDialogUserState.LookingFor = leaddetails[0].DocType;
                AssignedToDialogUserState.Store = leaddetails[0].Store;
                AssignedToDialogUserState.handledby = leaddetails[0].AssignedTo;
                AssignedToDialogUserState.currentstatus =
                    leaddetails[0].CurrentStatus;

                alertDialogOpenLeadOREnq(context, "Lead");
              } else if (enquirydetails.isNotEmpty) {
                AssignedToDialogUserState.LookingFor =
                    enquirydetails[0].DocType;
                AssignedToDialogUserState.Store = enquirydetails[0].Store;
                AssignedToDialogUserState.handledby =
                    enquirydetails[0].AssignedTo;
                AssignedToDialogUserState.currentstatus =
                    enquirydetails[0].CurrentStatus;

                alertDialogOpenLeadOREnq(context, "enquiry");
              }
            }
            // else if (value.itemdata!.enquirydetails!.isNotEmpty &&
            //     value.itemdata!.enquirydetails != null) {
            //   for (int i = 0; i < value.itemdata!.enquirydetails!.length; i++) {

            //   }
            //   log("Anbuenq");
            //   enquirydetails = value.itemdata!.enquirydetails;

            // }
          } else {
            oldcutomer = false;
            customerapicLoading = false;
            notifyListeners();
          }
        } else if (value.itemdata == null) {
          oldcutomer = false;
          customerapicLoading = false;
          notifyListeners();
        }
      } else if (value.stcode! >= 400 && value.stcode! <= 410) {
        customerapicLoading = false;
        exceptionOnApiCall = '${value.stcode!}..!!${value.exception}..!! ';
        notifyListeners();
      } else if (value.stcode == 500) {
        customerapicLoading = false;
        exceptionOnApiCall =
            '${value.stcode!}..!!Network Issue..\nTry again Later..!!';
        notifyListeners();
      }
    });
  }

  int? forid;
  String? forcustcode;
  mapValues(GetCustomerData itemdata) async {
    log("MApvalues");
    PatchExCus patch = new PatchExCus();
    forid = itemdata.ID!;
    forcustcode = itemdata.customerCode!;
    mycontroller[0].text = itemdata.mobileNo!;
    mycontroller[1].text = itemdata.customerName!;
    mycontroller[2].text = itemdata.Address_Line_1.toString().isEmpty ||
            itemdata.Address_Line_1 == null ||
            itemdata.Address_Line_1 == "null"
        ? ''
        : itemdata.Address_Line_1!;
    mycontroller[3].text = itemdata.Address_Line_2.toString().isEmpty ||
            itemdata.Address_Line_2 == null ||
            itemdata.Address_Line_2 == "null"
        ? ''
        : itemdata.Address_Line_2!;
    mycontroller[4].text = itemdata.Pincode.toString().isEmpty ||
            itemdata.Pincode == null ||
            itemdata.Pincode == "null" ||
            itemdata.Pincode == "0"
        ? ''
        : itemdata.Pincode!;
    mycontroller[5].text = itemdata.City.toString().isEmpty ||
            itemdata.City == null ||
            itemdata.City == "null"
        ? ''
        : itemdata.City!;
    mycontroller[6].text = itemdata.email.toString().isEmpty ||
            itemdata.email == null ||
            itemdata.email == "null"
        ? ''
        : itemdata.email!;
    //
    mycontroller[10].text = itemdata.contactName.toString().isEmpty ||
            itemdata.contactName == null ||
            itemdata.contactName == "null"
        ? ''
        : itemdata.contactName!; //cantact name
    mycontroller[11].text = itemdata.area.toString().isEmpty ||
            itemdata.area == null ||
            itemdata.area == "null"
        ? ''
        : itemdata.area!; //area
    mycontroller[12].text = itemdata.State.toString().isEmpty ||
            itemdata.State == null ||
            itemdata.State == "null"
        ? ''
        : itemdata.State!; //state
    mycontroller[13].text = itemdata.altermobileNo.toString().isEmpty ||
            itemdata.altermobileNo == null ||
            itemdata.altermobileNo == "null"
        ? ''
        : itemdata.altermobileNo!; //Alter no
// isSelectedCsTag = itemdata.customerGroup.toString().isEmpty||itemdata.customerGroup ==null?'':itemdata.customerGroup!;
    // mycontroller[7].text = itemdata.Lookingfor!;
    for (int i = 0; i < cusTagList.length; i++) {
      if (cusTagList[i].Name == itemdata.customerGroup) {
        isSelectedCsTag = cusTagList[i].Code.toString();
      }
      notifyListeners();
    }
    // isSelectedenquiryReffers=itemdata.referal!;
    mycontroller[9].text = itemdata.PotentialValue.toString();
    customerapicLoading = false;
    await defaultSelectAssignto(itemdata.AssignedTo_User!);
    log("isSelectedCsTag::" + isSelectedCsTag.toString());
    notifyListeners();
  }

  bool isAnother = true;
  static List<String> comeFromAcc = [];
  static List<String> comeFromEnq = [];
  mapValuesFormAcc() async {
    exceptionOnApiCall = '';
    customerapicalled = true;
    notifyListeners();
    await getUserAssingData();

    await setdefaultUserName();
    await getEnqType();
    await getCusTagType();
    await getEnqRefferes();
    // await getDivisionValue();
    await mapValuesFormEnq();

    await stateApicallfromDB();
    await catagoryApi();
    await getLeveofType();
    if (comeFromAcc.isNotEmpty) {
      mycontroller[0].text = comeFromAcc[0] == "null" || comeFromAcc[0].isEmpty
          ? ""
          : comeFromAcc[0];
      mycontroller[1].text = comeFromAcc[1] == "null" || comeFromAcc[1].isEmpty
          ? ""
          : comeFromAcc[1];
      mycontroller[10].text = comeFromAcc[9] == "null" || comeFromAcc[9].isEmpty
          ? ""
          : comeFromAcc[9];
      mycontroller[2].text = comeFromAcc[2] == "null" || comeFromAcc[2].isEmpty
          ? ""
          : comeFromAcc[2];
      mycontroller[3].text = comeFromAcc[3] == "null" || comeFromAcc[3].isEmpty
          ? ""
          : comeFromAcc[3];
      mycontroller[11].text =
          comeFromAcc[10] == "null" || comeFromAcc[10].isEmpty
              ? ""
              : comeFromAcc[10];
      mycontroller[5].text = comeFromAcc[5] == "null" || comeFromAcc[5].isEmpty
          ? ""
          : comeFromAcc[5];
      mycontroller[4].text = comeFromAcc[4] == "null" ||
              comeFromAcc[4] == "0" ||
              comeFromAcc[4].isEmpty
          ? ""
          : comeFromAcc[4];
      mycontroller[12].text =
          comeFromAcc[11] == "null" || comeFromAcc[11].isEmpty
              ? ""
              : comeFromAcc[11];
      mycontroller[13].text = comeFromAcc[6] == "null" || comeFromAcc[6].isEmpty
          ? ""
          : comeFromAcc[6];
      mycontroller[6].text = comeFromAcc[7] == "null" || comeFromAcc[7].isEmpty
          ? ""
          : comeFromAcc[7];
      if (comeFromAcc[8].isNotEmpty) {
        for (int i = 0; i < cusTagList.length; i++) {
          if (cusTagList[i].Name == comeFromAcc[8]) {
            isSelectedCsTag = cusTagList[i].Code!;
          }
        }
      }
      customerapicalled = false;
      notifyListeners();
      comeFromAcc.clear();
      notifyListeners();
    }
  }

  mapValuesFormEnq() {
    // print("lennnnnnn comeFromEnq: ${comeFromEnq.length}");
    if (comeFromEnq.isNotEmpty) {
      mycontroller[0].text = comeFromEnq[0];
      mycontroller[1].text = comeFromEnq[1];
      mycontroller[2].text = comeFromEnq[2];
      mycontroller[3].text = comeFromEnq[3];
      mycontroller[4].text = comeFromEnq[4];
      mycontroller[5].text = comeFromEnq[5];
      customerapicLoading = false;
      oldcutomer = true;
      comeFromEnq.clear();
      notifyListeners();
    }
  }

  clearnum() {
    mycontroller[1].clear();
    mycontroller[2].clear();
    mycontroller[3].clear();
    mycontroller[4].clear();
    mycontroller[5].clear();
    mycontroller[6].clear();
    mycontroller[7].clear();
    mycontroller[8].clear();
    mycontroller[9].clear();
    mycontroller[10].clear();
    mycontroller[13].clear();
    mycontroller[11].clear();
    mycontroller[12].clear();
    isSelectedCsTag = '';
    customerapicalled = false;
    setdefaultUserName();
    notifyListeners();
  }

  clearwarning() {
    mycontroller[0].clear();
    mycontroller[1].clear();
    mycontroller[2].clear();
    mycontroller[3].clear();
    mycontroller[4].clear();
    mycontroller[5].clear();
    mycontroller[6].clear();
    mycontroller[7].clear();
    mycontroller[8].clear();
    mycontroller[9].clear();
    mycontroller[10].clear();
    mycontroller[13].clear();
    mycontroller[11].clear();
    mycontroller[12].clear();
    isSelectedCsTag = '';
    customerapicalled = false;
    setdefaultUserName();
    notifyListeners();
  }

  String? valueChosedStatus;
  String? valueChosedCusType;
  choosedType(String? val) {
    valueChosedCusType = val;
    notifyListeners();
  }

  choosedStatus(String? val) {
    valueChosedStatus = val;
    notifyListeners();
  }

  setArgument(String mobileno, BuildContext context) {
    if (mobileno.isNotEmpty) {
      mycontroller[0].text = mobileno;
      callApi(context);
    }
    notifyListeners();
  }

  clearAllData() {
    clearbool();
    leveofdata.clear();
    ordertypedata.clear();
    enquirydetails.clear();
    leaddetails.clear();
    checkretime = false;
    valueChosedStatus = null;
    valueChosedCusType = null;
    catagorydata.clear();
    filtercatagorydata.clear();
    sitevisitreq = false;
    isText1Correct = false;
    mycontroller[21].clear();
    mycontroller[14].clear();
    mycontroller[15].clear();
    mycontroller[16].clear();
    mycontroller[17].clear();
    mycontroller[0].clear();
    mycontroller[1].clear();
    mycontroller[2].clear();
    mycontroller[3].clear();
    mycontroller[4].clear();
    mycontroller[5].clear();
    mycontroller[6].clear();
    mycontroller[7].clear(); //looking
    mycontroller[8].clear(); //assign to
    mycontroller[9].clear();
    reyear = null;
    remonth = null;
    reday = null;
    rehours = null;
    reminutes = null;
    //potention
    //new
    mycontroller[10].clear();
    mycontroller[11].clear();
    mycontroller[12].clear();
    mycontroller[13].clear();
    statecode = '';
    countrycode = '';
    statename = '';
    statebool = false;
    isAnother == true;

    isloadingBtn = false;
    isSelectedenquirytype = '';
    isSelectedenquiryReffers = '';
    customerapicalled = false;
    oldcutomer = false;
    customerapicLoading = false;
    exceptionOnApiCall = '';
    isSelectedCsTag = '';
    visibleEnqType = false;
    visibleRefferal = false;
    visibleremainder = false;
    setdefaultUserName();
    notifyListeners();
  }

  getEnqType() async {
    final Database db = (await DBHelper.getInstance())!;

    enqList = await DBOperation.getEnqData(db);
    notifyListeners();
  }

  getCusTagType() async {
    cusTagList = [];
    final Database db = (await DBHelper.getInstance())!;

    cusTagList = await DBOperation.getCusTagData(db);
    notifyListeners();
  }

  List<LevelofData> leveofdata = [];
  List<OrderTypeData> ordertypedata = [];
  getLeveofType() async {
    leveofdata.clear();
    ordertypedata.clear();
    final Database db = (await DBHelper.getInstance())!;

    leveofdata = await DBOperation.getlevelofData(db);
    ordertypedata = await DBOperation.getordertypeData(db);
    notifyListeners();
  }

  getEnqRefferes() async {
    final Database db = (await DBHelper.getInstance())!;

    enqReffList = await DBOperation.getEnqRefferes(db);
    notifyListeners();
  }

  List<String> catagorydata = [];
  List<String> filtercatagorydata = [];
  catagoryApi() async {
    catagorydata.clear();
    filtercatagorydata.clear();
    String meth = ConstantApiUrl.getItemCategoryApi!;
    await ItemMasterCategoryApi.getData(meth).then((value) {
      if (value.stcode! >= 200 && value.stcode! <= 210) {
        catagorydata = value.itemdata!;
        filtercatagorydata = catagorydata;
        log("catagorydata::" + catagorydata.length.toString());
      } else {
        log("ANBBBUUUU");
      }
    });
  }

  ontapvalid(BuildContext context) {
    methidstate(mycontroller[12].text);
    FocusScope.of(context).requestFocus(focusNode1);
    statebool = false;
    notifyListeners();
  }

  iscateSeleted(BuildContext context, String select) {
    mycontroller[7].text = select;
    Navigator.pop(context);
    notifyListeners();
  }

  methodfortest() {
    // for(int i=0;i<filterstateData.length;i++){
    if (mycontroller[12].text.toLowerCase() == statename.toLowerCase()) {
      log("ANBUDUPppppppppppppppp");
      isText1Correct = false;
      notifyListeners();
    } else {
      log("ANBUDUP");
      statecode = '';
      countrycode = '';
      statename = '';
      isText1Correct = false;
      notifyListeners();
    }
    // }
  }

  methidstate(String name) {
    log("ANBU");
    statecode = '';
    statename = '';
    countrycode = '';
    for (int i = 0; i < filterstateData.length; i++) {
      if (filterstateData[i].stateName.toString().toLowerCase() ==
          name.toString().toLowerCase()) {
        statecode = filterstateData[i].statecode.toString();
        statename = filterstateData[i].stateName.toString();
        countrycode = filterstateData[i].countrycode.toString();

        log("statecode:::" + statecode.toString());
      }
    }
    if (statecode.isEmpty) {}
    //  notifyListeners();
  }

  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  void alertDialogOpenLeadOREnq(BuildContext context, typeOfDataCus) {
    showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          AssignedToDialogUserState.typeOfDataCus = typeOfDataCus;
          // assignto = false;
          return WarningDialog();
        }).then((value) {
      if (isAnother == false) {
        FocusScope.of(context).requestFocus(focusNode2);
      } else {}

      // clearAllData(context);
    });
  }

  String isremaider = 'Required Remaind On*';
  callAddEnq(BuildContext context) {
    visibleEnqType = false;
    visibleRefferal = false;
    visibleremainder = false;
    if (mycontroller[12].text.isNotEmpty) {
      methidstate(mycontroller[12].text);
    }
    // log("message" + statecode.toString());
    if (formkey.currentState!.validate()) {
      if (mycontroller[12].text.isEmpty ||
          statecode.isEmpty && countrycode.isEmpty) {
        isText1Correct = true;
        notifyListeners();
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select Correct State"),));
      } else if (isSelectedenquirytype.isEmpty) {
        visibleEnqType = true;
        notifyListeners();
      } else if (isSelectedenquiryReffers.isEmpty) {
        visibleRefferal = true;
        notifyListeners();
      } else if (mycontroller[16].text.isEmpty ||
          mycontroller[17].text.isEmpty) {
        visibleremainder = true;
        if (mycontroller[16].text.isNotEmpty && mycontroller[17].text.isEmpty) {
          visibleremainder = true;
          isremaider = 'Required Remaind On Time*';
        }
      } else {
        PatchExCus patch = new PatchExCus();
        patch.id = forid;
        patch.custcode = forcustcode.toString();
        log("forcustcode::" + forid.toString());
        log("forcustcode::" + patch.custcode.toString());
        // log("patchid::"+itemdata.id.toString());
        // log("patch::"+patch.id.toString());

        patch.CardCode = mycontroller[0].text;
        patch.CardName = mycontroller[1].text;
        //  patch.CardType =  mycontroller[2].text;
        patch.U_Address1 =
            mycontroller[2].text.isEmpty ? null : mycontroller[2].text;
        patch.U_Address2 =
            mycontroller[3].text.isEmpty ? null : mycontroller[3].text;
        patch.U_Pincode =
            mycontroller[4].text.isEmpty ? null : mycontroller[4].text;
        patch.U_City =
            mycontroller[15].text.isEmpty ? null : mycontroller[5].text;
        patch.U_Type = isSelectedCsTag;
        patch.cantactName =
            mycontroller[10].text.isEmpty ? null : mycontroller[10].text;
        patch.area =
            mycontroller[11].text.isEmpty ? null : mycontroller[11].text;
        patch.U_State = statecode;
        patch.altermobileNo =
            mycontroller[13].text.isEmpty ? null : mycontroller[13].text;
        patch.U_Country = countrycode;
        patch.remarks =
            mycontroller[21].text.isEmpty ? null : mycontroller[21].text;
        patch.levelof = valueChosedStatus == null || valueChosedStatus!.isEmpty
            ? null
            : valueChosedStatus;
        patch.ordertype =
            valueChosedCusType == null || valueChosedCusType!.isEmpty
                ? null
                : valueChosedCusType;

        patch.U_EMail =
            mycontroller[6].text.isEmpty ? null : mycontroller[6].text;

        if (oldcutomer == true) {
          isloadingBtn = true;

          notifyListeners();
          callPostEnq(patch, context);
        } else {
          isloadingBtn = true;
          notifyListeners();
          callPostEnq(patch, context);
        }
      }
    }
    notifyListeners();
  }

  int? reyear;
  int? remonth;
  int? reday;
  int? rehours;
  int? reminutes;

  List<Levelofinterest> levelofinterest = [
    Levelofinterest(name: "Hot"),
    Levelofinterest(name: "Cold"),
    Levelofinterest(name: "Warm"),
  ];

  callPostEnq(PatchExCus patch, BuildContext context) async {
    Config config2 = Config();
    tz.TZDateTime? tzChosenDate;
    PostEnq postEnq = new PostEnq();
    postEnq.CardCode = mycontroller[0].text;
    postEnq.U_Lookingfor = mycontroller[7].text;
    postEnq.U_PotentialValue = mycontroller[9].text.isEmpty
        ? 0.0
        : double.parse(mycontroller[9].text.toString());
    postEnq.U_EnqRefer = EnqRefer;
    postEnq.ActivityType = EnqTypeCode;
    postEnq.assignedtoslpCode = getslpID;
    postEnq.assignedtoManagerSlpCode = managerSlpCode;
    if (sitevisitreq == true) {
      postEnq.isvist = "Y";
      String newdateformat = config2.alignDatevisit(mycontroller[14].text);
      String newdate = config2.alignDateforvisit(mycontroller[15].text);
      postEnq.sitedate = newdateformat + "T" + newdate;
      //  mycontroller[14].text,mycontroller[15].text
    } else {
      postEnq.isvist = "N";
      postEnq.sitedate = null;
    }
    if (mycontroller[16].text.isNotEmpty && mycontroller[17].text.isNotEmpty) {
      String newdateformat = config2.remainderonalign(mycontroller[16].text);
      String newdate = config2.remainderontime(mycontroller[17].text);
      postEnq.remainderdate = newdateformat + "T" + newdate;
      rehours = int.parse(newdate.split(':')[0]);
      reminutes = int.parse(newdate.split(':')[1]);
      log("rehours::" + rehours.toString());
      log("reminutes::" + reminutes.toString());

      final DateTime chosenDate =
          DateTime(reyear!, remonth!, reday!, rehours!, reminutes!);
      final tz.Location indian = tz.getLocation('Asia/Kolkata');
      tzChosenDate = tz.TZDateTime.from(chosenDate, indian);
    } else {
      postEnq.remainderdate = null;
    } // log("message ${ postEnq.assignedtoslpCode} , ${getslpID}");
    String meth = ConstantApiUrl.enqPost!;
    await EnqPostApi.getData(meth, postEnq, patch).then((value) {
      //fs
      if (value.stcode! >= 200 && value.stcode! <= 210) {
        isloadingBtn = false;
        if (value.resType == 'success') {
          log("tzChosenDate::" + tzChosenDate.toString());
          config2.addEventToCalendar(
              tzChosenDate!,
              "Remainder For Enquiry  date ${mycontroller[16].text} for ${mycontroller[1].text}",
              "${value.message}");
          callAlertDialog(context, '${value.message}..!!');
        } else if (value.resType == 'error') {
          callAlertDialog2(context, '${value.message}..!!');
        }
        notifyListeners();
      } else if (value.stcode! >= 400 && value.stcode! <= 410) {
        isloadingBtn = false;
        notifyListeners();
        callAlertDialog2(context, '${value.resType}..!!${value.exception}..!!');
        // config.msgDialog(context, "Some thing wrong..!!", value.error!.message!.value!);
      } else {
        isloadingBtn = false;
        notifyListeners();
        callAlertDialog2(context,
            '${value.stcode!}..!!Network Issue..\nTry again Later..!!');
      }
    });
  }

  callAlertDialog(BuildContext context, String mesg) {
    showDialog<dynamic>(
        context: context,
        builder: (_) {
          return AlertMsg(
            msg: '$mesg',
          );
        }).then((value) {
      clearAllData();
      Get.offAllNamed(ConstantRoutes.dashboard);
    });
  }

  callAlertDialog2(BuildContext context, String mesg) {
    showDialog<dynamic>(
        context: context,
        builder: (_) {
          return AlertMsg(
            msg: '$mesg',
          );
        }).then((value) {});
  }

  callAlertDialogError(BuildContext context, String mesg) {
    showDialog<dynamic>(
        context: context,
        builder: (_) {
          return AlertMsg(
            msg: '$mesg',
          );
        }).then((value) {});
  }
}

class Levelofinterest {
  String? name;
  Levelofinterest({required this.name});
}
