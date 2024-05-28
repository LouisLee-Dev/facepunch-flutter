import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import 'face_punch/start_face_punch.dart';
import '/widgets/utils.dart';
import '/screens/face_login.dart';
import '/providers/app_provider.dart';
import '/providers/user_provider.dart';

class HomePage extends StatefulWidget{

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin<HomePage>{

  static const EMPLOYEE_SIGN_IN =0;
  static const FACE_PUNCH =1;

  late TabController _tabController;
  int _pageIndex = FACE_PUNCH;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: FACE_PUNCH);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    double imageSize = isShowKeyBoard?50:120;
    double width = MediaQuery.of(context).size.width;
    double borderRadius = 16.0;
    double iconSize = 16.0;
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      spreadRadius: 1,
      blurRadius: 1,
      offset: Offset(0, 0),
    );
    String lang = context.watch<UserProvider>().locale;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton(
            itemBuilder: (_)=><PopupMenuItem<String>>[
              PopupMenuItem<String>(
                  child: Text('English'),
                  value: 'en'
              ),
              PopupMenuItem<String>(
                  child: Text('Spanish'),
                  value: 'es'
              ),
              PopupMenuItem<String>(
                  child: Text('French'),
                  value: 'fr'
              ),
            ],
            padding: EdgeInsets.zero,
            onSelected: (l){
              context.read<UserProvider>().changeAppLanguage(l.toString());
            },
            child: Container(
              child: Text(lang.toUpperCase(),style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 8),
            ),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onLongPress: ()async{
                      if(await Tools.confirmDialog(context, 'Are you going to switch app mode?')){
                        context.read<AppProvider>().switchDebug();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: imageSize,
                        height: imageSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if(!isShowKeyBoard)
                Column(
                  children: [
                    Text(
                      S.of(context).welcomeToFacePunch,
                      style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4,),
                    Text(
                      S.of(context).theBestEmployeeClockingSystem.toUpperCase(),
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4,),
                  ],
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top:  Radius.circular(20)),
                  color: Colors.white
                ),
                height: MediaQuery.of(context).size.height*0.6-kBottomNavigationBarHeight,
                child: TabBarView(
                  children: [
                    FaceLogin(),
                    StartFacePunch(),
                  ],
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight+10,
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: TabBar(
          controller: _tabController,
          onTap: (i){
            setState(() { _pageIndex = i;});
          },
          indicatorPadding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          indicatorColor: Colors.blue,
          tabs: [
            Container(
              width: width/2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex == EMPLOYEE_SIGN_IN?Color(primaryColor):Colors.white.withOpacity(0.8),
                  boxShadow: [shadow]
              ),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: iconSize, color: _pageIndex == EMPLOYEE_SIGN_IN ? Colors.white : Colors.black,),
                  SizedBox(height: 8,),
                  Text(
                    S.of(context).employeePortal,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _pageIndex == EMPLOYEE_SIGN_IN ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Container(
              width: width/2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex == FACE_PUNCH?Color(primaryColor):Colors.white,
                  boxShadow: [
                    shadow,
                  ]
              ),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: iconSize, color: _pageIndex == FACE_PUNCH ? Colors.white : Colors.black,),
                  SizedBox(height: 8,),
                  Text(
                    S.of(context).facePunch,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _pageIndex == FACE_PUNCH ? Colors.white : Colors.black,),
                    textAlign: TextAlign.center,)
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
      extendBodyBehindAppBar: true,
    );
  }
}