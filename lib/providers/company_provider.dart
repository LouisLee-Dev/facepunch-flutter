import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import '/models/user_model.dart';
import '/models/company_model.dart';
import '/widgets/utils.dart';
import '/config/app_const.dart';
import 'base_provider.dart';


class CompanyProvider extends BaseProvider{
  final LocalStorage storage = LocalStorage('companies');
  Company? myCompany;
  CompanySettings? myCompanySettings;
  List<User> users = [];

  Future<bool> getMyCompany(int? companyId)async{
    await getCompanyFromLocal();
    await getCompanySettingsFromLocal();
    if(myCompany?.id != companyId || myCompanySettings == null){
      await getCompanyFromServer();
      await getCompanySettingsFromServer();
    }else{
      getCompanyFromServer();
      getCompanySettingsFromServer();
    }
    return myCompany != null && myCompanySettings != null;
  }

  getCompanyFromServer()async{
    try{
      final res = await sendGetRequest(AppConst.getMyCompany, GlobalData.token);
      Tools.consoleLog("[CompanyModel.getCompanyFromServer.res] ${res.body}");
      if(res.statusCode==200){
        myCompany = Company.fromJson(jsonDecode(res.body));
        await saveCompanyToLocal();
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.getCompanyFromServer.err] $e");
    }
    notifyListeners();
  }

  saveCompanyToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('my_company',myCompany?.toJson());
    }catch(e){
      Tools.consoleLog("[CompanyModel.saveCompanyToLocal.err] $e");
    }
  }

  getCompanyFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('my_company');
        if(json!=null){
          myCompany = Company.fromJson(json);
        }
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.getCompanyFromLocal.err] $e");
    }
    notifyListeners();
  }

  Future<String?> createEditEmployee(User user, String? photo)async{
    String? result = 'Oops, Unknown Errors!';
    try{
      user.companyId = myCompany?.id;
      var userData = user.toJson();
      if(photo != null){ userData['photo'] = photo; }
      final res = await sendPostRequest(AppConst.addEditEmployee, GlobalData.token, userData);
      Tools.consoleLog("[CompanyModel.createEditEmployee.res] ${res.body}");
      if(res.statusCode==200){
        if(user.id != null){
          user = users.firstWhere((u) => u.id == user.id);
          Punch? punch = user.lastPunch;
          users.removeWhere((u) => u.id == user.id);
          user = User.fromJson(jsonDecode(res.body));
          user.lastPunch = punch;
          users.add(user);
        }else{
          users.add(User.fromJson(jsonDecode(res.body)));
        }
        notifyListeners();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.createEditEmployee.err] $e");
      result = e.toString();
    }
    return result;
  }

  Future<String?> getCompanyUsers()async{
    try{
      var res = await sendGetRequest(AppConst.getCompanyEmployees, GlobalData.token);
      Tools.consoleLog("[CompanyModel.getCompanyUsers.res] ${res.body}");
      if(res.statusCode==200){
        users.clear();
        for(var json in jsonDecode(res.body))
          users.add(User.fromJson(json));
        notifyListeners();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.getCompanyUsers.err] $e");
      return e.toString();
    }
  }

  Future<String?> deleteEmployee(int userId)async{
    users.removeWhere((u) => u.id==userId);
    notifyListeners();
  }

  Future<String?> updateCompany({required String name, String? address1, String? address2,
    String? country, String? state, String? city, String? postalCode, String? phone})async{
    String? result = 'Oops, Unknown Errors!';
    try{
      var res = await sendPostRequest(
          AppConst.updateCompany,
          GlobalData.token,
          {
            'name':name,
            'address1' : address1,
            'address2' : address2,
            'city' : city,
            'country' : country,
            'state' : state,
            'postal_code' : postalCode,
            'phone' : phone
          }
      );
      Tools.consoleLog("[CompanyModel.updateCompany.res] ${res.body}");
      if(res.statusCode==200){
        myCompany = Company.fromJson(jsonDecode(res.body));
        await saveCompanyToLocal();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.updateCompany.err] $e");
    }
    return result;
  }

  Future<String?> getCompanySettingsFromServer()async{
    try{
      var res = await sendGetRequest(AppConst.getCompanySettings, GlobalData.token);
      Tools.consoleLog("[CompanyModel.getCompanySettings.res] ${res.body}");
      if(res.statusCode==200){
        myCompanySettings = CompanySettings.fromJson(jsonDecode(res.body));
        await saveCompanySettingsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.getCompanySettings.err] $e");
      return e.toString();
    }
  }

  getCompanySettingsFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('company_settings');
        if(json!=null){
          myCompanySettings = CompanySettings.fromJson(json);
          notifyListeners();
        }
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.getCompanyFromLocal.err] $e");
    }
    notifyListeners();
  }

  saveCompanySettingsToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('company_settings', myCompanySettings?.toJson());
      notifyListeners();
    }catch(e){
      Tools.consoleLog("[CompanyModel.saveCompanySettingsToLocal.err] $e");
    }
  }

  Future<String?> updateCompanySetting(CompanySettings settings)async{
    try{
      var res = await sendPostRequest(AppConst.updateCompanySettings, GlobalData.token, settings.toJson());
      Tools.consoleLog("[CompanyModel.updateCompanySetting.res] ${res.body}");
      if(res.statusCode==200){
        myCompanySettings = settings;
        saveCompanySettingsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.updateCompanySetting.err] $e");
      return e.toString();
    }
  }

  Future<String?> punchByAdmin({int? userId, required String action, required String punchTime,
    double? longitude, double? latitude})async{
    try{
      var res = await sendPostRequest(
          AppConst.punchByAdmin,
          GlobalData.token,
          {
            'user_id':userId,
            'action':action,
            'longitude':longitude,
            'latitude':latitude,
            'punch_time':punchTime,
          }
      );
      Tools.consoleLog("[CompanyModel.punchByAdmin.res] ${res.body}");
      if(res.statusCode==200){
        final punch = Punch.fromJson(jsonDecode(res.body));
        users.firstWhere((u) => u.id==userId).lastPunch = punch;
        notifyListeners();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[CompanyModel.punchByAdmin.err] $e");
      return e.toString();
    }
  }
}