import 'dart:convert';

import '/models/work_model.dart';
import '/config/app_const.dart';
import '/widgets/utils.dart';
import 'base_provider.dart';

class RevisionProvider extends BaseProvider {

  Future<String?> sendPunchRevisionRequest({int? punchId, required String newValue,
    String? oldValue, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
            'punch_id' : punchId.toString(),
            'new_value' : newValue,
            'old_value' : oldValue,
            'description' : description
          }
      );
      Tools.consoleLog("[RevisionModel.sendPunchRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendPunchRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendBreakRevisionRequest({required EmployeeBreak newBreak, required EmployeeBreak oldBreak, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
            'break_id':oldBreak.id,
            'new_value': newBreak.toJson(),
            'old_value': oldBreak.toJson(),
            'description': description
          }
      );
      Tools.consoleLog("[RevisionModel.sendBreakRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendBreakRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendWorkRevisionRequest({required WorkHistory newWork, required WorkHistory oldWork, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
            'work_id': oldWork.id,
            'new_value': newWork.toJson(),
            'old_value': oldWork.toJson(),
            'description': description
          }
      );
      Tools.consoleLog("[RevisionModel.sendWorkRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendWorkRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendScheduleRevision({required WorkSchedule newSchedule, required WorkSchedule oldSchedule, required String description})async{
    try{
      var res = await sendPostRequest(
        AppConst.sendTimeRevisionRequest,
        GlobalData.token,
        {
          'schedule_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        },
      );
      Tools.consoleLog('[RevisionModel.sendScheduleRevision.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[RevisionModel.sendScheduleRevision.err]$e');
      return e.toString();
    }
  }

  Future<String?> sendCallRevision({required EmployeeCall newSchedule, required EmployeeCall oldSchedule, required String description})async{
    try{
      var res = await sendPostRequest(
        AppConst.sendTimeRevisionRequest,
        GlobalData.token,
        {
          'call_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        },
      );
      Tools.consoleLog('[RevisionModel.sendCallRevision.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[RevisionModel.sendCallRevision.err]$e');
      return e.toString();
    }
  }
}