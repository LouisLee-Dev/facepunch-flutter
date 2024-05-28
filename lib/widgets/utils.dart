import 'dart:async';
import 'dart:math' as math;
import 'package:convert/convert.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '/models/notification.dart';
import '../config/app_const.dart';
import '/lang/l10n.dart';
import 'face_painter.dart';

typedef HandleDetection = Future<List<Face>> Function(InputImage image);

class Tools {
  static Future<void> playSound()async{
    try{
      AssetsAudioPlayer().open(
        Audio("assets/sound/sound.mp3"),
        autoStart: true,
      );
    }catch(e){
      Tools.consoleLog('[Tools.playSound]$e');
    }
  }

  static showErrorMessage(BuildContext context, String message, ){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){}, label: S.of(context).close, textColor: Colors.white,),
        )
    );
  }

  static showSuccessMessage(BuildContext context, String message){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Color(primaryColor),
          action: SnackBarAction(onPressed: (){}, label: S.of(context).close, textColor: Colors.white,),
        )
    );
  }

  static Future<void> consoleLog(String log)async{
    try{
      print('$log');
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${AppConst.LOG_FILE_PREFIX}${DateTime.now().toString().split(' ')[0]}');
      logFile.writeAsString('\n[${DateTime.now()}]$log', mode: FileMode.writeOnlyAppend);
    }catch(e){
      print('[consoleLog]$e');
    }
  }

  static Future<DateTime?> pickTime(BuildContext context, String initTime)async{
    DateTime initDate = DateTime.parse(initTime);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initDate.hour, minute: initDate.minute),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if(picked!=null){
      return DateTime(initDate.year, initDate.month, initDate.day, picked.hour, picked.minute, initDate.second);
    }
    return null;
  }

  static String? getNFCIdentifier(Map<String, dynamic> data){
    try{
      Uint8List? identifier;
      data.forEach((k1, v1) {
        if(k1 == 'identifier' && v1 is Uint8List){
          identifier = v1;
        }else if(v1 is Map){
          v1.forEach((k2, v2) {
            if(k2 == 'identifier' && v2 is Uint8List){
              identifier = v2;
            }else if(v2 is Map){
              v2.forEach((k3, v3) {
                if(k3 == 'identifier' && v3 is Uint8List){
                  identifier = v3;
                }
              });
            }
          });
        }
      });
      print(identifier);
      if(identifier == null) return null;
      return hex.encode(identifier!);
    }catch(e){
      consoleLog('[Tools.getNFCIdentifier]$e');
    }
  }

  static Future<bool> checkCameraPermission()async{
    try{
      var status = await Permission.camera.status;
      if(status.isGranted){
        return true;
      }else{
        status = await Permission.camera.request();
        if(status.isGranted){
          return true;
        }
      }
    } on PlatformException catch(e){
      consoleLog('[Tools.getCameraPermission]$e');
    }catch(e){
      consoleLog('[Tools.getCameraPermission]$e');
    }
    return false;
  }

  static Future<bool> checkLocationPermission(BuildContext context)async{
    try{
      var status = await Permission.location.status;
      if(status.isGranted){
        return true;
      }else{
        if(Platform.isAndroid){
          await showLocationPermissionDialog(context);
        }
        status = await Permission.location.request();
        if(status.isGranted){
          return true;
        }
      }
    }on PlatformException catch(e){
      consoleLog('[Tools.checkLocationPermission]$e');
    }catch(e){
      consoleLog('[Tools.checkLocationPermission]$e');
    }
    return false;
  }

  static String generateRandomString(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    math.Random r = math.Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  static void setupFirebaseNotification(Function onMessage)async{
    var status = await Permission.notification.status;
    if(!status.isGranted){
      await Permission.notification.request();
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessage(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message){
      if(message != null)onMessage(message);
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<CameraDescription> getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  static InputImageData buildMetaData(
      CameraImage image,
      InputImageRotation rotation,
      ) {
    return InputImageData(
        inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: rotation,
        planeData: image.planes.map((Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
        ).toList()
    );
  }

  static Future<List<Face>> detect(
      CameraImage image,
      HandleDetection handleDetection,
      InputImageRotation rotation,
      ) async {
    return handleDetection(
      InputImage.fromBytes(
        bytes: concatenatePlanes(image.planes),
        inputImageData: buildMetaData(image, rotation),
      ),
    );
  }

  static InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.Rotation_0deg;
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      default:
        assert(rotation == 270);
        return InputImageRotation.Rotation_270deg;
    }
  }

  static Widget faceRect(CameraController cameraController, List<Face>? faces, double strokeWidth) {
    try{
      if(faces == null || !(faces is List<Face>)) return SizedBox();
      final Size imageSize = Size(cameraController.value.previewSize!.height, cameraController.value.previewSize!.width,);
      CustomPainter painter = FaceDetectorPainter(imageSize, faces, strokeWidth);
      if(Platform.isIOS){
        return CustomPaint(painter: painter,);
      }else{
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: CustomPaint(painter: painter,),
        );
      }
    }catch(e){
      Tools.consoleLog("[Tools.faceRect.err] $e");
      return SizedBox();
    }
  }

  static Future<String> getPunchKey()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? punchKey = prefs.getString('face_punch_key');
    if(punchKey == null){
      punchKey = Tools.generateRandomString(20);
      prefs.setString('face_punch_key', punchKey);
    }
    return punchKey;
  }

  static Future<bool> pinCodeCheckDialog(String pin, BuildContext context)async{
    bool result = false;
    bool hasError= false;
    await showDialog(
      context: context,
      builder:(_)=> StatefulBuilder(
          builder: (BuildContext _context,StateSetter setState){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.all(0),
              title: Text(S.of(context).enterPinCode,style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  PinCodeTextField(
                    autofocus: true,
                    hideCharacter: true,
                    highlight: true,
                    highlightColor: Color(primaryColor),
                    defaultBorderColor: Colors.grey,
                    hasTextBorderColor: Colors.black87,
                    maxLength: 4,
                    maskCharacter: "*",
                    hasError: hasError,
                    onTextChanged: (text) {
                      setState(() {hasError = false;});
                    },
                    onDone: (text) {
                      if(pin == text){
                        result = true;
                        Navigator.pop(context);
                      }else{
                        setState(() {hasError = true;});
                      }
                    },
                    pinBoxWidth: 40,
                    pinBoxHeight: 50,
                    hasUnderline: true,
                    wrapAlignment: WrapAlignment.spaceAround,
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22.0,color: Colors.black87),
                    pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration: Duration(milliseconds: 200),
                    keyboardType: TextInputType.number,
                  ),
                  if(hasError)
                    Text(S.of(context).pinCodeNotCorrect,style: TextStyle(color: Colors.red),),
                  SizedBox(height: 20,),
                  MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.black87,
                    minWidth: MediaQuery.of(context).size.width*0.6,
                    height: 40,
                    splashColor: Color(primaryColor),
                    onPressed: ()=>Navigator.pop(context),
                    child: Text(S.of(context).close,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            );
          }
      ),
      useRootNavigator: true,
      barrierDismissible: false,
      useSafeArea: true,
    );
    return result;
  }

  static showNotificationDialog(AppNotification notification, BuildContext context, VoidCallback? onOpen){
    try{
      showDialog(
        context: context,
        builder:(_context)=> AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(16),
          title: Text(
            '${notification.type?.replaceAll('_', ' ').toUpperCase()}',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text('${notification.body}', textAlign: TextAlign.center,),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(_context);
              },
              child: Text(S.of(context).close,style: TextStyle(color: Colors.red),),
            ),
            if(onOpen != null)
              TextButton(
                onPressed: onOpen,
                child: Text(S.of(context).open,style: TextStyle(color: Color(primaryColor)),),
              ),
          ],
        ),
      );
    }catch(e){
      Tools.consoleLog("[showRevisionNotificationDialog] $e");
    }
  }

  static Future<bool> showLocationPermissionDialog(BuildContext context)async{
    bool allow = true;
    await showDialog(
      context: context,
      builder:(_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This app collects location data to enable EmployeePunch even when the app is closed or not in use.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8,),
              Text('This app tracks locations data of this phone when your employees punch with their face on this phone.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()async{
              Navigator.pop(context);
            },
            child: Text(S.of(context).close,style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
    return allow;
  }

  static Future<bool> confirmDeleting(BuildContext context, String message)async{
    bool allow = false;
    await showDialog(
      context: context,
      builder:(_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,textAlign: TextAlign.center,),
              SizedBox(height: 8,),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()async{
              Navigator.pop(context);
            },
            child: Text(S.of(context).close,style: TextStyle(color: Color(primaryColor)),),
          ),
          TextButton(
            onPressed: ()async{
              allow = true;
              Navigator.pop(context);
            },
            child: Text(S.of(context).delete, style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
    return allow;
  }

  static Future<void> checkAppVersionDialog(BuildContext context, bool isForce)async{
    await showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder:(_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.all(0),
        content: WillPopScope(
          onWillPop: ()async{
            return !isForce;
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.of(context).newVersionAvailable, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                SizedBox(height: 8,),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()async{
              if(Platform.isAndroid){
                launch('https://play.google.com/store/apps/details?id=com.golden.star.facepunch');
              }else{
                launch('https://apps.apple.com/us/app/face-punch-vision/id1556243840');
              }
            },
            child: Text(S.of(context).update, style: TextStyle(color: Color(primaryColor)),),
          ),
          TextButton(
            onPressed: isForce?null:()async{
              Navigator.pop(context);
            },
            child: Text(S.of(context).close, style: TextStyle(color: isForce?Colors.grey:Colors.red),),
          ),
        ],
      ),
    );
  }

  static Future<bool> confirmDialog(BuildContext context, String message)async{
    bool allow = false;
    await showDialog(
      context: context,
      builder:(_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,textAlign: TextAlign.center,),
              SizedBox(height: 8,),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()async{
              Navigator.pop(context);
            },
            child: Text(S.of(context).close,style: TextStyle(color: Color(primaryColor)),),
          ),
          TextButton(
            onPressed: ()async{
              allow = true;
              Navigator.pop(context);
            },
            child: Text(S.of(context).ok, style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
    return allow;
  }

  static Future<void> showTimeOutDialog(BuildContext context, String message, {Color color = Colors.green, int time = 3})async{
    await showDialog(
      context: context,
      builder: (_context){
        Future.delayed(Duration(seconds: time)).whenComplete((){
          try{
            if(Navigator.canPop(_context)){
              Navigator.pop(_context);
            }
          }catch(e){
            Tools.consoleLog('[Tools.showTimeOutDialog.err]$e');
          }
        });
        return AlertDialog(
          backgroundColor: color,
          content: Text(message, style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center,),
        );
      },
    );
  }

  static Future<String> getFirebaseToken()async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('firebase_token');
      if(token == null){
        final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        token = await _firebaseMessaging.getToken();
        if(token != null){
          prefs.setString('firebase_token', token);
        }
      }
      return token??'';
    }catch(e){
      consoleLog('[Tools.getFirebaseToken]$e');
      return '';
    }
  }
}
