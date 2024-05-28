
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '/widgets/utils.dart';
import '/models/user_model.dart';
import '/providers/user_provider.dart';
import 'revision_notification_item.dart';
import '/config/app_const.dart';
import '/lang/l10n.dart';
import '/models/revision_model.dart';

class TeamRevisionNotificationTab extends StatefulWidget{

  @override
  _TeamRevisionNotificationTabState createState() => _TeamRevisionNotificationTabState();
}

class _TeamRevisionNotificationTabState extends State<TeamRevisionNotificationTab>{
  DateTime _startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime _endDate = DateTime.parse("${DateTime.now().year}-12-31");
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  late User user;
  DateTime _date = DateTime.now();
  bool isWeek = true;
  List<Revision> _teamRevisions = [];

  @override
  void initState() {
    user = context.read<UserProvider>().user!;
    super.initState();
  }

  _onRefreshTeamRevision()async{
    try{
      _teamRevisions = await user.getTeamRevisionNotifications(_date.toString(), isWeek);
      if(!mounted) return;
      _refreshController.refreshCompleted();
      setState(() {});
    }catch(e){
      Tools.consoleLog('[EmployeeRevisions._onRefreshTeamRevision]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null){
      setState(() {_date = picked;});
      _refreshController.requestRefresh();
    }
  }

  _selectWeek(){
    final width = MediaQuery.of(context).size.width;
    DateTime _selectWeekDate = _date;
    showDialog(context: context, builder: (c){
      return StatefulBuilder(
        builder:(_, _setState)=> AlertDialog(
          content: Container(
            child: WeekPicker(
                selectedDate: _selectWeekDate,
                onChanged: (v){
                  _setState(() { _selectWeekDate = v.start.add(Duration(days: 3)); });
                },
                firstDate: _startDate,
                lastDate: _endDate,
                datePickerLayoutSettings: DatePickerLayoutSettings(
                    contentPadding: EdgeInsets.zero,
                    dayPickerRowHeight: 30,
                    monthPickerPortraitWidth: width,
                    maxDayPickerRowCount: 7,
                    scrollPhysics: NeverScrollableScrollPhysics()
                ),
                datePickerStyles: DatePickerRangeStyles(
                  selectedPeriodLastDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20.0)),
                  ),
                  selectedPeriodStartDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20.0)),
                  ),
                  selectedPeriodMiddleDecoration: BoxDecoration(color: Color(primaryColor)),
                  currentDateStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 18),
                  defaultDateTextStyle: TextStyle(fontSize: 16),
                )
            ),
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    _date = _selectWeekDate;
                  });
                  Navigator.pop(context);
                  _refreshController.requestRefresh();
                },
                child: Text(S.of(context).ok)
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
        controller: _refreshController,
        onRefresh: _onRefreshTeamRevision,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (){
                        setState(() {
                          if(isWeek){
                            _date = _date.subtract(Duration(days: 7));
                          }else{
                            _date = _date.subtract(Duration(days: 1));
                          }
                        });
                        _refreshController.requestRefresh();
                      },
                      child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
                    ),
                    SizedBox(width: 10,),
                    if(isWeek)
                      MaterialButton(
                        onPressed: _selectWeek,
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: Colors.black)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text('${PunchDateUtils.getStartOfCurrentWeek(_date).toString().substring(0, 10)} ~ ${PunchDateUtils.getEndOfCurrentWeek(_date).toString().substring(0, 10)}',
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                        ),
                      ),
                    if(!isWeek)
                      MaterialButton(
                        onPressed: _selectDate,
                        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: Colors.black)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text(_date.toString().split(' ')[0],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                      ),
                    SizedBox(width: 10,),
                    TextButton(
                      onPressed: (){
                        setState(() {
                          if(isWeek){
                            _date = _date.add(Duration(days: 7));
                          }else{
                            _date = _date.add(Duration(days: 1));
                          }
                        });
                        _refreshController.requestRefresh();
                      },
                      child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                        value: true,
                        groupValue: isWeek,
                      onChanged: (v){
                        setState(() { isWeek = true;});
                      },
                    ),
                    InkWell(
                      onTap: (){
                        setState(() { isWeek = true;});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                        child: Text(S.of(context).week,),
                      ),
                    ),
                    SizedBox(width: 8,),
                    Radio(
                      value: false,
                      groupValue: isWeek,
                      onChanged: (v){
                        setState(() { isWeek = false;});
                      },
                    ),
                    InkWell(
                      onTap: (){
                        setState(() { isWeek = false;});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                        child: Text(S.of(context).day,),
                      ),
                    ),
                  ],
                ),
              ),
              for(Revision revision in _teamRevisions)
                RevisionNotificationItem(
                  revision,
                  onSubmit: (){
                    _refreshController.requestRefresh();
                  },
                  isManager: true,
                  key: Key('team_revision_notification_${revision.id}'),
                ),
              if(_teamRevisions.isEmpty)
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