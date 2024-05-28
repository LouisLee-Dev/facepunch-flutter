import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'work_model.dart';
import '/widgets/utils.dart';
import '/lang/l10n.dart';
import 'revision_model.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/config/app_const.dart';
import '/providers/base_provider.dart';

class User with HttpRequest{
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? firstName;
  String? lastName;
  String? phone;
  String? pin;
  String? employeeCode;
  String? start;
  String? salary;
  String? birthday;
  String? address1;
  String? address2;
  String? city;
  String? country;
  String? state;
  String? postalCode;
  String? language;
  String? avatar;
  String? avatarUrl;
  String? role;
  String? type;
  String? firebaseToken;
  String? emailVerifyNumber;
  int? companyId;
  String? nfc;
  String? createdAt;
  String? updatedAt;
  bool? active = true;
  BreakSetting? breakSetting;

  List<Punch> punches = [];
  List<WorkHistory> works = [];
  List<EmployeeBreak> breaks = [];
  List<WorkSchedule> schedules = [];
  List<EmployeeCall> calls = [];
  Punch? lastPunch;
  String? token;

  bool? canNTCTracking = true;

  User({
    this.id,
    this.name,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.pin,
    this.start,
    this.salary,
    this.birthday,
    this.address1,
    this.address2,
    this.city,
    this.country,
    this.state,
    this.postalCode,
    this.language,
    this.avatar,
    this.role,
    this.type,
    this.companyId,
    this.employeeCode,
    this.nfc,
    this.token,
    this.active
  });

