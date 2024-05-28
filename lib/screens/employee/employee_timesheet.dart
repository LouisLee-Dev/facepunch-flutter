import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '/screens/admin/admin_settings.dart';
import '/screens/admin/employee_list.dart';
import '/screens/bug_report_page.dart';
import '/widgets/TimeEditor.dart';
import '/widgets/project_picker.dart';
import '/widgets/task_picker.dart';
import '/widgets/utils.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/screens/home_page.dart';
import '/widgets/calendar_strip/calendar_strip.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/providers/revision_provider.dart';
import '/providers/user_provider.dart';
import '/providers/work_provider.dart';

class EmployeeTimeSheet extends StatefulWidget {

  @override
  _EmployeeTimeSheetState createState() => _EmployeeTimeSheetState();
}

class _EmployeeTimeSheetState extends State<EmployeeTimeSheet> {
  DateTime startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime endDate = DateTime.parse("${DateTime.now().year}-12-31");
  DateTime selectedDate = DateTime.now();
  User? user;
  DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
  Map<String, List<Punch>> selectedPunches = {};
  late RefreshController _refreshController;
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  @override
  void initState() {
    super.initState();
    user = context.read<UserProvider>().user;
    if(user?.punches == null || user!.punches.isEmpty){
      _refreshController = RefreshController(initialRefresh: true);
    }else{
      _refreshController = RefreshController(initialRefresh: false);
      selectedPunches = user!.getPunchesGroupOfWeek(startOfWeek);
    }
  }

  onSelect(date) {
    List<Punch> punchesOfDate = user!.getPunchesOfDate(date);
    selectedPunches = {'${date.toString()}':punchesOfDate};
    setState(() { selectedDate = date;});
  }

  onWeekSelect(date) {
    setState(() { startOfWeek = date;});
    _refreshController.requestRefresh();
  }

