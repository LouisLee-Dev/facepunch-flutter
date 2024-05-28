import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ProjectPicker extends StatefulWidget{
  final List<Project> projects;
  final int? projectId;
  final ValueChanged<Project?>? onSelected;

  ProjectPicker({required this.projects, this.projectId, this.onSelected });
  @override
  _ProjectPickerState createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<ProjectPicker> {


  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Project>(
      items: widget.projects,
      onChanged: (Project? p) => widget.onSelected!(p),
      showSearchBox: true,
      searchDelay: Duration.zero,
      itemAsString: (p)=>'${p?.name}, ${p?.code}',
      popupItemBuilder: (_, p, selected){
        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.name}'),
              Text('${p.code}', style: TextStyle(fontSize: 10),),
            ],
          ),
        );
      },
      dropdownBuilder: (_, p){
        if(p == null) return Text(S.of(context).selectProject);
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.name}'),
              Text('${p.code}', style: TextStyle(fontSize: 10),),
            ],
          ),
        );
      },
      maxHeight: 300,
    );
  }
}