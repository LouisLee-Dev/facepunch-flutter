import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/work_model.dart';
import '/widgets/utils.dart';
import '/config/app_const.dart';
import 'base_provider.dart';
import '/models/user_model.dart';

class UserProvider extends BaseProvider{
  User? user;
  final LocalStorage storage = LocalStorage('face_punch_user');
  String locale = 'en';
  double yearTotalHours = 0;

  Future<User?> getUserFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('user');
        if(json != null){
          user = User.fromJson(json);
          user = await getUserInfoFromServer(user!.token!);
          if(user != null){
            if(user?.language == 'Spanish'){
              locale = 'es';
              GlobalData.lang = locale;
            }else if(user?.language == 'French'){
              locale = 'fr';
              GlobalData.lang = locale;
            }
            GlobalData.token = user!.token!;
          }else{
            logOut();
          }
        }else{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          locale = prefs.getString('language')??'en';
        }
      }
    }catch(e){
      Tools.consoleLog("[UserModel.getUserFromLocal.err] $e");
    }
    notifyListeners();
    return user;
  }

  saveUserToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('user', user?.toJson());
      if(user?.language=='Spanish'){
        locale = 'es';
      }else if(user?.language=='French'){
        locale = 'fr';
      }else{
        locale = 'en';
      }
      GlobalData.lang = locale;
      notifyListeners();
    }catch(e){
      Tools.consoleLog("[UserModel.saveUserToLocal.err] $e");
    }
  }

  Future<String?> adminLogin(String email, String password, bool isRememberMe)async{
    String? result = 'Oops, Unknown Errors!';
    try{
      String? deviceToken = await Tools.getFirebaseToken();
      var res = await sendPostRequest(
          AppConst.adminLogin,
          null,
          {
            'email':email,
            'password':password,
            'firebase_token': deviceToken
          }
      );
      Tools.consoleLog("[UserModel.adminLogin.res] ${res.body}");
      if(res.statusCode == 200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user!.token!;
        if(isRememberMe)await saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[UserModel.adminLogin.err] $e");
    }
    return result;
  }

  logOut()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        await storage.deleteItem('user');
        user = null;
      }
    }catch(e){
      Tools.consoleLog("[UserModel.logOut.err] $e");
    }
  }

  Future<String?> recoverPassword(String email)async{
    try{
      var res = await sendPostRequest(
          AppConst.recoverPassword,
          null,
          { 'email':email }
      );
      Tools.consoleLog("[UserModel.recoverPassword.res] ${res.body}");
      if(res.statusCode==200){
        return "We have sent new password to your email.";
      }else{
        return jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[UserModel.recoverPassword.err] $e");
      return 'Oops, Unknown Errors!';
    }
  }

  Future<String?> verifyEmailAddress(String number)async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await sendPostRequest(
          AppConst.emailVerify,
          user?.token,
          {
            'email' : user?.email,
            'verify_number' : number,
          }
      );
      Tools.consoleLog("[UserModel.verifyEmailAddress.res] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user!.token!;
        await saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[UserModel.verifyEmailAddress.err] $e");
    }
    return result;
  }

  Future<String?> sendVerifyEmailAgain()async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await sendGetRequest(
          AppConst.sendVerifyAgain,
          user?.token
      );
      Tools.consoleLog("[UserModel.sendVerifyEmailAgain.res] ${res.body}");
      if(res.statusCode==200){
        user?.emailVerifyNumber = jsonDecode(res.body)['number'];
        await saveUserToLocal();
        return null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[UserModel.sendVerifyEmailAgain.err] $e");
    }
    return result;
  }

  Future<String?> updateAdmin({required String email, String? newPassword, String? oldPassword, required String fName, required String lName})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await sendPostRequest(
          AppConst.updateAdmin,
          user?.token,
          {
            'email':email,
            'new_password' : newPassword,
            'old_password' : oldPassword,
            'first_name' : fName,
            'last_name' : lName
          }
      );
      Tools.consoleLog("[UserModel.updateUser.res] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user!.token!;
        await saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      Tools.consoleLog("[UserModel.updateUser.err] $e");
    }
    return result;
  }

  Future<String?> loginWithFace(String photo)async{
    String result = 'Oops, Unknown Errors!';
    try{
      String? deviceToken = await Tools.getFirebaseToken();
      Tools.consoleLog("[UserModel.loginWithFace.deviceToken] $deviceToken");
      var res = await sendPostRequest(
          AppConst.loginWithFace,
          null,
          {
            'photo':photo,
            'face_punch_key' : await Tools.getPunchKey(),
            'firebase_token': deviceToken
          }
      );
      Tools.consoleLog("[UserModel.loginWithFace.res] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user!.token!;
        await saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[UserModel.loginWithFace.err] $e");
    }
    return result;
  }

  Future<dynamic> punchWithFace({required String photo, double? longitude, double? latitude})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await sendPostRequest(
          AppConst.punchWithFace,
          null,
          {
            'photo': photo,
            'face_punch_key' : await Tools.getPunchKey(),
            'longitude': longitude,
            'latitude': latitude
          }
      );
      Tools.consoleLog("[UserModel.punchWithFace.res] ${res.body}");
      if(res.statusCode==200){
        return FacePunchData.fromJson(jsonDecode(res.body));
      }else{
        result = jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[UserModel.punchWithFace.err] $e");
    }
    return result;
  }

  Future<String?> getUserTimeSheetData(DateTime date)async{
    try{
      var res = await sendPostRequest(
          AppConst.getTimeSheetData,
          user?.token,
          {'date': date.toString()}
      );
      Tools.consoleLog("[UserModel.getUserTimeSheetData.res] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in body['punches']) punches.add(Punch.fromJson(punch));
        user?.punches = punches;
        List<WorkHistory> works = [];
        for(var work in body['works']) works.add(WorkHistory.fromJson(work));
        user?.works = works;
        List<EmployeeBreak> breaks = [];
        for(var b in body['breaks']) breaks.add(EmployeeBreak.fromJson(b));
        user?.breaks = breaks;
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      Tools.consoleLog("[UserModel.getUserTimeSheetData.err] $e");
      return e.toString() ;
    }
  }

  Future<String?> getEmployeeTimeSheetData(DateTime date, User employee)async{
    try{
      var res = await sendPostRequest(
          AppConst.getTimeSheetData,
          user?.token,
          {'date': date.toString(),'user_id': employee.id.toString()}
      );
      Tools.consoleLog("[UserModel.getEmployeeTimeSheetData.res] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in body['punches']) punches.add(Punch.fromJson(punch));
        employee.punches = punches;

        List<WorkHistory> works = [];
        for(var work in body['works']) works.add(WorkHistory.fromJson(work));
        employee.works = works;

        List<EmployeeBreak> breaks = [];
        for(var b in body['breaks']) breaks.add(EmployeeBreak.fromJson(b));
        employee.breaks = breaks;
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      Tools.consoleLog("[UserModel.getEmployeeTimeSheetData.err] $e");
      return e.toString() ;
    }
  }

  Future<String?> notificationSetting()async{
    try{
      String? token = "disabled";
      if(user?.firebaseToken == null || user?.firebaseToken == "disabled"){
        token = await Tools.getFirebaseToken();
      }
      var res = await sendPostRequest(
        AppConst.notificationSetting,
        user?.token,
        {'token':token},
      );
      Tools.consoleLog("[UserModel.notificationSetting.res] ${res.body}");
      if(res.statusCode==200){
        user?.firebaseToken = token;
        saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[UserModel.notificationSetting.err]");
      return e.toString();
    }
  }

  changeAppLanguage(String lang)async{
    locale = lang;
    GlobalData.lang = lang;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', lang);
  }

  Future<String?> getYearTotalHours()async{
    try{
      var res = await sendGetRequest(
        AppConst.getYearTotalHours,
        user?.token,
      );
      Tools.consoleLog("[UserModel.getYearTotalHours.res] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode == 200){
        yearTotalHours = double.parse(body['total'].toString());
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      Tools.consoleLog("[UserModel.getYearTotalHours.err] $e");
      return e.toString() ;
    }
  }

  Future<User?> getUserInfoFromServer(String token)async{
    try{
      var res = await sendGetRequest( AppConst.getUserInfo, token);
      Tools.consoleLog('[UserModel.getUserInfoFromServer.res]${res.body}');
      if(res.statusCode == 200){
        return User.fromJson(jsonDecode(res.body));
      }
    }catch(e){
      Tools.consoleLog('[UserModel.getUserInfoFromServer.err]$e');
    }
    return null;
  }
}