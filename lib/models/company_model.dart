import '/widgets/utils.dart';



class Company {
  int? id;
  int? adminId;
  String? name;
  int? plan;
  String? createdAt;
  String? updatedAt;

  Company({
    this.id,
    this.adminId,
    this.name,
    this.plan,
    this.createdAt,
    this.updatedAt
  });

  Company.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      adminId = json['admin_id'];
      name = json['name'];
      plan = json['plan'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog("[User.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['plan'] = this.plan;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CompanySettings{
  String? lowValue;
  String? lowColor;
  String? mediumColor;
  String? highValue;
  String? highColor;
  String? lastUpdated;
  String? reportTime;
  bool? hasNFCHarvest;
  bool? hasNFCReport;
  bool? hasHarvestReport;
  bool? hasTimeSheetRevision;
  bool? hasTimeSheetSchedule;
  bool? hasGeolocationPunch;
  bool? useOwnData;

  bool? receivePunchNotification;
  bool? receiveRevisionNotification;



  CompanySettings({
    this.lowValue,
    this.lowColor,
    this.mediumColor,
    this.highValue,
    this.highColor,
    this.lastUpdated,
    this.reportTime,
    this.hasNFCHarvest,
    this.hasNFCReport,
    this.hasHarvestReport,
    this.hasTimeSheetRevision,
    this.hasTimeSheetSchedule,
    this.hasGeolocationPunch,
    this.receivePunchNotification,
    this.receiveRevisionNotification,
  });

  CompanySettings.fromJson(Map<String, dynamic> json){
    try{
      lowValue = json['low_value'];
      lowColor = json['low_color'];
      mediumColor = json['medium_color'];
      highValue = json['high_value'];
      highColor = json['high_color'];
      lastUpdated = json['last_updated'];
      reportTime = json['report_time'];
      receivePunchNotification = json['receive_punch_notification']==null || json['receive_punch_notification']=='1';
      receiveRevisionNotification = json['receive_revision_notification']==null || json['receive_revision_notification']=='1';

      hasNFCHarvest = json['has_nfc_harvest']!=null && json['has_nfc_harvest']=='1';
      hasNFCReport = json['has_nfc_report']!=null && json['has_nfc_report']=='1';
      hasHarvestReport = json['has_harvest_report']!=null && json['has_harvest_report']=='1';
      hasTimeSheetRevision = json['has_time_sheet_revision']!=null && json['has_time_sheet_revision']=='1';
      hasTimeSheetSchedule = json['has_time_sheet_schedule']!=null && json['has_time_sheet_schedule']=='1';
      hasGeolocationPunch = json['has_geolocation_punch']!=null && json['has_geolocation_punch']=='1';
      useOwnData = json['use_own_data']!=null && json['use_own_data']=='1';
    }catch(e){
      Tools.consoleLog('[CompanySettings.fromJson.err]$e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.lowValue != null)data['low_value'] = this.lowValue;
    if(this.lowColor != null)data['low_color'] = this.lowColor;
    if(this.mediumColor != null)data['medium_color'] = this.mediumColor;
    if(this.highValue != null)data['high_value'] = this.highValue;
    if(this.highColor != null)data['high_color'] = this.highColor;
    if(this.reportTime != null)data['report_time'] = this.reportTime;
    if(this.lastUpdated != null)data['last_updated'] = this.lastUpdated;
    if(this.receivePunchNotification != null)data['receive_punch_notification'] = this.receivePunchNotification!?'1':'0';
    if(this.receiveRevisionNotification != null)data['receive_revision_notification'] = this.receiveRevisionNotification!?'1':'0';

    if(this.hasNFCHarvest != null)data['has_nfc_harvest'] = this.hasNFCHarvest!?'1':'0';
    if(this.hasNFCReport != null)data['has_nfc_report'] = this.hasNFCReport!?'1':'0';
    if(this.hasHarvestReport != null)data['has_harvest_report'] = this.hasHarvestReport!?'1':'0';
    if(this.hasTimeSheetRevision != null)data['has_time_sheet_revision'] = this.hasTimeSheetRevision!?'1':'0';
    if(this.hasTimeSheetSchedule != null)data['has_time_sheet_schedule'] = this.hasTimeSheetSchedule!?'1':'0';
    if(this.hasGeolocationPunch != null)data['has_geolocation_punch'] = this.hasGeolocationPunch!?'1':'0';
    if(this.useOwnData != null)data['use_own_data'] = this.useOwnData!?'1':'0';

    return data;
  }

}