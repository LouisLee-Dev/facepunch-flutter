import 'dart:convert';
import '../config/app_const.dart';
import 'user_model.dart';
import '/widgets/utils.dart';
import '/providers/base_provider.dart';


class Harvest with HttpRequest{
  int? id;
  int? userId;
  int? fieldId;
  int? containerId;
  int? companyId;
  double? quantity;
  String? createdAt;
  String? updatedAt;
  User? user;
  HContainer? container;
  Field? field;

  Harvest.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      userId = json['user_id'];
      fieldId = json['field_id'];
      containerId = json['container_id'];
      companyId = json['company_id'];
      quantity = double.tryParse(json['quantity'].toString());
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      if(json['user']!=null)user = User.fromJson(json['user']);
      if(json['field']!=null)field = Field.fromJson(json['field']);
      if(json['container']!=null)container = HContainer.fromJson(json['container']);
    }catch(e){
      Tools.consoleLog("[Harvest.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['field_id'] = this.fieldId;
    data['container_id'] = this.containerId;
    data['company_id'] = this.companyId;
    data['quantity'] = this.quantity;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  Future<String?> update(double quantity)async{
    try{
      var res = await sendPostRequest(
          AppConst.updateHarvest,
          GlobalData.token,
          {
            'id':id,
            'quantity': quantity
          }
      );
      Tools.consoleLog("[Field.update.res] ${res.body}");
      if(res.statusCode == 200){
        this.quantity = quantity;
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[Field.update.err] $e");
    }
  }
}

class HTask{
  int? id;
  int? companyId;
  int? containerId;
  int? fieldId;
  Field? field;
  HContainer? container;

  HTask({
    this.id,
    this.companyId,
    this.containerId,
    this.fieldId,
    this.field,
    this.container,
  });

  HTask.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      companyId = json['company_id'];
      containerId = json['container_id'];
      fieldId = json['field_id'];
      if(json['field']!=null)field = Field.fromJson(json['field']);
      if(json['container']!=null)container = HContainer.fromJson(json['container']);
    }catch(e){
      Tools.consoleLog("[Field.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['container_id'] = this.containerId;
    data['field_id'] = this.fieldId;
    data['field'] = this.field?.toJson();
    data['container'] = this.container?.toJson();
    return data;
  }

}

class HContainer{
  int? id;
  String? name;
  int? companyId;
  String? createdAt;
  String? updatedAt;

  HContainer({this.id,this.name,this.companyId,this.createdAt,this.updatedAt});

  HContainer.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      companyId = json['company_id'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog("[Field.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['company_id'] = this.companyId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  String shortName(){
    if(name == null && name!.isEmpty) return '';
    return name![0].toUpperCase();
  }

}

class Field{
  int? id;
  String? name;
  String? crop;
  String? cropVariety;
  int? companyId;
  String? createdAt;
  String? updatedAt;

  Field({
    this.id,
    this.name,
    this.crop,
    this.cropVariety,
    this.companyId,
    this.createdAt,
    this.updatedAt
  });

  Field.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      crop = json['crop'];
      cropVariety = json['crop_variety'];
      companyId = json['company_id'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog("[Field.fromJson.err] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['crop'] = this.crop;
    data['crop_variety'] = this.cropVariety;
    data['company_id'] = this.companyId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  String shortName(){
    if(name == null || name!.isEmpty) return '';
    return name!.substring(0, (name!.length > 1 ? 2 : name!.length)).toUpperCase();
  }
}

class HarvestEmployeeStats{
  int? userId;
  String? employeeName;
  double? time;
  double? quantity;

  HarvestEmployeeStats.fromJson(Map<String, dynamic> json){
    try{
      userId = json['id'];
      employeeName = json['name'];
      time = double.tryParse(json['time'].toString())??0.0;
      quantity = double.tryParse(json['quantity'].toString())??0.0;
    }catch(e){
      Tools.consoleLog('[HarvestEmployeeStats.fromJson.err]$e');
    }
  }

  double avg(){
    if(quantity == null || quantity == 0) return 0;
    if(time == null || time == 0) return 0;
    return quantity! / time!;
  }
}

class HarvestCompanyStats{
  double? harvestTimeOfDate;
  double? harvestTimeOfYear;
  double? quantityOfDate;
  double? quantityOfYear;
  List? containersOfDate;
  List? containersOfYear;

  HarvestCompanyStats.fromJson(Map<String, dynamic> json){
    try{
      harvestTimeOfDate = double.tryParse(json['date_stats']['time'].toString())??0.0;
      harvestTimeOfYear = double.tryParse(json['year_stats']['time'].toString())??0.0;
      quantityOfDate = double.tryParse(json['date_stats']['quantity'].toString())??0.0;
      quantityOfYear = double.tryParse(json['year_stats']['quantity'].toString())??0.0;
      containersOfDate = json['date_stats']['containers'];
      containersOfYear = json['year_stats']['containers'];
    }catch(e){
      Tools.consoleLog('[HarvestCompanyStats.fromJson.err]$e');
    }
  }

  String dateAvg(){
    if(quantityOfDate != null || quantityOfDate == 0) return '0.00';
    if(harvestTimeOfDate != null || harvestTimeOfDate == 0) return '0.00';
    return (quantityOfDate! / harvestTimeOfDate!).toStringAsFixed(2);
  }

  String yearAvg(){
    if(harvestTimeOfYear != null || harvestTimeOfYear == 0) return '0.00';
    if(harvestTimeOfYear != null || harvestTimeOfYear == 0) return '0.00';
    return (quantityOfYear! / harvestTimeOfYear!).toStringAsFixed(2);
  }

}

class HarvestDateStats{
  int? fieldId;
  String? fieldName;
  List? containers;

  HarvestDateStats.fromJson(Map<String, dynamic> json){
    try{
      fieldId = json['id'];
      fieldName = json['name'];
      containers = json['containers'];
    }catch(e){
      Tools.consoleLog('[HarvestDateStats.fromJson.err]$e');
    }
  }

  double getTotalQuantity(){
    double quantity = 0;
    try{
      if(containers != null){
        for(var c in containers!){
          quantity += double.tryParse(c['quantity'].toString())??0;
        }
      }
    }catch(e){
      Tools.consoleLog('[HarvestCompanyStats.getTotalQuantity.err]$e');
    }
    return quantity;
  }
}