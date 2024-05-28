import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/providers/user_provider.dart';
import '/models/user_model.dart';
import '/widgets/pages/employee/revision_notification/my_revision_notification_tab.dart';
import '/widgets/pages/employee/revision_notification/team_revision_notification_tab.dart';

class EmployeeRevisions extends StatefulWidget {

  @override
  _EmployeeRevisionState createState() => _EmployeeRevisionState();
}

enum RevisionTab{
  My, Team
}

class _EmployeeRevisionState extends State<EmployeeRevisions> with SingleTickerProviderStateMixin{


  late TabController _tabController;


  RevisionTab _tab = RevisionTab.My;
  late User user;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    user = context.read<UserProvider>().user!;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            height: kToolbarHeight+MediaQuery.of(context).padding.top,
            alignment: Alignment.center,
            color: Color(primaryColor),
            child: Text(S.of(context).revisions, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
          ),
          if(!user.isEmployee())
            TabBar(
              controller: _tabController,
              labelColor: Color(primaryColor),
              onTap: (index){
                if(index == 0){
                  setState(() {
                    _tab = RevisionTab.My;
                  });
                }else{
                  setState(() {
                    _tab = RevisionTab.Team;
                  });
                }
              },
              tabs: [
                Tab(
                  child: Text(S.of(context).my),
                ),
                Tab(
                  child: Text(S.of(context).team),
                ),
              ]
            ),
          if (_tab == RevisionTab.My)
            MyRevisionNotificationTab(),
          if (_tab == RevisionTab.Team)
            TeamRevisionNotificationTab(),
        ],
      ),
    );
  }
}