  User.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      email = json['email'];
      emailVerifiedAt = json['email_verified_at'];
      firstName = json['first_name'];
      lastName = json['last_name'];
      phone = json['phone'];
      pin = json['pin'];
      start = json['start'];
      salary = json['salary'];
      birthday = json['birthday'];
      address1 = json['address1'];
      address2 = json['address2'];
      city = json['city'];
      country = json['country'];
      state = json['state'];
      postalCode = json['postal_code'];
      language = json['language'];
      if(language==null){
        language = 'English';
      }
      avatar = json['avatar'];
      avatarUrl = json['avatar_url'];
      role = json['role'];
      type = json['type'];
      firebaseToken = json['firebase_token'];
      emailVerifyNumber = json['email_verify_number'];
      companyId = json['company_id'];
      employeeCode = json['employee_code'];
      token = json['token'];
      if(json['last_punch']!=null){
        lastPunch = Punch.fromJson(json['last_punch']);
      }
      nfc = json['nfc'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      active = json['active']??false;
      canNTCTracking = json['can_nfc_tracking']??false;
      if(json['break'] != null){
        breakSetting = BreakSetting.fromJson(json['break']);
      }
    }catch(e){
      Tools.consoleLog("[User.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['pin'] = this.pin;
    data['start'] = this.start;
    data['salary'] = this.salary;
    data['birthday'] = this.birthday;
    data['address1'] = this.address1;
    data['address2'] = this.address2;
    data['city'] = this.city;
    data['country'] = this.country;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    if(language!=null)data['language'] = this.language;
    data['avatar'] = this.avatar;
    data['avatar_url'] = this.avatarUrl;
    data['role'] = this.role;
    data['type'] = this.type;
    data['firebase_token'] = this.firebaseToken;
    data['email_verify_number'] = this.emailVerifyNumber;
    data['company_id'] = this.companyId;
    data['employee_code'] = this.employeeCode;
    data['token'] = this.token;
    data['nfc'] = this.nfc;
    data['can_nfc_tracking'] = this.canNTCTracking;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['active'] = this.active;
    if(this.breakSetting != null){
      data['break'] = this.breakSetting!.toJson();
    }
    return data;
  }

  String getFullName(){
    return '$firstName $lastName';
  }

  Punch? getTodayPunch(){
    return punches.lastWhereOrNull((p) =>(p.createdAt != null && isSameDatePunch(p.createdAt!, DateTime.now().toString())));
  }

  bool isSameDatePunch(String punchDate, String date){
    return getDateString(punchDate) == getDateString(date);
  }

  String getDateString(String date){
    return date.split(" ").first;
  }

  Map<String, List<Punch>> getPunchesGroupByDate(){
    Map<String, List<Punch>> punchGroup = {};
    punches.forEach((p) {
      if(p.createdAt != null){
        if(punchGroup[getDateString(p.createdAt!)] == null){
          punchGroup[getDateString(p.createdAt!)] = [p];
        }else{
          punchGroup[getDateString(p.createdAt!)]!.add(p);
        }
      }
    });
    return punchGroup;
  }

  List<Punch> getPunchesOfDate(DateTime date){
    return punches.where((p) =>p.createdAt != null && isSameDatePunch(p.createdAt!, date.toString()) && p.isIn()).toList();
  }

  List<Punch> getPunchesOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 7));
    return punches.where((p) => (p.createdAt != null && DateTime.parse(p.createdAt!).isAfter(startDate) && DateTime.parse(p.createdAt!).isBefore(endDate))).toList();
  }

  Map<String, List<Punch>> getPunchesGroupOfWeek(DateTime startDate){
    Map<String, List<Punch>> punchGroup = {};
    getPunchesOfWeek(startDate).forEach((p) {
      if(p.punch == "In" && p.createdAt != null){
        if(punchGroup[getDateString(p.createdAt!)]==null){
          punchGroup[getDateString(p.createdAt!)] = [p];
        }else{
          punchGroup[getDateString(p.createdAt!)]!.add(p);
        }
      }
    });
    return punchGroup;
  }

  double getHoursOfDate(DateTime date){
    List<Punch> punchesOfDate = getPunchesOfDate(date);
    double hours = 0.0;
    punchesOfDate.forEach((punchIn) {
      Punch? punchOut = getPunchOut(punchIn);
      if(punchOut != null && punchOut.createdAt != null){
        hours += DateTime.parse(punchOut.createdAt!).difference(DateTime.parse(punchIn.createdAt!)).inMinutes/60;
      }
    });
    return hours;
  }

  double getBreakTime(DateTime date){
    double hours = 0;
    breaks.where((b) => b.start != null && isSameDatePunch(b.start!, date.toString())).forEach((b) {
      if(b.length != null){
        hours += b.length!/60;
      }
    });
    return hours;
  }

  double calculateHoursOfDate(DateTime date){
    return getHoursOfDate(date) - getBreakTime(date);
  }

  double getTotalHoursOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 6));
    Map<String, List<Punch>> punchGroup = getPunchesGroupByDate();
    double totalHours = 0.0;
    punchGroup.forEach((d, v) {
      DateTime date = DateTime.parse(d);
      if(date.isAfter(startDate) && date.isBefore(endDate)){
        totalHours += calculateHoursOfDate(date);
      }
    });
    return totalHours;
  }

  double getTotalHoursOfCurrentWeek(){
    DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    return getTotalHoursOfWeek(startOfWeek);
  }

  double getTotalHoursOfLastWeek(){
    DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    return getTotalHoursOfWeek(startOfWeek.subtract(Duration(days: 7)));
  }

  Punch? getPunchOut(Punch punchIn){
    return punches.firstWhereOrNull((p) => (p.inId != null && p.inId == punchIn.id));
  }

  List<WorkHistory> worksOfPunch(Punch punch){
    return works.where((w) => (w.punchId != null && w.punchId == punch.id),).toList();
  }

  List<EmployeeBreak> breaksOfPunch(Punch punch){
    return breaks.where((b) => (b.punchId!=null && b.punchId == punch.id),).toList();
  }

  Future<String?> editPunch(int? punchId, String value)async{
    try{
      var res = await sendPostRequest(
        AppConst.editPunch,
        GlobalData.token,
        {'punch_id':punchId,'value':value},
      );
      Tools.consoleLog("[User.editPunch.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.editPunch.err] $e");
      return e.toString();
    }
  }

  Future<String?> deletePunch(int? punchId)async{
    try{
      var res = await sendPostRequest(
        AppConst.deletePunch,
        GlobalData.token,
        {'punch_id':punchId},
      );
      Tools.consoleLog("[User.deletePunch.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.deletePunch.err] $e");
      return e.toString();
    }
  }

  Future<String?> editWork(WorkHistory work)async{
    try{
      var res = await sendPostRequest(
        AppConst.editWork,
        GlobalData.token,
        work.toJson(),
      );
      Tools.consoleLog("[User.editWork.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.editWork.err] $e");
      return e.toString();
    }
  }

  Future<String?> deleteWork(int? workId)async{
    try{
      var res = await sendPostRequest(
        AppConst.deleteWork,
        GlobalData.token,
        {'id':workId},
      );
      Tools.consoleLog("[User.deleteWork.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.deleteWork.err] $e");
      return e.toString();
    }
  }

  bool isPunchIn(){
    return lastPunch != null && lastPunch?.punch=='In';
  }

  bool hasTracking(){
    return ['shop_tracking','call_shop_tracking'].contains(type);
  }

  bool hasSchedule(){
    return ['shop_daily','call_shop_daily'].contains(type);
  }

  bool hasCall(){
    return ['call', 'call_shop_daily', 'call_shop_tracking'].contains(type);
  }

  bool checkType(String v){
    return type == v;
  }

  bool hasNTCTracking(){
    return canNTCTracking??false;
  }

  bool hasCode(){
    return employeeCode != null && employeeCode!.isNotEmpty;
  }

  String pdfUrl(DateTime? startDate){
    DateTime pdfDate = startDate??PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    final pdfLink = "$firstName $lastName (${pdfDate.toString().split(" ")[0]} ~ ${pdfDate.add(Duration(days: 6)).toString().split(" ")[0]}).pdf";
    return Uri.encodeFull('${AppConst.domainURL}punch-pdfs/$companyId/$pdfLink');
  }

  String harvestReportUrl(){
    return Uri.encodeFull('${AppConst.domainURL}harvest-reports/$companyId/Harvest_Report_${DateTime.now().toString().split(' ')[0]}.png');
  }

  Widget userAvatarImage(){
    return CachedNetworkImage(
      imageUrl: '$avatarUrl',
      alignment: Alignment.center,
      placeholder: (_,__)=>Image.asset("assets/images/person.png"),
      errorWidget: (_,__,___)=>Image.asset("assets/images/person.png"),
      fit: BoxFit.cover,
    );
  }

  Future<String?> getDailyTasks(String date)async{
    try{
      var res = await sendPostRequest(
          AppConst.getDailyTasks,
          token,
          {'date':date}
      );
      Tools.consoleLog('[WorkModel.getDailyTasks.res]${res.body}');
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        schedules.clear();
        calls.clear();
        works.clear();
        for(var s in body['schedules']){
          schedules.add(WorkSchedule.fromJson(s));
        }
        for(var c in body['calls']){
          calls.add(EmployeeCall.fromJson(c));
        }
        for(var w in body['works']){
          works.add(WorkHistory.fromJson(w));
        }
        return null;
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.getDailyTasks.err]$e');
      return e.toString();
    }
  }

  Future<List<Revision>> getMyRevisionNotifications()async{
    var res = await sendGetRequest(
        AppConst.getRevisionNotifications,
        token
    );
    Tools.consoleLog('[User.getMyRevisionNotifications.res]${res.body}');
    final json = jsonDecode(res.body);
    if(res.statusCode==200){
      List<Revision> revisions = [];
      for(var revision in json){
        revisions.add(Revision.fromJson(revision));
      }
      return revisions;
    }else{
      throw handleError(json);
    }
  }

  Future<List<Revision>> getTeamRevisionNotifications(String date, bool isWeek)async{
    var res = await sendPostRequest(
        AppConst.getTeamRevisionNotifications,
        token,
      {
        'date': date,
        'is_week': isWeek
      }
    );
    Tools.consoleLog('[User.getTeamRevisionNotifications.res]${res.body}');
    final json = jsonDecode(res.body);
    if(res.statusCode==200){
      List<Revision> revisions = [];
      for(var revision in json){
        revisions.add(Revision.fromJson(revision));
      }
      return revisions;
    }else{
      throw handleError(json);
    }
  }

  Future<String?> getDailyCall(String date)async{
    try{
      var res = await sendPostRequest(
          AppConst.getEmployeeCall,
          GlobalData.token,
          {
            'date' : date,
            'id' : id.toString()
          }
      );
      Tools.consoleLog('[WorkModel.getDailyCall.res]${res.body}');
      var body = jsonDecode(res.body);
      if(res.statusCode == 200){
        calls.clear();
        for(var c in body){
          calls.add(EmployeeCall.fromJson(c));
        }
        return null;
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.getDailyCall.err]$e');
      return e.toString();
    }
  }

  Future<String?> deleteBreak(int? breakId)async{
    try{
      var res = await sendPostRequest(
        AppConst.deleteBreak,
        GlobalData.token,
        {'id':breakId},
      );
      Tools.consoleLog("[User.deleteBreak.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.deleteBreak.err] $e");
      return e.toString();
    }
  }

  bool isAdmin(){
    return role == 'admin';
  }

  bool isEmployee(){
    return role == 'employee';
  }

  bool isManager(){
    return role == 'manager';
  }

  bool isSubAdmin(){
    return role == 'sub_admin';
  }

  bool canManageDispatch(){
    return role != 'employee';
  }

  bool isManualBreak(){
    return breakSetting != null && breakSetting!.type == "manual";
  }

  Future<String?> startShopTracking({int? projectId, int? taskId, double? latitude, double? longitude})async{
    try{
      var res = await sendPostRequest(
          AppConst.startShopTracking,
          token,
          {
            'task_id': taskId,
            'project_id': projectId,
            'latitude': latitude,
            'longitude': longitude,
          }
      );
      Tools.consoleLog('[User.startShopTracking.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[User.startShopTracking.err]$e');
      return e.toString();
    }
  }

  Future<String?> startManualBreak()async{
    try{
      var res = await sendGetRequest(AppConst.startManualBreak, token);
      Tools.consoleLog('[User.startManualBreak.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[User.startManualBreak.err]$e');
      return e.toString();
    }
  }

  Future<String?> endManualBreak()async{
    try{
      var res = await sendGetRequest(AppConst.endManualBreak, token);
      Tools.consoleLog('[User.endManualBreak.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[User.endManualBreak.err]$e');
      return e.toString();
    }
  }

  Future<String?> delete()async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await sendPostRequest(AppConst.deleteEmployee, GlobalData.token, {'id' : id});
      Tools.consoleLog("[User.delete.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.delete.err] $e");
    }
    return result;
  }

  Future<String?> punchOut({double? latitude, double? longitude})async{
    try{
      var res = await sendPostRequest(
          AppConst.punchOut,
          token,
          {
            'latitude':latitude,
            'longitude':longitude
          }
      );
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[User.punchOut.err] $e");
      return e.toString();
    }
  }
}

