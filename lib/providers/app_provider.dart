import 'dart:convert';
import 'dart:io';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/widgets/utils.dart';
import '/config/app_const.dart';
import 'base_provider.dart';

class AppProvider extends BaseProvider{
  bool isDebug = false;
  final LocalStorage storage = LocalStorage('app_config');

  getConfig()async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isDebug = prefs.getBool('is_debug')??false;
      notifyListeners();
      if(isDebug){
        AppConst.domainURL = AppConst.devDomain;
      }else{
        AppConst.domainURL = AppConst.liveDomain;
      }
    }catch(e){
      Tools.consoleLog('[AppModel.getConfig]$e');
    }
  }

  switchDebug()async{
    isDebug = !isDebug;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_debug', isDebug);
    if(isDebug){
      AppConst.domainURL = AppConst.devDomain;
    }else{
      AppConst.domainURL = AppConst.liveDomain;
    }
  }

  Future<Map<String, dynamic>?> getAppVersions()async{
    try{
      await getConfig();
      var res = await sendGetRequest( AppConst.getAppVersions, null);
      Tools.consoleLog('[AppModel.getAppVersions.res]${res.body}');
      if(res.statusCode == 200){
        return jsonDecode(res.body);
      }
    }catch(e){
      Tools.consoleLog('[AppModel.getAppVersions.err]$e');
    }
    return null;
  }

  Future<String?> submitMobileLog({String? comment, required Map<String, dynamic> deviceInfo})async{
    try{
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${AppConst.LOG_FILE_PREFIX}${DateTime.now().toString().split(' ')[0]}');
      String content = '';
      if(await logFile.exists()){
        content = await logFile.readAsString();
      }
      Map<String, dynamic> data = Map<String, dynamic>();
      data['log'] = content;
      if(comment != null){
        data['comment'] = comment;
      }
      deviceInfo['app_version'] = AppConst.currentVersion;
      deviceInfo['lang'] = GlobalData.lang;
      data['device'] = deviceInfo;
      final res = await sendPostRequest(AppConst.submitMobileLog, GlobalData.token, data);
      Tools.consoleLog('[AppModel.submitMobileLog.res]${res.body}');
      if(res.statusCode == 200){
        logFile.deleteSync();
        return null;
      }else{
        return jsonDecode(res.body)['message']??"Something went wrong.";
      }
    }catch(e){
      Tools.consoleLog('[AppModel.submitMobileLog.err]$e');
      return e.toString();
    }
  }

}