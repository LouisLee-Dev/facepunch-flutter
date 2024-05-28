import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/screens/home_page.dart';
import '/models/user_model.dart';
import '/screens/admin/admin_home.dart';
import '/screens/employee/employee_home.dart';
import '/config/app_const.dart';
import '/widgets/utils.dart';
import '/providers/app_provider.dart';
import '/providers/company_provider.dart';
import '/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _init();
  }

  _init()async{
    try{
      final appVersions = await context.read<AppProvider>().getAppVersions();
      if(appVersions != null){
        if(appVersions[Platform.isAndroid?'android':'ios'] > AppConst.currentVersion){
          await Tools.checkAppVersionDialog(context, appVersions['force']);
        }
      }
      User? user  = await context.read<UserProvider>().getUserFromLocal();
      if(user == null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }else{
        bool result = await context.read<CompanyProvider>().getMyCompany(user.companyId);
        if(result){
          if(user.isAdmin()){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
          }
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
        }
      }
    }catch(e){
      Tools.consoleLog("[SplashScreen._init.err]$e");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          child: Stack(
            children: [
              Positioned(
                top: height/4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png",width: width/3, color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("FACE\nPUNCH",style: TextStyle(fontWeight: FontWeight.w500, fontSize: 50, color: Colors.white),)
                  ],
                ),
              ),
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                    child: Text(
                      S.of(context).timeSheetSystemForEmployee,
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500, color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}