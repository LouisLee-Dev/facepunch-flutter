import 'dart:convert';
import 'package:localstorage/localstorage.dart';

import '/config/app_const.dart';
import '/models/harvest_model.dart';
import '/widgets/utils.dart';
import 'base_provider.dart';

class HarvestProvider extends BaseProvider{
  final LocalStorage storage = LocalStorage('harvest');
  List<Field> fields = [];
  List<HContainer> containers = [];
  List<HTask> tasks = [];

  Future<void> getHarvestData()async{
    await getHarvestDataFromLocal();
    await getHarvestDataFromServer();
  }

  Future<void> getHarvestDataFromLocal()async{
    try {
      final ready = await storage.ready;
      if (ready) {
        var tJson = storage.getItem('tasks');
        if(tJson!=null){
          tasks.clear();
          for(var t in tJson){
            tasks.add(HTask.fromJson(t));
          }
        }
        var fJson = storage.getItem('fields');
        if(fJson!=null){
          fields.clear();
          for(var f in fJson){
            fields.add(Field.fromJson(f));
          }
        }

        var cJson = storage.getItem('containers');
        if(cJson!=null){
          containers.clear();
          for(var c in cJson){
            containers.add(HContainer.fromJson(c));
          }
        }
      }
      notifyListeners();
    } catch (err) {
      Tools.consoleLog("[HarvestModel.getHarvestDataFromLocal.err] $err");
    }
  }

