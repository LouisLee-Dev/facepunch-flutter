import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/lang/l10n.dart';
import '../../config/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/widgets/utils.dart';
import '/widgets/project_picker.dart';
import '/widgets/task_picker.dart';

class SelectTaskScreen extends StatefulWidget{

  final FacePunchData facePunchData;
  SelectTaskScreen(this.facePunchData);

  @override
  _SelectTaskScreenState createState() => _SelectTaskScreenState();
}

class _SelectTaskScreenState extends State<SelectTaskScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<WorkSchedule> schedules = [];
  List<EmployeeCall> calls = [];
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];
  late User employee;
  Punch? punch;
  WorkSchedule? selectedSchedule;
  EmployeeCall? selectedCall;
  Project? selectedProject;
  ScheduleTask? selectedTask;
  WorkHistory? currentWork;
  double? latitude;
  double? longitude;
  bool isInManualBreak = false;

  @override
  void initState() {
    super.initState();
    schedules = widget.facePunchData.schedules;
    calls = widget.facePunchData.calls;
    projects = widget.facePunchData.projects;
    tasks = widget.facePunchData.tasks;
    employee = widget.facePunchData.employee;
    punch = widget.facePunchData.punch;
    currentWork = widget.facePunchData.work;
    latitude = widget.facePunchData.latitude;
    longitude = widget.facePunchData.longitude;
    isInManualBreak = widget.facePunchData.isInManualBreak;
  }

  bool canStartWork(){
    return selectedSchedule != null || selectedCall != null || (selectedTask != null && selectedProject != null);
  }

  String startButtonTitle(){
    if(selectedSchedule != null && selectedSchedule!.status == "pending"){
      return S.of(context).resume.toUpperCase();
    }
    return S.of(context).start.toUpperCase();
  }

  Future<void> startWork()async{
    try{
      context.loaderOverlay.show();
      String? message;
      if(selectedCall != null){
        message = await selectedCall!.startCall(token: employee.token, latitude: latitude, longitude: longitude);
      }else if(selectedSchedule != null){
        message = await selectedSchedule!.startSchedule(token: employee.token, latitude: latitude, longitude: longitude);
      }else if(selectedProject != null && selectedTask != null){
        message = await employee.startShopTracking(
          projectId: selectedProject!.id,
          taskId: selectedTask!.id,
          latitude: latitude,
          longitude: longitude
        );
      }
      context.loaderOverlay.hide();
      if(message != null){
        Tools.showErrorMessage(context, message);
      }else{
        if(selectedProject != null && selectedTask != null){
          Tools.showSuccessMessage(context, "${employee.name}, \n ${S.of(context).youAreWorkingOn} ${selectedProject!.name} - ${selectedTask!.name}");
        }else if(selectedCall != null){
          Tools.playSound();
          Tools.showSuccessMessage(context, "${employee.name}, \n ${S.of(context).youAreWorkingOnCall}");
        }else{
          Tools.showSuccessMessage(context, "${S.of(context).welcome}, ${employee.name}");
        }
        Navigator.pop(context);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen.startWork]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
  }

  Future<void> startManualBreak()async{
    try{
      context.loaderOverlay.show();
      String?  message = await employee.startManualBreak();
      context.loaderOverlay.hide();
      if(message != null){
        Tools.showErrorMessage(context, message);
      }else{
        Navigator.pop(context);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen.startManualBreak]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
  }

  Future<bool> endManualBreak()async{
    try{
      context.loaderOverlay.show();
      String?  message = await employee.endManualBreak();
      context.loaderOverlay.hide();
      if(message != null){
        Tools.showErrorMessage(context, message);
      }else{
        return true;
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen.endManualBreak]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
    return false;
  }

  Future<void> punchOut()async{
    try{
      context.loaderOverlay.show();
      String? result = await employee.punchOut(
          latitude: latitude,
          longitude: longitude
      );
      context.loaderOverlay.hide();
      if(result == null){
        Tools.showErrorMessage(context, "${S.of(context).bye}, ${employee.name}");
        Navigator.pop(context);
      }else{
        Tools.showErrorMessage(context, result);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen._punchOut]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
  }

  Widget _actionButtons(){
    List<Widget> buttons = [];
    if(employee.isPunchIn() && employee.isManualBreak() && isInManualBreak){
      buttons.add(
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.orange,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: MediaQuery.of(context).size.width-40,
            height: 40,
            onPressed: ()async{
              if(await endManualBreak()){
                if(mounted)setState(() {isInManualBreak = false;});
              }
            },
            child: Text(
              S.of(context).endManualBreak.toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
      );
    }else{
      if(employee.isPunchIn() && employee.isManualBreak()){
        buttons.add(
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: Colors.orange,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: MediaQuery.of(context).size.width-40,
              height: 40,
              onPressed: startManualBreak,
              child: Text(
                S.of(context).startManualBreak.toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
        );
      }
      buttons.add(SizedBox(height: 8,));
      buttons.add(MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Color(primaryColor),
        disabledColor: Colors.grey,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minWidth: MediaQuery.of(context).size.width-40,
        height: 40,
        onPressed: canStartWork()?startWork:null,
        child: Text(startButtonTitle(), style: TextStyle(color: Colors.white, fontSize: 16),),
      ));
      buttons.add(SizedBox(height: 8,));
      if(employee.isPunchIn()){
        buttons.add(MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.red,
          disabledColor: Colors.grey,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: MediaQuery.of(context).size.width-40,
          height: 40,
          onPressed: punchOut,
          child: Text(S.of(context).punchOut.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
        ));
      }
    }
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).selectTask),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(employee.hasTracking())
              Container(
                margin: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(currentWork != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey)
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Text(S.of(context).youAreWorkingOn, style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              children: [
                                Text('${S.of(context).project}: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('${currentWork!.projectName} - ${currentWork!.projectCode}'),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${S.of(context).task}: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('${currentWork!.taskName} - ${currentWork!.taskCode}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Text(S.of(context).project),
                    ProjectPicker(
                      projects: projects,
                      projectId: selectedProject?.id,
                      onSelected: (v){
                        setState(() {
                          selectedCall = null;
                          selectedProject = v;
                        });
                      },
                    ),
                    SizedBox(height: 20,),
                    Text(S.of(context).task),
                    TaskPicker(
                      tasks: tasks,
                      taskId: selectedTask?.id,
                      onSelected: (v){
                        setState(() {
                          selectedCall = null;
                          selectedTask = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            for(var call in calls)
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedCall==call?Color(primaryColor):Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      selectedProject = null;
                      selectedTask = null;
                      selectedSchedule = null;
                      selectedCall = call;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('${S.of(context).start} : '),
                              Text(call.startTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${S.of(context).end} : '),
                              Text(call.endTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${S.of(context).priority} : '),
                              Text('${call.priority}', style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(call.projectTitle()),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${S.of(context).task} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(call.taskTitle()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text('${S.of(context).todo} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('${call.todo}'),
                      ),
                      Text('${S.of(context).note} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('${call.note}'),
                      ),
                    ],
                  ),
                ),
              ),
            for(var schedule in schedules)
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedSchedule==schedule ? Color(primaryColor) : Color(int.parse('0xFF${schedule.color}')),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                child: InkWell(
                  onTap: ()=>setState(() {
                    selectedCall = null;
                    selectedSchedule = schedule;
                  }),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('${S.of(context).start} : '),
                              Text(schedule.startTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${S.of(context).end} : '),
                              Text(schedule.endTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${S.of(context).shift} : '),
                              Text('${schedule.shift?.name?.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(schedule.projectTitle()),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${S.of(context).task} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(schedule.taskTitle()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _actionButtons(),
    );
  }
}