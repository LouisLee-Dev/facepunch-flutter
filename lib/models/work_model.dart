import 'dart:convert';
import 'package:flutter/material.dart';

import '/lang/l10n.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/config/app_const.dart';
import '/widgets/utils.dart';
import '/providers/base_provider.dart';


class Project{
  int? id;
  int? companyId;
  String? name;
  String? companyName;
  String? code;
  String? address;

  Project.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      companyId = json['company_id'];
      companyName = json['company_name'];
      name = json['name'];
      code = json['code'];
      address = json['address'];
    }catch(e){
      Tools.consoleLog('[Project.fromJson.err]$e');
    }
  }

  bool hasCode(){
    return code != null && code!.isNotEmpty;
  }

}

class ScheduleTask{
  int? id;
  String? name;
  String? code;
  int? companyId;

  ScheduleTask.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      companyId = json['company_id'];
      name = json['name'];
      code = json['code'];
    }catch(e){
      Tools.consoleLog('[ScheduleTask.fromJson.err]$e');
    }
  }

  bool hasCode(){
    return code != null && code!.isNotEmpty;
  }
}

class WorkHistory{
  int? id;
  int? userId;
  int? punchId;
  int? taskId;
  int? projectId;
  String? projectAddress;
  int? callId;
  int? scheduleId;
  String? start;
  String? end;
  String? taskName;
  String? taskCode;
  String? projectName;
  String? projectCode;
  String? type;
  String? createdAt;
  String? updatedAt;
  WorkHistory({
    this.id,
    this.userId,
    this.taskId,
    this.projectId,
    this.start,
    this.end,
    this.taskName,
    this.projectName,
    this.taskCode,
    this.projectCode
  });

  WorkHistory.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      punchId = json['punch_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      callId = json['call_id'];
      scheduleId = json['schedule_id'];
      taskName = json['task_name'];
      taskCode = json['task_code'];
      projectName = json['project_name'];
      projectCode = json['project_code'];
      projectAddress = json['project_address'];
      start = json['start'];
      end = json['end'];
      type = json['type'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog('[WorkHistory.fromJson.err]$e');
    }
  }

  double workHour(){
    try{
      final startTime = DateTime.tryParse(start!);
      final endTime = DateTime.tryParse(end!);
      if(startTime == null)return 0.0;
      if(endTime == null)return 0.0;
      return endTime.difference(startTime).inMinutes/60;
    }catch(e){
      Tools.consoleLog('[WorkHistory.workHour.err]$e');
    }
    return 0.0;
  }

  DateTime? getStartTime(){
    if(start != null){
      return DateTime.tryParse(start!);
    }
  }

  DateTime? getEndTime(){
    if(end==null || end!.isEmpty) return null;
    return DateTime.tryParse(end!);
  }

  String title(){
    return '${projectName??''} - ${taskName??''}';
  }

  String projectTitle(){
    return '$projectName - $projectCode \n $projectAddress'.trim();
  }

  String taskTitle(){
    return '$taskName - $taskCode';
  }

