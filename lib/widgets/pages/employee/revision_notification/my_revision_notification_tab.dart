import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '/widgets/utils.dart';
import '/models/revision_model.dart';
import '/models/user_model.dart';
import 'revision_notification_item.dart';
import '/config/app_const.dart';
import '/lang/l10n.dart';
import '/providers/user_provider.dart';

class MyRevisionNotificationTab extends StatefulWidget {

  @override
  _MyRevisionNotificationTabState createState() => _MyRevisionNotificationTabState();
}

class _MyRevisionNotificationTabState extends State<MyRevisionNotificationTab>{
  RefreshController _myRefreshController = RefreshController(initialRefresh: true);
  List<Revision> _myRevisions = [];
  late User user;


  @override
  void initState() {
    user = context.read<UserProvider>().user!;
    super.initState();
  }

  _onRefreshMyRevision()async{
    try{
      _myRevisions = await user.getMyRevisionNotifications();
      if(!mounted) return;
      _myRefreshController.refreshCompleted();
      setState(() {});
    }catch(e){
      Tools.consoleLog('[EmployeeRevisions._onRefreshMyRevision]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
        controller: _myRefreshController,
        onRefresh: _onRefreshMyRevision,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for(Revision revision in _myRevisions)
                RevisionNotificationItem(revision, key: Key('my_revision_notification_${revision.id}'),),
              if(_myRevisions.isEmpty)
                Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.center,
                    child: Text(S.of(context).empty, style: TextStyle(fontSize: 20),)
                )
            ],
          ),
        ),
      ),
    );
  }
}