class Punch{
  int? id;
  int? userId;
  int? inId;
  String? punch;
  double? longitude;
  double? latitude;
  String? status;
  String? createdAt;
  String? updatedAt;

  Punch({
    this.id,
    this.userId,
    this.punch,
    this.longitude,
    this.latitude,
    this.createdAt,
    this.updatedAt
  });

  Punch.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      userId = json['user_id'];
      inId = json['in_id'];
      punch = json['punch'];
      longitude = json['longitude']==null?null:double.parse(json['longitude'].toString());
      latitude = json['latitude']==null?null:double.parse(json['latitude'].toString());
      status = json['status'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog("[Punch.fromJson.err] $e");
    }
  }

  bool isIn(){
    return punch == "In";
  }

  bool isOut(){
    return punch == "Out";
  }

  bool isSent(){
    return status == 'Sent';
  }

  String title(BuildContext context){
    if(createdAt == null){
      return "${S.of(context).punch} $punch ${S.of(context).at} --:--";
    }
    return "${S.of(context).punch} $punch ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.parse(createdAt!))}";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['in_id'] = this.inId;
    data['user_id'] = this.userId;
    data['punch'] = this.punch;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  String getTime(){
    if(createdAt == null) return '--:--';
    return PunchDateUtils.getTimeString(DateTime.parse(createdAt!));
  }

  bool hasLocation(){
    return latitude != null && longitude != null;
  }

}