  toJson(){
    return {
      'id':id,
      'user_id':userId,
      'punch_id':punchId,
      'start':start,
      'end':end,
      'task_id' : taskId,
      'project_id' : projectId,
      'call_id' : callId,
      'schedule_id' : scheduleId,
      'task_name':taskName,
      'task_code':taskCode,
      'project_name':projectName,
      'project_code':projectCode,
      'project_address':projectAddress,
      'type':type,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isEnd(){
    return end != null && end!.isNotEmpty;
  }

  bool isWorkingOn(){
    return start != null && end == null;
  }

  String startTime(){
    if(start != null && start!.length > 16){
      return start!.substring(11, 16);
    }
    return '--:--';
  }

  String endTime(){
    if(end != null && end!.length > 16){
      return end!.substring(11, 16);
    }
    return '--:--';
  }

}

class WorkSchedule with HttpRequest{
  int? id;
  int? userId;
  int? projectId;
  int? taskId;
  String? projectName;
  String? projectCode;
  String? projectAddress;
  String? taskName;
  String? taskCode;
  String? start;
  String? end;
  Shift? shift;
  String? color;
  String? noAvailable;
  String? status;
  String? createdAt;
  String? updatedAt;

  WorkSchedule({
    this.id,
    this.userId,
    this.projectId,
    this.taskId,
    this.projectName,
    this.projectCode,
    this.projectAddress,
    this.taskName,
    this.taskCode,
    this.start,
    this.end,
    this.shift,
    this.color,
    this.noAvailable,
    this.createdAt,
    this.updatedAt
  });

  WorkSchedule.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      projectName = json['project_name'];
      projectCode = json['project_code'];
      projectAddress = json['project_address'];
      taskName = json['task_name'];
      taskCode = json['task_code'];
      start = json['start'];
      end = json['end'];
      if(json['shift'] != null){
        shift = Shift.fromJson(json['shift']);
      }
      noAvailable = json['no_available'];
      color = json['color'];
      status = json['status'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog('[WorkSchedule.fromJson.err]$e');
    }
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'project_id':projectId,
      'task_id':taskId,
      'project_name':projectName,
      'project_code':projectCode,
      'project_address':projectAddress,
      'task_name':taskName,
      'task_code':taskCode,
      'start':start,
      'end':end,
      'shift':shift,
      'no_available':noAvailable,
      'color': color,
      'status' : status,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isWorked(){
    return status == 'done';
  }

  bool isWorkingOn(){
    return status == "working";
  }

  DateTime? getStartTime(){
    return DateTime.tryParse(start!);
  }

  DateTime? getEndTime(){
    return DateTime.tryParse(end!);
  }

  String startTime(){
    if(start != null && start!.length > 16){
      return start!.substring(11, 16);
    }
    return '--:--';
  }

  String endTime(){
    if(end != null && end!.length > 16){
      return end!.substring(11, 16);
    }
    return '--:--';
  }

  String projectTitle(){
    if(isNoAvailable()) return '';
    return '$projectName - ${projectCode??''} \n $projectAddress'.trim();
  }

  String taskTitle(){
    if(isNoAvailable()) return '$taskName';
    return '$taskName - ${taskCode??''}';
  }

  bool isNoAvailable(){
    return noAvailable != null && noAvailable!.isNotEmpty;
  }

  String? isValid(){
    final startTime = getStartTime();
    if(startTime != null){
      int startDiff = startTime.difference(DateTime.now()).inMinutes;
      if(startDiff > 5){
        return 'Why do you start this schedule early?';
      }else if(startDiff < -5){
        return 'Why do you start this schedule late?';
      }
    }
    final endTime = getEndTime();
    if(endTime != null){
      int endDiff = endTime.difference(DateTime.now()).inMinutes;
      if(endDiff > 5){
        return 'Why do you finish this schedule early?';
      }else if(endDiff < -5){
        return 'Why do you finish this schedule late?';
      }
    }
  }

  Future<String?> startSchedule({String? token, double? latitude, double? longitude})async{
    try{
      var res = await sendPostRequest(
        AppConst.startSchedule,
        token??GlobalData.token,
        {
          'id' : id,
          'latitude' : latitude,
          'longitude' : longitude
        }
      );
      Tools.consoleLog('[WorkSchedule.startSchedule.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.startSchedule.err]$e');
      return e.toString();
    }
  }

  Future<String?> endSchedule()async{
    try{
      var res = await sendPostRequest(
        AppConst.endSchedule,
        GlobalData.token,
        {'id':id}
      );
      Tools.consoleLog('[WorkSchedule.endSchedule.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.endSchedule.err]$e');
      return e.toString();
    }
  }

  Future<String?> deleteSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.deleteSchedule,
          GlobalData.token,
          { 'id':id }
      );
      Tools.consoleLog('[WorkSchedule.deleteSchedule.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.deleteSchedule.err]$e');
      return e.toString();
    }
  }

  Future<String?> editSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.editSchedule,
          GlobalData.token,
          toJson(),
      );
      Tools.consoleLog('[WorkSchedule.editSchedule.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.editSchedule.err]$e');
      return e.toString();
    }
  }

  Future<String?> addSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.addSchedule,
          GlobalData.token,
          toJson()
      );
      Tools.consoleLog('[WorkSchedule.addSchedule.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.addSchedule.err]$e');
      return e.toString();
    }
  }
}

class EmployeeCall with HttpRequest{
  int? id;
  int? userId;
  int? projectId;
  int? taskId;
  String? projectName;
  String? projectCode;
  String? projectAddress;
  String? taskName;
  String? taskCode;
  String? date;
  String? start;
  String? end;
  String? todo;
  String? note;
  int? priority;
  String? status;
  String? createdAt;
  String? updatedAt;

