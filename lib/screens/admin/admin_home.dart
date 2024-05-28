import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/company_model.dart';
import '/models/notification.dart';
import '/models/user_model.dart';
import '/screens/admin/employee_list.dart';
import '/widgets/utils.dart';
import 'create_edit_employee.dart';
import 'nfc/harvest_report.dart';
import 'nfc/nfc_scan.dart';
import 'admin_settings.dart';
import '/providers/company_provider.dart';
import '/providers/harvest_provider.dart';
import '/providers/user_provider.dart';
import '/providers/work_provider.dart';

class AdminHomePage extends StatefulWidget {

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;
  CompanySettings? settings;

  @override
  void initState() {
    super.initState();
    Tools.setupFirebaseNotification(_onMessage);
    _fetchCompanyData();
  }

  _fetchCompanyData()async{
    await context.read<WorkProvider>().getProjectsAndTasks();
    await context.read<HarvestProvider>().getHarvestData();
  }

  _onMessage(message){
    try{
      if(mounted){
        AppNotification newNotification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        VoidCallback? onOpen;
        switch (newNotification.type){
          case 'revision_request':
            onOpen = (){
              Navigator.pop(context);
              _pageController.jumpToPage(1);
            };
            break;
        }
        Tools.showNotificationDialog(newNotification, context, onOpen);
      }
    }catch(e){
      Tools.consoleLog('[AdminHome._onMessage]$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    settings = context.watch<CompanyProvider>().myCompanySettings;
    if(user == null) return Container();

    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: PageView(
          children: [
            EmployeeList(),
            if(settings?.useOwnData??false)
              CreateEditEmployee(pageController: _pageController,),
            if(settings?.hasNFCHarvest??false)
              NFCScanPage(),
            if(settings?.hasHarvestReport??false)
              HarvestReportScreen(),
            AdminSetting(),
          ],
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (i){
            setState(() { index = i; });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset('assets/images/ic_dashboard.png', color: Colors.grey, width: 30, height: 30,),
              activeIcon: Image.asset('assets/images/ic_dashboard.png', color: Color(primaryColor), width: 30, height: 30,),
              label: S.of(context).calender
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              activeIcon: Icon(Icons.notifications, color: Color(primaryColor),),
              label: S.of(context).notifications
          ),
          if(settings?.useOwnData??false)
            BottomNavigationBarItem(
                icon: Icon(Icons.person_add),
                activeIcon: Icon(Icons.person_add, color: Color(primaryColor),),
                label: S.of(context).employee
            ),
          if(settings?.hasNFCHarvest??false)
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/nfc.png', color: Colors.grey, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/nfc.png', color: Color(primaryColor), width: 30, height: 30,),
                label: S.of(context).nfc
            ),
          if(settings?.hasHarvestReport??false)
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/ic_harvest.png', color: Colors.grey, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/ic_harvest.png', color: Color(primaryColor),width: 30, height: 30,),
                label: S.of(context).harvestReport
            ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              activeIcon: Icon(Icons.settings, color: Color(primaryColor),),
              label: S.of(context).setting
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: index,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: (i){
          _pageController.jumpToPage(i);
          setState(() {index = i;});
        },
      ),
      backgroundColor: Color(0xFFf4f4f4),
      resizeToAvoidBottomInset: true,
    );
  }

}