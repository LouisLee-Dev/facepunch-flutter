import 'package:dropdown_search/dropdown_search.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';

class TaskPicker extends StatefulWidget{
  final List<ScheduleTask> tasks;
  final int? taskId;
  final ValueChanged<ScheduleTask?>? onSelected;

  TaskPicker({required this.tasks, this.taskId, this.onSelected });

  @override
  _TaskPickerState createState() => _TaskPickerState();
}

class _TaskPickerState extends State<TaskPicker> {


  @override
  Widget build(BuildContext context) {
    return DropdownSearch<ScheduleTask>(
      items: widget.tasks,
      onChanged: (ScheduleTask? t) => widget.onSelected!(t),
      showSearchBox: true,
      searchDelay: Duration.zero,
      itemAsString: (t)=>'${t?.name}${t?.code}',
      popupItemBuilder: (_, t, selected){
        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.name}'),
              Text('${t.code}', style: TextStyle(fontSize: 10),),
            ],
          ),
        );
      },
      dropdownBuilder: (_, t){
        if(t == null) return Text(S.of(context).selectTask);
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.name}'),
              Text('${t.code}', style: TextStyle(fontSize: 10),),
            ],
          ),
        );
      },
      maxHeight: 300,
    );
  }
}