  EmployeeCall({
    this.id,
    this.userId,
    this.projectId,
    this.taskId,
    this.projectName,
    this.projectCode,
    this.projectAddress,
    this.taskCode,
    this.taskName,
    this.date,
    this.start,
    this.end,
    this.todo,
    this.note,
    this.priority,
    this.createdAt,
    this.updatedAt
  });

  EmployeeCall.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      projectName = json['project_name'];
      projectCode = json['project_code'];
      projectAddress = json['project_address'];
      taskName = json['task_name'];
      taskCode = json['task_code'];
      date = json['date'];
      start = json['start'];
      end = json['end'];
      todo = json['todo']??'';
      note = json['note']??'';
      priority = json['priority'];
      status = json['status'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog('[EmployeeCall.fromJson.err]$e');
    }
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'project_id':projectId,
      'task_id':taskId,
      'project_name':projectName,
      'project_code':projectCode,
      'project_address':projectAddress,
      'task_name':taskName,
      'task_code':taskCode,
      'date':date,
      'start':start,
      'end':end,
      'todo':todo,
      'note':note,
      'status':status,
      'priority':priority,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isWorked(){
    return status == 'done';
  }

  bool isWorkingOn(){
    return status == 'working';
  }

  DateTime? getStartTime(){
    if(start == null) return null;
    return DateTime.tryParse(start!);
  }

  DateTime? getEndTime(){
    if(end == null) return null;
    return DateTime.tryParse(end!);
  }

  String startTime(){
    if(start != null && start!.length > 16){
      return start!.substring(11, 16);
    }
    return '--:--';
  }

  String endTime(){
    if(end != null && end!.length > 16){
      return end!.substring(11, 16);
    }
    return '--:--';
  }

  Future<String?> startCall({String? token, double? latitude, double? longitude})async{
    try{
      var res = await sendPostRequest(
          AppConst.startCall,
          token,
          {
            'id':id,
            'latitude':latitude,
            'longitude':longitude
          }
      );
      Tools.consoleLog('[EmployeeCall.startCall.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[EmployeeCall.startSchedule.err]$e');
      return e.toString();
    }
  }

  Future<String?> addEditCall()async{
    try{
      var res = await sendPostRequest(
        AppConst.addEditCall,
        GlobalData.token,
        toJson(),
      );
      Tools.consoleLog('[EmployeeCall.addEditCall.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[EmployeeCall.addEditCall.err]$e');
      return e.toString();
    }
  }

  Future<String?> delete()async{
    try{
      var res = await sendPostRequest(
          AppConst.deleteCall,
          GlobalData.token,
          {'id':id}
      );
      Tools.consoleLog('[EmployeeCall.delete.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[EmployeeCall.startSchedule.err]$e');
      return e.toString();
    }
  }

  Color color(){
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.teal,
      Colors.amber,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    if(id==null) return Colors.blue;
    return colors[id!%10];
  }

  String projectTitle(){
    return '$projectName - ${projectCode??''} \n $projectAddress'.trim();
  }

  String taskTitle(){
    return '$taskName - $taskCode';
  }

  bool hasTime(){
    return start != null && end != null;
  }
}

class EmployeeBreak{
  int? id;
  int? userId;
  int? punchId;
  String? title;
  String? start;
  int? length;
  bool? calculate;
  String? createdAt;
  String? updatedAt;

  EmployeeBreak.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      punchId = json['punch_id'];
      title = json['title'];
      start = json['start'];
      length = json['length'];
      calculate = json['calculate']==1;
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog('[EmployeeBreak.fromJson.err]$e');
    }
  }

  String getTitle(BuildContext context){
    if(start == null){
      return '$title ${S.of(context).at} --:--, $length Minutes';
    }
    return '$title ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.tryParse(start!))}, $length Minutes';
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'punch_id':punchId,
      'start':start,
      'title':title,
      'length':length,
      'calculate':(calculate!= null && calculate!)?1:0,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }
}

class Shift{
  int? id;
  String? name;
  String? start;
  String? end;
  String? color;

  Shift.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      name = json['name'];
      start = json['start'];
      end = json['end'];
      color = json['color'];
    }catch(e){
      Tools.consoleLog('[Shift.fromJson.err]$e');
    }
  }
}