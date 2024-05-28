import 'dart:convert';
import 'package:localstorage/localstorage.dart';

import '/widgets/utils.dart';
import 'base_provider.dart';
import '/models/revision_model.dart';
import '/config/app_const.dart';

class NotificationProvider extends BaseProvider {
  final LocalStorage storage = LocalStorage('notifications');
  List<Revision> revisions = [];


  Future<void> getNotificationFromServer()async{
    try{
      var res = await sendGetRequest(
          AppConst.getRevisionRequest,
          GlobalData.token
      );
      Tools.consoleLog("[NotificationModel.getNotificationFromServer.res] ${res.body}");
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        revisions.clear();
        for(var json in body){
          revisions.add(Revision.fromJson(json));
        }
        notifyListeners();
      }
    }catch(e){
      Tools.consoleLog("[NotificationModel.getNotificationFromServer.res] $e");
    }
  }

  removeRevision(Revision revision){
    revisions.removeWhere((r) => r.id == revision.id);
    notifyListeners();
  }
}