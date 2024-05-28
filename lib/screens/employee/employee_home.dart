import 'package:facepunch/models/company_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/notification.dart';
import '/config/app_const.dart';
import '/widgets/utils.dart';
import '/lang/l10n.dart';
import '/screens/admin/nfc/nfc_scan.dart';
import 'call_detail.dart';
import 'employee_document.dart';
import 'employee_timesheet.dart';
import 'employee_dispatch.dart';
import 'employee_daily_tasks.dart';
import 'employee_revisions.dart';
import '/screens/admin/nfc/harvest_report.dart';
import '/providers/company_provider.dart';
import '/providers/harvest_provider.dart';
import '/providers/user_provider.dart';
import '/providers/work_provider.dart';
import '/models/user_model.dart';

class EmployeeHomePage extends StatefulWidget {

  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;
  late User user;
  CompanySettings? settings;

  @override
  void initState() {
    super.initState();
    Tools.setupFirebaseNotification(_onMessage);
    _fetchData();
    user = context.read<UserProvider>().user!;
  }

  _onMessage(message){
    try{
      if(mounted){
        AppNotification notification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        VoidCallback? onOpen;
        if(notification.hasCall()){
          onOpen = (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=>CallDetailScreen(notification.callId!)));
          };
        }else if(notification.hasRevision()){
          int _revisionPage = 3;
          if(user.hasNTCTracking()){
            _revisionPage++;
          }
          if((settings?.hasHarvestReport??false) && user.isManager()){
            _revisionPage++;
          }
          if(user.canManageDispatch()){
            _revisionPage++;
          }
          onOpen = (){
            _pageController.jumpToPage(_revisionPage);
            setState(() {index = _revisionPage;});
          };
        }
        Tools.showNotificationDialog(notification, context, onOpen);
      }
    }catch(e){
      Tools.consoleLog('[EmployeeHome._onMessage]$e');
    }
  }

  _fetchData()async{
    await context.read<WorkProvider>().getProjectsAndTasks();
    final user = context.read<UserProvider>().user;
    if(user?.canManageDispatch()??false){
      await context.read<CompanyProvider>().getCompanyUsers();
    }
    await context.read<UserProvider>().getYearTotalHours();
    await context.read<HarvestProvider>().getHarvestData();
  }

  @override
  Widget build(BuildContext context) {
    settings = context.watch<CompanyProvider>().myCompanySettings;

    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: PageView(
          children: [
            EmployeeTimeSheet(),
            EmployeeDocument(),
            if(user.hasNTCTracking())
              NFCScanPage(),
            if((settings?.hasHarvestReport??false) && user.isManager())
              HarvestReportScreen(),
            EmployeeDailyTasks(),
            if(user.canManageDispatch())
              EmployeeDispatch(),
            EmployeeRevisions()
          ],
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (i){
            setState(() {index = i; });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_calendar.png",width: 30,),
              activeIcon: Image.asset("assets/images/ic_calendar.png",width: 30,color: Color(primaryColor),),
              label: S.of(context).calender
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_document.png",width: 30,),
              activeIcon: Image.asset("assets/images/ic_document.png",width: 30,color: Color(primaryColor),),
              label: S.of(context).document
          ),
          if(user.hasNTCTracking())
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/nfc.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/nfc.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).nfc
            ),
          if((settings?.hasHarvestReport??false) && user.isManager())
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/ic_harvest.png', color: Colors.black, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/ic_harvest.png', color: Color(primaryColor),width: 30, height: 30,),
                label: S.of(context).harvestReport
            ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Colors.black,),
              activeIcon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Color(primaryColor),),
              label: S.of(context).schedule
          ),
          if(user.canManageDispatch())
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).dispatch
            ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_revision.png", width: 30,color: Colors.black,),
              activeIcon: Image.asset("assets/images/ic_revision.png", width: 30,color: Color(primaryColor),),
              label: S.of(context).nfc
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