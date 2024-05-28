import 'dart:convert';

import '/config/app_const.dart';
import '/widgets/utils.dart';
import '/models/work_model.dart';
import 'base_provider.dart';

class WorkProvider extends BaseProvider{
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  Future<void> getProjectsAndTasks()async{
    try{
      var res = await sendGetRequest(
        AppConst.getProjectsAndTasks,
        GlobalData.token,
      );
      Tools.consoleLog('[WorkModel.getProjects.res]${res.body}');
      if(res.statusCode==200){
        projects.clear();
        for(var project in jsonDecode(res.body)['projects']){
          projects.add(Project.fromJson(project));
        }
        tasks.clear();
        for(var project in jsonDecode(res.body)['tasks']){
          tasks.add(ScheduleTask.fromJson(project));
        }
        notifyListeners();
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.getProjects.err]$e');
    }
  }

  Future<dynamic> getCall(int callId)async{
    try{
      var res = await sendPostRequest(
          AppConst.getCall,
          GlobalData.token,
          {
            'id': callId
          }
      );
      Tools.consoleLog('[WorkModel.getCall.res]${res.body}');
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        return EmployeeCall.fromJson(body);
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      Tools.consoleLog('[WorkModel.getCall.err]$e');
      return e.toString();
    }
  }
}