  dateTileBuilder(date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
    TextStyle normalStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fontColor);
    TextStyle dayNameStyle = TextStyle(fontSize: 12, color: fontColor);
    List<Widget> _children = [
      Text(dayName, style: dayNameStyle),
      Container(
          decoration: BoxDecoration(
            color: !isSelectedDate ? Colors.transparent : Color(primaryColor),
            shape: BoxShape.circle
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Text(date.day.toString(), style: normalStyle, maxLines: 1,)
      ),
      Text("${PunchDateUtils.convertHoursToString(user!.calculateHoursOfDate(date))}", style: TextStyle(fontSize: 12),),
    ];
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: _children,
      ),
    );
  }

  Widget monthNameWidget(String weekNumber, String monthName){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthName, style: TextStyle(fontWeight: FontWeight.bold,),),
          Text(weekNumber, style: TextStyle(fontWeight: FontWeight.bold,),)
        ],
      ),
    );
  }


  List<Widget> employeeLogs(){
    TextStyle logStyle = TextStyle(fontSize: 14);
    List<Widget> logs = [];
    selectedPunches.forEach((date, punches) {
      if(punches.isNotEmpty){
        List<Widget> punchDetail = [];
        for(var punchIn in punches){
          punchDetail.add(
              InkWell(
                onTap: (){
                  if(punchIn.isSent()){
                    Tools.showErrorMessage(context, S.of(context).thisPunchHasBeenSentAlready);
                  }else{
                    _showPunchRevisionDialog(punchIn);
                  }
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      punchIn.title(context),
                      style: logStyle,
                    )
                ),
              )
          );
          final works = user!.worksOfPunch(punchIn);
          works.forEach((work) {
            punchDetail.add(InkWell(
              onTap: (){
                if(work.isEnd())_showWorkRevisionDialog(work);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    work.title(),
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
              ),
            ));
          });
          final breaks = user!.breaksOfPunch(punchIn);
          breaks.forEach((b) {
            punchDetail.add(InkWell(
              onTap: (){_showBreakRevisionDialog(b);},
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    b.getTitle(context),
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
              ),
            ));
          });

          Punch? punchOut = user!.getPunchOut(punchIn);
          if(punchOut != null){
            punchDetail.add(
                InkWell(
                  onTap: (){
                    if(punchIn.isSent() || punchOut.isSent()){
                      Tools.showErrorMessage(context, S.of(context).thisPunchHasBeenSentAlready);
                    }else{
                      _showPunchRevisionDialog(punchOut);
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        punchOut.title(context),
                        style: logStyle,
                      )
                  ),
                )
            );
          }
        }

        punchDetail.add(
            Text(
              "${S.of(context).total}: ${PunchDateUtils.convertHoursToString(user!.getHoursOfDate(DateTime.parse(date)))} - ${PunchDateUtils.convertHoursToString(user!.getBreakTime(DateTime.parse(date)))} (${S.of(context).breaks}) = ${PunchDateUtils.convertHoursToString(user!.calculateHoursOfDate(DateTime.parse(date)))}",
              style: TextStyle(color: Color(primaryColor), fontWeight: FontWeight.bold, fontSize: 16),
            )
        );
        logs.add(
            Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey,))
              ),
              padding: EdgeInsets.all(2),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text("${PunchDateUtils.getDateString(date)}",style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                  Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: punchDetail.reversed.toList(),
                      )
                  ),
                ],
              ),
            )
        );
      }
    });
    return logs.reversed.toList();
  }

  _showPunchRevisionDialog(Punch punch){
    if(punch.createdAt == null) return;
    String? correctTime = punch.createdAt;
    String description = '';
    String? errorMessage;
    bool _isSending = false;

    showDialog(
      context: context,
      builder:(_)=> WillPopScope(
        onWillPop: ()async{
          return !_isSending;
        },
        child: StatefulBuilder(
            builder: (BuildContext _context, StateSetter _setState){
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.zero,
                scrollable: true,
                content: Container(
                  width: MediaQuery.of(context).size.width-50,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).hourRevisionRequest, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),),
                      SizedBox(height: 16,),
                      TimeEditor(
                        label: S.of(context).correctPunchTime,
                        initTime: punch.createdAt,
                        onChanged: (v){
                          _setState(() { correctTime = v;});
                        },
                      ),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: S.of(context).description,
                            alignLabelWithHint: true,
                            errorText: errorMessage
                        ),
                        minLines: 3,
                        maxLines: null,
                        onChanged: (v){
                          _setState(() {description = v;});
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: ()async{
                      if(!_isSending && correctTime != null){
                        if(description.isNotEmpty){
                          _setState(() { _isSending=true; });
                          await _sendPunchRevisionRequest(punch.id, correctTime!, punch.createdAt, description);
                          Navigator.pop(_context);
                        }else{
                          _setState(() {
                            errorMessage = S.of(context).youMustWriteDescription;
                          });
                        }
                      }
                    },
                    child: _isSending
                        ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                        :Text(S.of(context).submit,style: TextStyle(color: Colors.red ),),
                  )
                ],
              );
            }
        ),
      )
    );
  }

  _showBreakRevisionDialog(EmployeeBreak employeeBreak){
    EmployeeBreak newBreak = EmployeeBreak.fromJson(employeeBreak.toJson());
    String description = '';
    String? errorMessage;
    bool _isSending = false;
    TextEditingController _length = TextEditingController(text: newBreak.length.toString());

    showDialog(
        context: context,
        builder:(_)=> WillPopScope(
          onWillPop: ()async{
            return !_isSending;
          },
          child: StatefulBuilder(
            builder: (_context, StateSetter _setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.zero,
                scrollable: true,
                content: Container(
                  width: MediaQuery.of(context).size.width-50,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).hourRevisionRequest, style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(height: 12,),
                      TimeEditor(
                        label: S.of(context).correctBreakTime,
                        initTime: employeeBreak.start,
                        onChanged: (v){
                          _setState(() { newBreak.start = v;});
                        },
                      ),
                      SizedBox(height: 8,),
                      TextField(
                        key: Key('break_length_input_${newBreak.id}'),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: "${S.of(context).length} (m)",
                            alignLabelWithHint: true
                        ),
                        keyboardType: TextInputType.number,
                        controller: _length,
                        onChanged: (v){
                          _setState(() {
                            try{
                              newBreak.length = int.parse(v);
                              errorMessage = null;
                            }catch(e){
                              errorMessage = S.of(context).invalidBreakLength;
                              newBreak.length = 0;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: S.of(context).description,
                            alignLabelWithHint: true,
                            errorText: errorMessage
                        ),
                        minLines: 3,
                        maxLines: null,
                        onChanged: (v){
                          _setState(() { description = v;});
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: ()async{
                      if(!_isSending && newBreak.start != null){
                        if(description.isEmpty){
                          _setState(() {
                            errorMessage = S.of(context).youMustWriteDescription;
                          });
                          return;
                        }
                        if(newBreak.length == 0){
                          _setState(() {
                            errorMessage = S.of(context).breakLengthCanNotBeZero;
                          });
                          return;
                        }
                        _setState(() { _isSending=true; });
                        await _sendBreakRevisionRequest(employeeBreak, newBreak, description);
                        Navigator.pop(_context);
                      }
                    },
                    child: _isSending
                        ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                        :Text(S.of(context).submit,style: TextStyle(color: Colors.red),),
                  ),
                ],
              );
            }
          ),
        )
    );
  }

  _showWorkRevisionDialog(WorkHistory work){
    bool _isSending = false;
    WorkHistory newWork = WorkHistory.fromJson(work.toJson());
    String description = '';
    String? errorMessage;

    showDialog(
        context: context,
        builder:(_)=> WillPopScope(
          onWillPop: ()async{
            return !_isSending;
          },
          child: StatefulBuilder(
              builder: (BuildContext _context, StateSetter _setState){
                return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.zero,
                  scrollable: true,
                  content: Container(
                    width: MediaQuery.of(context).size.width-50,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text(S.of(context).hourRevisionRequest,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
                        if(work.projectId != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8,),
                              Text(S.of(context).project,style: TextStyle(fontSize: 12),),
                              ProjectPicker(
                                projects: projects,
                                projectId: newWork.projectId,
                                onSelected: (v) {
                                  _setState((){
                                    newWork.projectId = v?.id;
                                    newWork.projectName = v?.name;
                                  });
                                },
                              ),
                            ],
                          ),
                        if(work.taskId != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6,),
                              Text(S.of(context).task, style: TextStyle(fontSize: 12),),
                              TaskPicker(
                                tasks: tasks,
                                taskId: newWork.taskId,
                                onSelected: (v) {
                                  _setState((){
                                    newWork.taskId = v?.id;
                                    newWork.taskName = v?.name;
                                  });
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 12,),
                        TimeEditor(
                          label: S.of(context).startTime,
                          initTime: work.start,
                          onChanged: (v){
                            _setState(() { newWork.start = v; });
                          },
                        ),
                        SizedBox(height: 12,),
                        TimeEditor(
                          label: S.of(context).endTime,
                          initTime: work.end,
                          onChanged: (v){
                            _setState(() { newWork.end = v; });
                          },
                        ),
                        SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: S.of(context).description,
                              alignLabelWithHint: true,
                              errorText: errorMessage
                          ),
                          minLines: 3,
                          maxLines: null,
                          onChanged: (v){
                            _setState(() {description = v;});
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: ()async{
                        if(!_isSending && newWork.start != null && newWork.end != null){
                          if(description.isNotEmpty){
                            _setState(() { _isSending=true; });
                            await _sendWorkRevisionRequest(work, newWork, description);
                            Navigator.pop(_context);
                          }else{
                            _setState(() { errorMessage = S.of(context).youMustWriteDescription; });
                          }
                        }
                      },
                      child: _isSending
                          ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                          :Text(S.of(context).submit,style: TextStyle(color: Colors.red),),
                    )
                  ],
                );
              }
          ),
        )
    );
  }

  _sendPunchRevisionRequest(int? punchId, String newValue, String? oldValue, String description)async{
    String? result = await context.read<RevisionProvider>().sendPunchRevisionRequest(
        punchId: punchId,
        newValue: newValue,
        oldValue:oldValue,
        description: description
    );
    if(result != null){
      Tools.showErrorMessage(context, result);
    }else{
      Tools.showSuccessMessage(context, S.of(context).revisionHasBeenSent);
    }
  }

  _sendBreakRevisionRequest(EmployeeBreak oldBreak, EmployeeBreak newBreak, String description)async{
    String? result = await context.read<RevisionProvider>().sendBreakRevisionRequest(
        oldBreak: oldBreak,
        newBreak:newBreak,
        description: description
    );
    if(result != null){
      Tools.showErrorMessage(context, result);
    }else{
      Tools.showSuccessMessage(context, S.of(context).revisionHasBeenSent);
    }
  }

  _sendWorkRevisionRequest(WorkHistory oldWork, WorkHistory newWork, String description)async{
    String? result = await context.read<RevisionProvider>().sendWorkRevisionRequest(
        newWork: newWork,
        oldWork: oldWork,
        description: description
    );
    if(result != null){
      Tools.showErrorMessage(context, result);
    }else{
      Tools.showSuccessMessage(context, S.of(context).revisionHasBeenSent);
    }
  }

  void _onRefresh() async{
    try{
      await context.read<UserProvider>().getUserTimeSheetData(startOfWeek);
      selectedPunches = user!.getPunchesGroupOfWeek(startOfWeek);
      _refreshController.refreshCompleted();
      if(mounted)setState(() {});
    }catch(e){
      Tools.consoleLog('[EmployeeTimeSheet._onRefresh]$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Punch? currentPunch = user!.getTodayPunch();
    projects = context.watch<WorkProvider>().projects;
    tasks = context.watch<WorkProvider>().tasks;

    return Container(
      child: Column(
        children: [
          Container(
            width: width,
            height: height*0.4,
            child: Stack(
              children: [
                Positioned(
                  bottom: 40,
                  left: -width/2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 3)],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: width,
                    ),
                  ),
                ),
                ClipOval(
                  clipper: TopBackgroundClipper(width: width, height: -(width-height*0.4+150)),
                  child: Container(
                    width: width,
                    height: height*0.4,
                    decoration: BoxDecoration(
                        color: Color(primaryColor),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 85,
                    child: Center(
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: '${user!.avatarUrl}',
                          height: 150,
                          width: 150,
                          alignment: Alignment.center,
                          placeholder: (_,__)=>Container(
                            color: Colors.white,
                              child: Image.asset("assets/images/person.png",width: 150,height: 150,)
                          ),
                          errorWidget: (_,__,___)=>Container(
                              color: Colors.white,
                              child: Image.asset("assets/images/person.png",width: 150,height: 150,)
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${PunchDateUtils.convertHoursToString(user!.getTotalHoursOfLastWeek())}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text("${S.of(context).week} ${PunchDateUtils.calculateCurrentWeekNumber(DateTime.now().subtract(Duration(days: 7)))}",
                                style: TextStyle(fontSize: 12)
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        child: currentPunch!=null?Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${currentPunch.getTime()}",style: TextStyle(fontSize: 12, color: Colors.white)),
                            Text("${currentPunch.punch} ${S.of(context).time}",style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ):Text(S.of(context).noPunch, style: TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center,),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${PunchDateUtils.convertHoursToString(context.watch<UserProvider>().yearTotalHours)}", style: TextStyle(fontSize: 12)),
                            Text(S.of(context).total,style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top+10,
                  left: 20,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                            "${user!.getFullName()}",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),
                          )
                      ),
                      Row(
                        children: [
                          if(user!.isManager())
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset('assets/images/ic_dashboard.png', color: Colors.white, width: 25, height: 25,)
                                ),
                                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeList()))
                            ),
                          if(user!.isManager())
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(Icons.settings, color: Colors.white,size: 30,),
                                ),
                                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSetting()))
                            ),
                          if(user!.isManager())
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.bug_report, color: Colors.white, size: 30,),
                              ),
                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>BugReportPage()))
                            ),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.logout, color: Colors.white, size: 30,),
                            ),
                            onTap: ()async{
                              await context.read<UserProvider>().logOut();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
                            }
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Container(
              width: width,
              padding: EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CalendarStrip(
                    startDate: startDate,
                    endDate: endDate,
                    onDateSelected: onSelect,
                    onWeekSelected: onWeekSelect,
                    dateTileBuilder: dateTileBuilder,
                    iconColor: Colors.black87,
                    markedDates: [],
                    monthNameWidget: monthNameWidget,
                    leftIcon: Icon(Icons.chevron_left),
                    rightIcon: Icon(Icons.chevron_right),
                    addSwipeGesture: true,
                    weekStartsOnSunday: true,
                    selectedDate: selectedDate,
                  ),
                  Text("${S.of(context).totalHours}: ${PunchDateUtils.convertHoursToString(user!.getTotalHoursOfWeek(startOfWeek))}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Container(
                width: width,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).logs),
                    Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: false,
                          header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 20,),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          child: ListView(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            children: employeeLogs(),
                          ),
                        )
                    ),
                    Center(child: Text("*${S.of(context).askRevision}*",style: TextStyle(color: Colors.red),)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class TopBackgroundClipper extends CustomClipper<Rect> {
  final double width;
  final double height;
  TopBackgroundClipper({required this.width ,required this.height});
  @override
  getClip(Size size) {
    var path = Rect.fromCircle(center: Offset(width/2,height) ,radius: width);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }

}