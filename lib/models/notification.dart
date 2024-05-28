import '/widgets/utils.dart';

class AppNotification {
  String? body;
  String? title;
  bool? seen;
  String? date;
  String? type;
  int? callId;
  int? scheduleId;
  int? revisionId;

  AppNotification.fromJsonFirebase(Map<String, dynamic> json) {
    try {
      var notification;
      if(json['data']!=null){
        notification = json['data']; // android
      }else{
        notification = json; // iOS real device
      }
      Tools.consoleLog("[AppNotification.fromJsonFirebase.res] $notification");
      body = notification['body'];
      title = notification['title'];
      type = notification['notify_type'];
      seen = false;
      date = DateTime.now().toString();
      callId = int.tryParse(notification['call_id'].toString());
      scheduleId = int.tryParse(notification['schedule_id'].toString());
      revisionId = int.tryParse(notification['revision_id'].toString());
    } catch (e) {
      Tools.consoleLog("[AppNotification.fromJsonFirebase.err]$e");
    }
  }

  bool hasCall(){
    return callId != null;
  }

  bool hasRevision(){
    return revisionId != null;
  }

}
