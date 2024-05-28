import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/widgets/TimeEditor.dart';
import '/widgets/project_picker.dart';
import '/widgets/task_picker.dart';
import '/widgets/utils.dart';
import '/providers/company_provider.dart';
import '/providers/work_provider.dart';

class EmployeeDispatch extends StatefulWidget{

  @override
  _EmployeeDispatchState createState() => _EmployeeDispatchState();
}

class _EmployeeDispatchState extends State<EmployeeDispatch> {
  DateTime selectedDate = DateTime.now();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<User> employees = [];
  List<EmployeeCall> calls = [];
  User? selectedUser;
  EmployeeCall? _call;
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  _selectScheduleDate() async {
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

  _onRefresh()async{
    if(selectedUser!=null){
      final result = await selectedUser!.getDailyCall(selectedDate.toString());
      if(result != null){
        Tools.showErrorMessage(context, result);
      }else{
        calls = selectedUser!.calls;
      }
    }
    _refreshController.refreshCompleted();
    if(mounted)setState(() {_call = null;});
  }

  Widget _callItem(EmployeeCall call){
    try{
      if(call == _call){
        return Container(
          height: 70,
          alignment: Alignment.center,
          color: Colors.red,
          child: CircularProgressIndicator(),
        );
      }
      return InkWell(
        onTap: (){
          if(_call!=null)return;
          if(call.isWorked() || call.isWorkingOn()){
            Tools.showErrorMessage(context, S.of(context).canNotEditDeleteCall);
            return;
          }
          _showCallDialog(call);
        },
        child: Container(
          decoration: BoxDecoration(
            color: call.color(),
          ),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              Text(call.projectTitle(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),textAlign: TextAlign.center,),
              Text(call.taskTitle(),textAlign: TextAlign.center,),
              SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${call.priority}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if(call.hasTime())
                    Text("${call.startTime()} ~ ${call.endTime()}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }catch(e){
      return Container(
        color: Colors.red,
        height: 30,
        child: Text(e.toString()),
      );
    }
  }

  Widget _callLine(){
    if(calls.isEmpty){
      return Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(S.of(context).empty, style: TextStyle(fontSize: 20),)
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for(var call in calls)
            _callItem(call),
        ],
      ),
    );
  }

  Widget _userItem(User employee){
    return Container(
      margin: EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: selectedUser?.id == employee.id ? Colors.red:Colors.transparent, width: 2),
              shape: BoxShape.circle
            ),
            child: InkWell(
              onTap: (){
                setState(() {selectedUser = employee;});
                _refreshController.requestRefresh();
              },
              splashColor: Colors.transparent,
              child: ClipOval(
                child: employee.userAvatarImage(),
              ),
            ),
          ),
          if(employee.hasCode())
            Text('${employee.employeeCode}',
              style: TextStyle(fontSize: 10),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          Expanded(
            child: Text('${employee.getFullName()}',
              style: TextStyle(fontSize: 12), maxLines: 1, textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  _showCallDialog(EmployeeCall? c){
    if(projects.isEmpty || tasks.isEmpty || selectedUser==null)return;
    EmployeeCall call = EmployeeCall(
        projectId: projects.first.id,
        projectName: projects.first.name,
        taskId: tasks.first.id,
        taskName: tasks.first.name,
        date: selectedDate.toString().split(' ')[0],
        start: null,
        end: null,
        userId: selectedUser!.id,
        priority: 1,
    );
    if(c != null){
      call = EmployeeCall.fromJson(c.toJson());
    }
    TextEditingController _todo = TextEditingController(text: call.todo);
    TextEditingController _note = TextEditingController(text: call.note);

    showDialog(
        context: context,
        builder:(_)=> StatefulBuilder(
            builder: (BuildContext _context, StateSetter _setState){
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.zero,
                scrollable: true,
                content: Container(
                  width: MediaQuery.of(context).size.width-50,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text(
                              S.of(context).dispatch,
                              style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                            )
                        ),
                        SizedBox(height: 8,),
                        Text(S.of(context).project,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                        ProjectPicker(
                          projects: projects,
                          projectId: call.projectId,
                          onSelected: (v) {
                            _setState((){ call.projectId = v?.id; call.projectName = v?.name; });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                        SizedBox(height: 8,),
                        Text(S.of(context).task,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                        TaskPicker(
                          tasks: tasks,
                          taskId: call.taskId,
                          onSelected: (v) {
                            _setState((){call.taskId = v?.id; call.taskName = v?.name;});
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                        SizedBox(height: 16,),
                        TimeEditor(
                          label: S.of(context).startTime,
                          initTime: c?.start,
                          isOptional: true,
                          onChanged: (v){
                            _setState(() { call.start = v;});
                          },
                        ),
                        SizedBox(height: 16,),
                        TimeEditor(
                          label: S.of(context).endTime,
                          initTime: c?.end,
                          isOptional: true,
                          onChanged: (v){
                            _setState(() { call.end = v;});
                          },
                        ),
                        SizedBox(height: 8,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).priority, style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                              Row(
                                children: [
                                  Radio(
                                    onChanged: (v){
                                      _setState((){
                                        call.priority = v as int?;
                                      });
                                    },
                                    value: 1,
                                    groupValue: call.priority,
                                  ),
                                  Text("1  "),
                                  Radio(
                                    onChanged: (v){
                                      _setState((){
                                        call.priority = v as int?;
                                      });
                                    },
                                    value: 2,
                                    groupValue: call.priority,
                                  ),
                                  Text("2  "),
                                  Radio(
                                    onChanged: (v){
                                      _setState((){
                                        call.priority = v as int?;
                                      });
                                    },
                                    value: 3,
                                    groupValue: call.priority,
                                  ),
                                  Text("3"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(S.of(context).todo,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                        TextField(
                          maxLines: 2,
                          minLines: 2,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 6,vertical: 2)
                          ),
                          controller: _todo,
                          onChanged: (v){
                            call.todo = v;
                          },
                        ),
                        SizedBox(height: 4,),
                        Text(S.of(context).notes,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                        TextField(
                          maxLines: 2,
                          minLines: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6,vertical: 2),
                          ),
                          controller: _note,
                          onChanged: (v){
                            call.note = v;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.of(_context).pop();
                      },
                      child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
                  ),
                  if(c != null)
                    TextButton(
                        onPressed: ()async{
                          Navigator.of(_context).pop();
                          _deleteCall(c);
                        },
                        child: Text(S.of(context).delete, style: TextStyle(color: Colors.red),)
                    ),
                  TextButton(
                      onPressed: ()async{
                        Navigator.of(_context).pop();
                        setState(() {
                          if(c == null){
                            calls.add(call);
                            _call = call;
                          }else{
                            _call = c;
                          }
                        });
                        _addEditCall(call);
                      },
                      child: Text(S.of(context).save, style: TextStyle(color: Color(primaryColor)),)
                  ),
                ],
              );
            }
        )
    );
  }

  _addEditCall(EmployeeCall call)async{
    final result = await call.addEditCall();
    if(result != null) Tools.showErrorMessage(context, result);
    _refreshController.requestRefresh();
  }

  _deleteCall(EmployeeCall call)async{
    setState(() { _call = call; });
    String? result = await call.delete();
    if(!mounted) return;
    setState(() { _call = null;});
    if(result == null){
      setState(() {
        calls.remove(call);
      });
    }else{
      Tools.showErrorMessage(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    employees = context.watch<CompanyProvider>().users.where((u) => u.hasCall()).toList();
    projects = context.watch<WorkProvider>().projects;
    tasks = context.watch<WorkProvider>().tasks;
    if(selectedUser == null && employees.isNotEmpty){
      selectedUser = employees.first;
    }
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
            child: Text(S.of(context).dispatch,style: TextStyle(fontSize: 20, color: Colors.white),),
          ),
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
                  onPressed: _selectScheduleDate,
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
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverList(delegate: SliverChildListDelegate([
                    _callLine(),
                    if(selectedUser!=null && selectedUser!.type != 'shop_tracking')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          onPressed: ()=>_showCallDialog(null),
                          height: 40,
                          child: Text(S.of(context).addCall, style: TextStyle(color: Colors.white),),
                          color: Colors.black,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                  ])),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5,childAspectRatio: 0.7),
                    delegate: SliverChildListDelegate(
                        [
                          for(var employee in employees)
                            _userItem(employee),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}