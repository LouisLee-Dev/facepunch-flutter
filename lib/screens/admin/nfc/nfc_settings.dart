import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/company_model.dart';
import '/models/harvest_model.dart';
import '/widgets/popover/cool_ui.dart';
import '/widgets/utils.dart';
import '/providers/company_provider.dart';
import '/providers/harvest_provider.dart';

class NFCSettingPage extends StatefulWidget{

  @override
  _NFCSettingPageState createState() => _NFCSettingPageState();
}

class _NFCSettingPageState extends State<NFCSettingPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _lowValue = TextEditingController(text: '2.5');
  TextEditingController _highValue = TextEditingController(text: '3.0');
  TimeOfDay _reportTime = TimeOfDay.now();
  DateTime _lastUpdated = DateTime.now();

  bool isLoading = false;
  Color lowColor = Colors.red;
  Color mediumColor = Colors.yellow;
  Color highColor = Colors.green;
  CompanySettings? companySettings;
  List<Field> fields = [];
  List<HContainer> containers = [];
  Field? selectedField;
  HContainer? selectedContainer;

  @override
  void initState() {
    companySettings = context.read<CompanyProvider>().myCompanySettings;
    _init();
    super.initState();
  }

  _init(){
    try{
      if(companySettings != null){
        if(companySettings?.lowValue != null)_lowValue = TextEditingController(text: companySettings?.lowValue);
        if(companySettings?.highValue != null)_highValue = TextEditingController(text: companySettings?.highValue);
        if(companySettings?.lowColor != null)lowColor = Color(int.parse('0x${companySettings?.lowColor}'));
        if(companySettings?.mediumColor != null)mediumColor = Color(int.parse('0x${companySettings?.mediumColor}'));
        if(companySettings?.highColor != null)highColor = Color(int.parse('0x${companySettings?.highColor}'));
        if(companySettings?.reportTime != null)_reportTime = TimeOfDay.fromDateTime(DateTime.parse(companySettings!.reportTime!));
        if(companySettings?.lastUpdated != null)_lastUpdated = DateTime.parse(companySettings!.lastUpdated!);
      }
    }catch(e){
      Tools.consoleLog('[NFCSettingPage._init]$e');
    }
  }

  showFieldDialog(Field? field){
    TextEditingController _fieldName = TextEditingController(text: field?.name);
    TextEditingController _fieldCrop = TextEditingController(text: field?.crop);
    TextEditingController _fieldCropVariety = TextEditingController(text: field?.cropVariety);
    bool isSavingField = false;
    String? _fieldNameError, _fieldCropError,_fieldVarietyError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
          title: Text(field==null?S.of(context).createNewField:S.of(context).updateField,textAlign: TextAlign.center,),
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(8),
          content: StatefulBuilder(
            builder: (_, setState)=>Container(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _fieldName,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldName.value = _fieldName.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldName,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldNameError,
                    ),
                    maxLength: 5,
                  ),
                  TextField(
                    controller: _fieldCrop,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldCrop.value = _fieldCrop.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldCrop,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldCropError
                    ),
                    maxLength: 12,
                  ),
                  TextField(
                    controller: _fieldCropVariety,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldCropVariety.value = _fieldCropVariety.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldCropVariety,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldVarietyError
                    ),
                    maxLength: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(S.of(context).close
                          ,style: TextStyle(color: Colors.red),
                        ),
                        onPressed: ()async{
                          Navigator.pop(_context);
                        },
                      ),
                      TextButton(
                        child: isSavingField
                            ?SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2,),
                        ):Text(S.of(context).save,
                          style: TextStyle(color: Color(primaryColor)),
                        ),
                        onPressed: ()async{
                          try{
                            _fieldVarietyError = null; _fieldCropError = null; _fieldNameError = null;
                            if(_fieldName.text.isEmpty){
                              setState((){_fieldNameError=S.of(context).fieldNameIsRequired;});
                              return;
                            }
                            if(_fieldCrop.text.isEmpty){
                              setState((){_fieldCropError=S.of(context).cropIsRequired;});
                              return;
                            }
                            if(_fieldCropVariety.text.isEmpty){
                              setState((){_fieldVarietyError=S.of(context).varietyIsRequired;});
                              return;
                            }
                            setState((){isSavingField=true;});
                            if(field != null){
                              field!.name = _fieldName.text;
                              field!.crop = _fieldCrop.text;
                              field!.cropVariety = _fieldCropVariety.text;
                            }else{
                              field = Field(name: _fieldName.text,crop: _fieldCrop.text,cropVariety: _fieldCropVariety.text);
                            }
                            String? result = await context.read<HarvestProvider>().createOrUpdateField(field!);
                            if(result != null){
                              _fieldVarietyError = result;
                            }else{
                              Navigator.pop(_context);
                            }
                            setState((){isSavingField=false;});
                          }catch(e){
                            Navigator.pop(_context);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }

  showContainerDialog(HContainer? container){
    TextEditingController _containerName = TextEditingController(text: container?.name);
    bool isSavingContainer = false;
    String? _containerNameError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(container==null?S.of(context).createNewContainer:S.of(context).updateContainer, textAlign: TextAlign.center,),
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(8),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _containerName,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v){
                        _containerName.value = _containerName.value.copyWith(text: firstToUpper(v));
                      },
                      decoration: InputDecoration(
                          labelText: S.of(context).containerName,
                          labelStyle: TextStyle(color: Colors.black54),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          errorText: _containerNameError
                      ),
                      maxLength: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(S.of(context).close, style: TextStyle(color: Colors.red),),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                        ),
                        TextButton(
                          child: isSavingContainer
                              ?SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2,),
                          ):Text(S.of(context).save, style: TextStyle(color: Color(primaryColor)),),
                          onPressed: ()async{
                            try{
                              _containerNameError = null;
                              if(_containerName.text.isEmpty){
                                setState((){_containerNameError=S.of(context).nameIsRequired;});
                                return;
                              }
                              setState((){isSavingContainer=true;});
                              if(container != null){
                                container!.name = _containerName.text;
                              }else{
                                container = HContainer(name: _containerName.text);
                              }
                              String? result = await context.read<HarvestProvider>().createOrUpdateContainer(container!);
                              if(result != null){
                                _containerNameError = result;
                              }else{
                                Navigator.pop(_context);
                              }
                              setState((){isSavingContainer=false;});
                            }catch(e){
                              Tools.consoleLog('[showContainerDialog.onPressed]$e');
                              Navigator.pop(_context);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        );
      },
    );
  }

  Future<Color> showColorPicker(Color color)async{
    Color pickedColor = Color(color.value);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).chooseColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (c){pickedColor = c;},
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                color = pickedColor;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return color;
  }

  changeReportTime()async{
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reportTime,
      initialEntryMode: TimePickerEntryMode.input
    );
    if(picked!=null){
      setState(() {
        _reportTime = picked;
      });
    }
  }

  bool validator(){
    if(_lowValue.text.isEmpty){
      Tools.showErrorMessage(context, S.of(context).lowValueIsEmpty);
      return false;
    }
    if(double.tryParse(_lowValue.text)==null){
      Tools.showErrorMessage(context, S.of(context).lowValueShouldBeNumber);
      return false;
    }
    if(_highValue.text.isEmpty){
      Tools.showErrorMessage(context, S.of(context).highValueIsEmpty);
      return false;
    }
    if(double.tryParse(_highValue.text) ==null ){
      Tools.showErrorMessage(context, S.of(context).highValueShouldBeNumber);
      return false;
    }
    if(double.parse(_highValue.text) < double.parse(_lowValue.text)){
      Tools.showErrorMessage(context, S.of(context).highValueShouldBeBigger);
      return false;
    }
    return true;
  }

  String firstToUpper(String v){
    if(v.isNotEmpty){
      return v[0].toUpperCase()+v.substring(1);
    }
    return v;
  }

  Widget _fieldItem(Field field){
    Widget child = Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,

            )
          ]
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(field.shortName(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          FittedBox(
              child: Text('${field.crop}', style: TextStyle(fontSize: 12),)
          ),
          FittedBox(
              child: Text('${field.cropVariety}', style: TextStyle(fontSize: 12),)
          )
        ],
      ),
    );
    if(selectedField == field){
      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          CircularProgressIndicator()
        ],
      );
    }
    return CupertinoPopoverButton(
      popoverBoxShadow: [
        BoxShadow(color: Colors.black54,blurRadius: 5.0)
      ],
      popoverWidth: 180,
      popoverBuild: (_context){
        return CupertinoPopoverMenuList(
          children: <Widget>[
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).editField,style: TextStyle(color: Colors.black87),),
                    Icon(Icons.edit,color: Colors.black87,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pop(_context);
                showFieldDialog(field);
                return true;
              },
            ),
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).delete,style: TextStyle(color: Colors.red),),
                    Icon(Icons.delete,color: Colors.red,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pop(_context);
                _deleteField(field);
                return true;
              },
            )
          ],
        );
      },
      onTap: (){
        return true;
      },
      child: child,
    );
  }

  _deleteField(Field field)async{
    if(await Tools.confirmDeleting(context, S.of(context).deleteFieldConfirm)){
      setState(() { selectedField = field; });
      String? result = await context.read<HarvestProvider>().deleteField(field);
      if(result != null) Tools.showErrorMessage(context, result);
      if(mounted)setState(() {
        selectedField = null;
      });
    }
  }

  Widget _containerItem(HContainer container){
    Widget child = Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,

            )
          ]
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(container.shortName(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          FittedBox(
              child: Text('${container.name}',style: TextStyle(fontSize: 12),)
          ),
        ],
      ),
    );
    if(selectedContainer == container){
      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          CircularProgressIndicator()
        ],
      );
    }
    return CupertinoPopoverButton(
      popoverBoxShadow: [
        BoxShadow(color: Colors.black54,blurRadius: 5.0)
      ],
      popoverWidth: 180,
      popoverBuild: (_context){
        return CupertinoPopoverMenuList(
          children: <Widget>[
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).editContainer,style: TextStyle(color: Colors.black87),),
                    Icon(Icons.edit,color: Colors.black87,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pop(_context);
                showContainerDialog(container);
                return true;
              },
            ),
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).delete,style: TextStyle(color: Colors.red),),
                    Icon(Icons.delete,color: Colors.red,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pop(_context);
                _deleteContainer(container);
                return true;
              },
            )
          ],
        );
      },
      onTap: (){
        return true;
      },
      child: child,
    );
  }

  _deleteContainer(HContainer container)async{
    if(await Tools.confirmDeleting(context, S.of(context).deleteContainerConfirm)){
      setState(() { selectedContainer = container; });
      String? result = await context.read<HarvestProvider>().deleteContainer(container);
      if(result != null) Tools.showErrorMessage(context, result);
      if(mounted)setState(() {
        selectedContainer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fields = context.watch<HarvestProvider>().fields;
    containers = context.watch<HarvestProvider>().containers;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).nfcSettings),
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).fields,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for(var field in fields)
                      _fieldItem(field),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              
                            )
                          ]
                      ),
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.all(2),
                      child: InkWell(
                        onTap: (){showFieldDialog(null);},
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(Icons.add, size: 30, color: Colors.white,)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text(S.of(context).containers,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for(var container in containers)
                      _containerItem(container),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              
                            )
                          ]
                      ),
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.all(2),
                      child: InkWell(
                          onTap: (){ showContainerDialog(null); },
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(Icons.add,size: 30,color: Colors.white,)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text(S.of(context).containerHour,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                    )
                  ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            highColor = await showColorPicker(highColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: highColor,
                            ),
                            child: Text(S.of(context).highDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: TextField(
                          controller: _highValue,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            suffixText: '+',
                            suffixStyle: TextStyle(fontSize: 18),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (v){
                            setState(() {});
                          },
                          style: TextStyle(fontSize: 18),
                        )
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      )
                    ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            mediumColor = await showColorPicker(mediumColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: mediumColor,
                            ),
                            child: Text(S.of(context).mediumDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: Center(
                            child: Text(
                              "${_lowValue.text} to ${_highValue.text}",
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            )
                        )
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      )
                    ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            lowColor = await showColorPicker(lowColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lowColor,
                            ),
                            child: Text(S.of(context).lowDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: TextField(
                          controller: _lowValue,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            suffixText: '-',
                            suffixStyle: TextStyle(fontSize: 18),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (v){
                            setState(() {});
                          },
                          style: TextStyle(fontSize: 18),
                        )
                    )
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${S.of(context).reportTime}: ${_reportTime.format(context)}', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                        SizedBox(width: 16,),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.edit,color: Colors.red,),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          onTap: changeReportTime,
                        )
                      ],
                    ),
                    Text('${S.of(context).lastUpdated}: ${_lastUpdated.toString().split(' ')[0]}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Center(
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width-60,
                  padding: EdgeInsets.all(8),
                  splashColor: Color(primaryColor),
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  onPressed: ()async{
                    try{
                      if(validator()){
                        final now = DateTime.now();
                        if(companySettings != null){
                          companySettings!.reportTime = DateTime(now.year, now.month, now.day, _reportTime.hour, _reportTime.minute).toString();
                          companySettings!.lastUpdated = now.toString().split(' ')[0];
                          companySettings!.highColor = highColor.value.toRadixString(16);
                          companySettings!.mediumColor = mediumColor.value.toRadixString(16);
                          companySettings!.lowColor = lowColor.value.toRadixString(16);
                          companySettings!.highValue = _highValue.text;
                          companySettings!.lowValue = _lowValue.text;
                          setState(() { isLoading=true; });
                          String? result = await context.read<CompanyProvider>().updateCompanySetting(companySettings!);
                          setState(() { isLoading=false; });
                          if(result != null){
                            Tools.showErrorMessage(context, result);
                          }
                        }
                      }
                    }catch(e){
                      Tools.consoleLog('[NFCSettingPage.onSave] $e');
                      Tools.showErrorMessage(context, e.toString());
                    }
                  },
                  child: isLoading
                      ?SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(),
                      ):Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(S.of(context).save, style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}