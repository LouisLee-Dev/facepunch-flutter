import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';
import '/widgets/utils.dart';

import '../config/app_const.dart';

class BaseProvider with ChangeNotifier, HttpRequest{

}

class HttpRequest{

  Future<http.Response> sendPostRequest(String url, String? token, Map<dynamic, dynamic> data)async{
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['app-version'] = '${AppConst.currentVersion}';
    headers['operating-system'] = Platform.operatingSystem;
    headers['lang'] = GlobalData.lang;
    if(token != null){
      headers['Authorization'] = 'Bearer '+token;
    }
    headers['device-token'] = await Tools.getFirebaseToken();
    var logData = { ...data };
    if(logData['photo'] != null){
      logData['photo'] = '----Base 64 photo----';
    }
    Tools.consoleLog('[POST][$url][$logData]');
    return await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data)
    );
  }

  Future<http.Response> sendGetRequest(String url, String? token)async{
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['app-version'] = '${AppConst.currentVersion}';
    headers['operating-system'] = Platform.operatingSystem;
    headers['lang'] = GlobalData.lang;
    if(token != null){
      headers['Authorization'] = 'Bearer '+token;
    }
    headers['device-token'] = await Tools.getFirebaseToken();
    Tools.consoleLog('[GET][$url]');
    return await http.get(
        Uri.parse(url),
        headers: headers
    );
  }

  String handleError(Map json){
    if(json['message'] != null){
      return json['message'].toString();
    }
    if(json['messages'] != null && json['messages'] is List){
      return (json['messages'] as List).join('\n');
    }
    return 'OOPS, Something went wrong.';
  }

}