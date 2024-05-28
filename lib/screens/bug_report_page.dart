import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';

import '/widgets/utils.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/providers/app_provider.dart';


class BugReportPage extends StatefulWidget{

  @override
  _BugReportPageState createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage>{
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  TextEditingController _comment = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        final deviceData = await deviceInfoPlugin.androidInfo;
        _deviceData['make'] = deviceData.manufacturer;
        _deviceData['model'] = deviceData.model;
        _deviceData['version'] = deviceData.version.release;
        _deviceData['os'] = deviceData.version.sdkInt;
        _deviceData['brand'] = deviceData.brand;
      } else if (Platform.isIOS) {
        final deviceData = await deviceInfoPlugin.iosInfo;
        _deviceData['name'] = deviceData.name;
        _deviceData['model'] = deviceData.model;
        _deviceData['version'] = deviceData.systemVersion;
        _deviceData['system'] = deviceData.systemName;
      }
    }on PlatformException catch(e){
      Tools.consoleLog('[BugReportPage.initPlatformState]$e');
    } catch(e){
      Tools.consoleLog('[BugReportPage.initPlatformState]$e');
    }
    if(mounted)setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).bugReport),
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return !isSubmitting;
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: S.of(context).bugReportDescription,
                  ),
                  minLines: 50,
                  maxLines: null,
                  controller: _comment,
                  enabled: !isSubmitting,
                ),
              ),
              SizedBox(height: 10,),
              if(Platform.isAndroid)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).make),
                        Text('${_deviceData['make']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).model),
                        Text('${_deviceData['model']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).brand),
                        Text('${_deviceData['brand']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).os),
                        Text('${_deviceData['os']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).version),
                        Text('${_deviceData['version']}')
                      ],
                    ),
                  ],
                ),
              if(Platform.isIOS)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).name),
                        Text('${_deviceData['name']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).model),
                        Text('${_deviceData['model']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).system),
                        Text('${_deviceData['system']}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).version),
                        Text('${_deviceData['version']}')
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 10,),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.green,
                minWidth: double.infinity,
                height: 45,
                onPressed: ()async{
                  try{
                    FocusScope.of(context).requestFocus(FocusNode());
                    if(!isSubmitting){
                      setState(() {isSubmitting = true;});
                      String? result = await context.read<AppProvider>().submitMobileLog(comment: _comment.text, deviceInfo: _deviceData);
                      if(!mounted) return;
                      setState(() {isSubmitting = false;});
                      if(result != null){
                        Tools.showErrorMessage(context, result);
                      }else{
                        Tools.showSuccessMessage(context, S.of(context).thankYouForReporting);
                      }
                    }
                  }catch(e){
                    Tools.consoleLog('[BugReportPage.submit.err]');
                  }
                },
                child: isSubmitting
                    ?SizedBox( width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                    :Text(S.of(context).submit.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}