  Future<String?> getHarvestDataFromServer()async{
    try{
      final res = await sendGetRequest(AppConst.getHarvestData,GlobalData.token);
      Tools.consoleLog('[HarvestModel.getHarvestDataFromServer.res] ${res.body}');
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        fields.clear();
        for(var json in body['fields']){
          fields.add(Field.fromJson(json));
        }
        containers.clear();
        for(var json in body['containers']){
          containers.add(HContainer.fromJson(json));
        }
        tasks.clear();
        for(var json in body['tasks']){
          tasks.add(HTask.fromJson(json));
        }
        saveHarvestDataToLocal();
        return null;
      }else{
        return body['message']??'Something want wrong.';
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.getHarvestDataFromServer.err] $e');
      return e.toString();
    }
  }

  Future<void> saveHarvestDataToLocal() async {
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('fields', fields.map((v) => v.toJson()).toList());
        await storage.setItem('containers', containers.map((v) => v.toJson()).toList());
        await storage.setItem('tasks', tasks.map((v) => v.toJson()).toList());
      }
      notifyListeners();
    } catch (e) {
      Tools.consoleLog("[HarvestModel.saveFieldsToLocal.err] $e");
    }
  }

  Future<String?> createOrUpdateField(Field field)async{
    try{
      final res = await sendPostRequest(AppConst.createOrUpdateFiled,GlobalData.token,field.toJson());
      Tools.consoleLog('[HarvestModel.createOrUpdateField.res] ${res.body}');
      if(res.statusCode==200){
        if(field.id == null){
          field = Field.fromJson(jsonDecode(res.body));
          fields.add(field);
          saveHarvestDataToLocal();
        }
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.createOrUpdateField.err] $e');
      return e.toString();
    }
  }

  Future<String?> deleteField(Field field)async{
    try{
      final res = await sendPostRequest(AppConst.deleteField,GlobalData.token,field.toJson());
      Tools.consoleLog('[HarvestModel.deleteField.res] ${res.body}');
      if(res.statusCode==200){
        fields.remove(field);
        tasks.removeWhere((t) => t.fieldId == field.id);
        saveHarvestDataToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.deleteField.err] $e');
      return e.toString();
    }
  }

  Future<String?> createOrUpdateContainer(HContainer container)async{
    try{
      final res = await sendPostRequest(
          AppConst.createOrUpdateContainer,
          GlobalData.token,
          container.toJson()
      );
      Tools.consoleLog('[HarvestModel.createOrUpdateContainer.res] ${res.body}');
      if(res.statusCode==200){
        if(container.id == null){
          container = HContainer.fromJson(jsonDecode(res.body));
          containers.add(container);
          saveHarvestDataToLocal();
        }
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.createOrUpdateContainer.err] $e');
      return e.toString();
    }
  }

  Future<String?> deleteContainer(HContainer container)async{
    try{
      final res = await sendPostRequest(
          AppConst.deleteContainer,
          GlobalData.token,
          container.toJson()
      );
      Tools.consoleLog('[HarvestModel.deleteContainer.res] ${res.body}');
      if(res.statusCode==200){
        containers.remove(container);
        tasks.removeWhere((t) => t.containerId == container.id);
        saveHarvestDataToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.deleteContainer.err] $e');
      return e.toString();
    }
  }

  Future<String?> deleteTask(HTask task)async{
    try{
      final res = await sendPostRequest(
        AppConst.deleteTask,
        GlobalData.token,
        task.toJson(),
      );
      Tools.consoleLog('[HarvestModel.deleteTask.res]${res.body}');
      if(res.statusCode==200){
        tasks.remove(task);
        saveHarvestDataToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.deleteTask.err] $e');
      return e.toString();
    }
  }

  Future<String?> createOrUpdateTask(HTask task)async{
    try{
      final res = await sendPostRequest(
        AppConst.createOrUpdateTask,
        GlobalData.token,
        task.toJson(),
      );
      Tools.consoleLog('[HarvestModel.createOrUpdateTask.res]${res.body}');
      if(res.statusCode==200){
        final newTask = HTask.fromJson(jsonDecode(res.body));
        tasks.removeWhere((t) => t.id==newTask.id);
        newTask.container = task.container;
        newTask.field = task.field;
        tasks.add(newTask);
        saveHarvestDataToLocal();
        notifyListeners();
      }else{
        return jsonDecode(res.body)['message'];
      }
      return null;
    }catch(e){
      Tools.consoleLog('[HarvestModel.createOrUpdateContainer.err] $e');
      return e.toString();
    }
  }

  Future<List<Harvest>> getHarvestsOfDate(String date)async{
    try{
      List<Harvest> harvests = [];
      final res = await sendPostRequest(
        AppConst.getHarvestsOfDate,
        GlobalData.token,
        {'date':date},
      );
      Tools.consoleLog('[HarvestModel.getHarvestsOfDate.res] ${res.body}');
      if(res.statusCode==200){
        for(var json in jsonDecode(res.body)){
          harvests.add(Harvest.fromJson(json));
        }
        return harvests;
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.getHarvestsOfDate.err] $e');
    }
    return [];
  }

  Future addHarvest({required HTask task, required String date, required String nfc})async{
    try{
      final res = await sendPostRequest(
        AppConst.addHarvest,
        GlobalData.token,
        {
          'container_id':task.container?.id,
          'field_id':task.field?.id,
          'date':date,
          'quantity':1.0,
          'nfc':nfc
        },
      );
      Tools.consoleLog('[HarvestModel.addHarvest.res] ${res.body}');
      if(res.statusCode==200){
        return Harvest.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.addHarvest.err] $e');
    }
    return null;
  }

  Future deleteHarvest(int? id)async{
    try{
      final res = await sendPostRequest(
          AppConst.deleteHarvest,
          GlobalData.token,
          {'id':id}
      );
      Tools.consoleLog('[HarvestModel.deleteHarvest.res] ${res.body}');
      if(res.statusCode==200){
        return Harvest.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.deleteHarvest.err] $e');
    }
    return null;
  }

  Future getEmployeeHarvestStats(String date, int? field)async{
    try{
      final res = await sendPostRequest(
        AppConst.getEmployeeHarvestStats,
        GlobalData.token,
        {
          'date':date,
          'field':field,
        },
      );
      Tools.consoleLog('[HarvestModel.getEmployeeHarvestStats.res]${res.body}');
      if(res.statusCode==200){
        List<HarvestEmployeeStats> eStats = [];
        final json = jsonDecode(res.body);
        for(var stats in json){
          eStats.add(HarvestEmployeeStats.fromJson(stats));
        }
        return eStats;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.getEmployeeHarvestStats.err]$e');
      return e.toString();
    }
  }

  Future getCompanyHarvestStats(String date, int? field)async{
    try{
      final res = await sendPostRequest(
        AppConst.getCompanyHarvestStats,
        GlobalData.token,
        {
          'date':date,
          'field':field,
        },
      );
      Tools.consoleLog('[HarvestModel.getCompanyHarvestStats.res]${res.body}');
      if(res.statusCode==200){
        return HarvestCompanyStats.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.getEmployeeHarvestStats.err]$e');
      return e.toString();
    }
  }

  Future getDateHarvestStats(String date)async{
    try{
      final res = await sendPostRequest(
        AppConst.getDateHarvestStats,
        GlobalData.token,
        {'date':date},
      );
      Tools.consoleLog('[HarvestModel.getDateHarvestStats.res]${res.body}');
      if(res.statusCode==200){
        List<HarvestDateStats> dateStats = [];
        for(var stats in jsonDecode(res.body))
          dateStats.add(HarvestDateStats.fromJson(stats));
        return dateStats;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[HarvestModel.getDateHarvestStats.err]$e');
      return e.toString();
    }
  }
}