class FacePunchData{
  late User employee;
  Punch? punch;
  List<EmployeeCall> calls = [];
  List<WorkSchedule> schedules = [];
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];
  String? message;
  WorkHistory? work;
  double? latitude;
  double? longitude;
  bool isInManualBreak = false;

  FacePunchData.fromJson(Map<String, dynamic> json){
    try{
      employee = User.fromJson(json['employee']);
      message = json['message'];
      if(json['punch'] != null){
        punch = Punch.fromJson(json['punch']);
      }
      if(json['calls'] != null){
        for(var call in json['calls']){
          calls.add(EmployeeCall.fromJson(call));
        }
      }
      if(json['schedules'] != null){
        for(var schedule in json['schedules']){
          schedules.add(WorkSchedule.fromJson(schedule));
        }
      }
      if(json['projects'] != null){
        for(var project in json['projects']){
          projects.add(Project.fromJson(project));
        }
      }
      if(json['tasks'] != null){
        for(var task in json['tasks']){
          tasks.add(ScheduleTask.fromJson(task));
        }
      }
      if(json['work'] != null){
        work = WorkHistory.fromJson(json['work']);
      }
      isInManualBreak = json['in_manual_break']??false;
    }catch(e){
      Tools.consoleLog("[FacePunchData.fromJson.err] $e");
    }
  }
}

class BreakSetting{
  String? type;
  String? start;
  int? length;
  bool? calculate;

  BreakSetting.fromJson(Map<String, dynamic> json){
    try{
      type = json['type'];
      start = json['start'];
      length = json['length'];
      calculate = json['calculate'];
    }catch(e){
      Tools.consoleLog("[BreakSetting.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    data['start'] = start;
    data['length'] = length;
    data['calculate'] = calculate;
    return data;
  }
}

