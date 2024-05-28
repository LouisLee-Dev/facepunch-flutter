import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '/widgets/utils.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/company_model.dart';
import '/models/harvest_model.dart';
import '/providers/company_provider.dart';
import '/providers/harvest_provider.dart';

class HarvestReportScreen extends StatefulWidget{

  @override
  _HarvestReportScreenState createState() => _HarvestReportScreenState();
}

class _HarvestReportScreenState extends State<HarvestReportScreen>{

  DateTime selectedDate = DateTime.now();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  HTask? selectedTask;
  List<HarvestEmployeeStats> employeeStats = [];
  HarvestCompanyStats? companyStats;
  List<HarvestDateStats> dateStats = [];
  late Timer _timer;
  bool isFetchingDateStats = false;
  bool isShowEmployeeStats = true;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if(isShowEmployeeStats){
        _getEmployeeStats();
        _getCompanyStats();
      }else{
        _getDateStats();
      }
    });
    super.initState();
  }

  _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null){
      setState(() {selectedDate = picked;});
      _refreshController.requestRefresh();
    }
  }

  void _onRefresh() async{
    if(isShowEmployeeStats){
      await _getEmployeeStats();
      await _getCompanyStats();
    }else{
      await _getDateStats();
    }
    _refreshController.refreshCompleted();
  }

  _getEmployeeStats()async{
    if(selectedTask!=null){
      final result = await context.read<HarvestProvider>().getEmployeeHarvestStats(selectedDate.toString(), selectedTask?.fieldId);
      if(result is String){
        Tools.showErrorMessage(context, result);
      }else{
        employeeStats = result;
      }
      if(mounted)setState(() {});
    }
  }

  _getDateStats()async{
    final result = await context.read<HarvestProvider>().getDateHarvestStats(selectedDate.toString());
    if(result is String){
      Tools.showErrorMessage(context, result);
    }else{
      dateStats = result;
    }
    if(mounted)setState(() {});
  }

  double harvestTotalOfDate(){
    double total = 0;
    dateStats.forEach((d) {
      total += d.getTotalQuantity();
    });
    return total;
  }


  _getCompanyStats()async{
    if(selectedTask!=null){
      final result = await context.read<HarvestProvider>().getCompanyHarvestStats(selectedDate.toString(), selectedTask?.fieldId);
      if(result is String){
        Tools.showErrorMessage(context, result);
      }else{
        companyStats = result;
      }
      if(mounted)setState(() {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Color getLogColor(double avg, CompanySettings? settings){
    try{
      double lowValue = 2.5;
      double highValue = 3.0;
      Color lowColor = Color(0xFFe24c3c);
      Color mediumColor = Color(0xFFe2e03c);
      Color highColor = Color(0xFF6fe23c);
      if(settings != null){
        if(settings.lowValue != null)lowValue = double.parse(settings.lowValue!);
        if(settings.highValue != null)highValue = double.parse(settings.highValue!);
        if(settings.lowColor != null)lowColor = Color(int.parse(settings.lowColor!, radix: 16));
        if(settings.mediumColor != null)mediumColor = Color(int.parse(settings.mediumColor!, radix: 16));
        if(settings.highColor != null)highColor = Color(int.parse(settings.highColor!, radix: 16));
      }
      if(avg >= highValue) return highColor;
      if(avg >= lowValue) return mediumColor;
      return lowColor;
    }catch(e){
      Tools.consoleLog('[getLogColor]$e');
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<HTask> tasks = context.watch<HarvestProvider>().tasks;
    final settings = context.watch<CompanyProvider>().myCompanySettings;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(primaryColor),
        title: Text(S.of(context).harvestReport),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
                ),
                SizedBox(width: 10,),
                MaterialButton(
                  onPressed: _selectHarvestDate,
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: Colors.black)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(selectedDate.toString().split(' ')[0],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                ),
                SizedBox(width: 10,),
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
                ),
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Color(primaryColor)),borderRadius: BorderRadius.circular(50)),
            elevation: 8,
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      height: 70,
                      child: ListView(
                        children: [
                          for(var task in tasks)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: MaterialButton(
                                onPressed: (){
                                  setState(() {
                                    selectedTask = task;
                                    isShowEmployeeStats = true;
                                  });
                                  _refreshController.requestRefresh();
                                },
                                minWidth: 0,
                                shape: CircleBorder(),
                                color: selectedTask==task?Color(primaryColor):Colors.white,
                                clipBehavior: Clip.antiAlias,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${task.field?.shortName()}',
                                        style: TextStyle(
                                          color: selectedTask==task?Colors.white:Colors.black87
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: FittedBox(
                                          child: Text('${task.field?.crop}',
                                            style: TextStyle(
                                                color: selectedTask==task?Colors.white:Colors.black87
                                            ),
                                          ),
                                        )
                                      ),
                                      Text('${task.container?.shortName()}',
                                        style: TextStyle(
                                            color: selectedTask==task?Colors.white:Colors.black87
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MaterialButton(
                    onPressed: ()async{
                      setState(() {isShowEmployeeStats = !isShowEmployeeStats;});
                      if(!isShowEmployeeStats){
                        setState(() {isFetchingDateStats = true;});
                        await _getDateStats();
                        setState(() {isFetchingDateStats = false;});
                      }
                    },
                    height: 70,
                    minWidth: 0,
                    shape: CircleBorder(),
                    color: isShowEmployeeStats?Color(0xFFDDDDDD)
                        :Color(primaryColor),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: isFetchingDateStats?SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(backgroundColor: Colors.white, strokeWidth: 2,)
                    ):Icon(Icons.title),
                  ),
                )
              ],
            ),
          ),
          if(companyStats != null && isShowEmployeeStats)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(S.of(context).totalOfTheDay)
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(var container in companyStats!.containersOfDate??[])
                                Text('${container['quantity']} ${container['name']}'),
                            ],
                          )
                      ),
                      Flexible(
                          flex: 1,
                          child: Text('${companyStats!.dateAvg()} ${S.of(context).containerHour}'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).totalOfTheSeason)
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(var container in companyStats!.containersOfYear??[])
                                Text('${container['quantity']} ${container['name']}'),
                            ],
                          )
                      ),
                      Flexible(
                          child: Text('${companyStats!.yearAvg()} ${S.of(context).containerHour}')
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if(isShowEmployeeStats)
            Container(
              color: Color(primaryColor),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(S.of(context).employee,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(S.of(context).quantity,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(S.of(context).containerHour,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                  ),
                ],
              ),
            ),
          if(!isShowEmployeeStats)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(S.of(context).totalOfTheDay),
                      Text('${harvestTotalOfDate()} ${S.of(context).containers}'),
                    ],
                  ),
                ),
                Container(
                  color: Color(primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).field,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).container,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).quantity,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor)),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                children: isShowEmployeeStats?[
                  for(var stats in employeeStats)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: getLogColor(stats.avg(), settings),
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('${stats.employeeName}',style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                          ),
                          Expanded(
                              flex: 1,
                              child: Text('${stats.quantity}',style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                          ),
                          Expanded(
                              flex: 1,
                              child: Text('${stats.avg().toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                          ),
                        ],
                      ),
                    )
                ]:[
                  for(var stats in dateStats)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('${stats.fieldName}', textAlign: TextAlign.center,)
                          ),
                          Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  for(var container in stats.containers??[])
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(container['name'],textAlign: TextAlign.center,)
                                        ),
                                        Expanded(
                                            child: Text("${container['quantity']}",textAlign: TextAlign.center,)
                                        ),
                                      ],
                                    )
                                ],
                              )
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}