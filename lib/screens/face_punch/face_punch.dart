import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/models/notification.dart';
import '/models/revision_model.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/user_model.dart';
import '/widgets/utils.dart';
import 'select_task.dart';
import '/providers/user_provider.dart';

class FacePunchScreen extends StatefulWidget {

  @override
  _FacePunchScreenState createState() => _FacePunchScreenState();
}

class _FacePunchScreenState extends State<FacePunchScreen>{

  final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    mode: FaceDetectorMode.fast,
    enableLandmarks: true,
    enableClassification: true,
    enableContours: true,
    enableTracking: true,
  ));
  List<Face>? faces;
  CameraController? cameraController;
  CameraLensDirection _direction = CameraLensDirection.front;
  InputImageRotation? rotation;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool _isDetecting = false;
  bool hasError = false;
  String _photoPath="";
  bool _isCameraAllowed = false;
  Position? currentPosition;
  OverlayEntry? _revisionOverlay;

  @override
  void initState() {
    super.initState();
    _init();
  }


  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  _init()async{
    _isCameraAllowed = await Tools.checkCameraPermission();
    if(mounted){
      setState(() {});
      _initializeCamera();
      _determinePosition();
      Wakelock.enable();
      Tools.setupFirebaseNotification(_onMessage);
    }
  }

  _onMessage(message)async{
    try{
      AppNotification notification = AppNotification.fromJsonFirebase(message.data);
      if(mounted){
        if(notification.hasRevision()){
          String description = '';
          String? errorMessage;
          _revisionOverlay = OverlayEntry(
            builder: (_)=>StatefulBuilder(builder: (BuildContext _context, StateSetter _setState){
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.8),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.zero,
                  title: Text(
                    S.of(context).revisionDescription,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width-50,
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
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
                  ),
                  actions: [
                    TextButton(
                      onPressed: ()async{
                        if(description.isNotEmpty){
                          _revisionOverlay?.remove();
                          context.loaderOverlay.show();
                          String? message = await Revision(id: notification.revisionId).update(description);
                          context.loaderOverlay.hide();
                          if(message == null){
                            Tools.showSuccessMessage(context, S.of(context).revisionDescriptionSubmitted);
                          }else{
                            Tools.showErrorMessage(context, message);
                          }
                        }else{
                          _setState(() { errorMessage = S.of(context).youMustWriteDescription; });
                        }
                      },
                      child: Text(S.of(context).submit, style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              );
            }),
          );
          Overlay.of(context)!.insert(_revisionOverlay!);
        }
      }
    }catch(e){
      Tools.consoleLog('[FacePunchScreen._onMessage]$e');
    }
  }

  _initializeCamera({CameraDescription? description}) async {
    try{
      if(_isCameraAllowed){
        if(description == null){
          description = await Tools.getCamera(_direction);
          if(!mounted)return;
        }
        rotation = Tools.rotationIntToImageRotation(description.sensorOrientation);
        cameraController = CameraController(
          description,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        if(!mounted)return;
        await initDetectFace();
        if(!mounted)return;
      }else{
        Tools.showErrorMessage(context, S.of(context).allowCameraPermissionToTakePictures);
      }
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunchScreen._initializeCamera]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> initDetectFace()async{
    try{
      if(cameraController!.value.isStreamingImages)return;
      cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || !mounted) return;
        _isDetecting = true;
        Tools.detect(image, GoogleMlKit.vision.faceDetector().processImage, rotation!).then((dynamic result) {
          if(mounted)setState(() {faces = result;});
          _isDetecting = false;
        }).catchError((e) {
          Tools.consoleLog('[FacePunch.initDetectFace.detect]$e');
        _isDetecting = false;
        },);
      }).catchError((e){
        Tools.consoleLog('[FacePunch.initDetectFace.startImageStream]$e');
      Tools.showErrorMessage(context, e.toString());
      });
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunch.initDetectFace]$e');
      Tools.showErrorMessage(context, e.toString());
    }on PlatformException catch(e){
      Tools.consoleLog('[FacePunch.initDetectFace]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> cameraClose()async{
    try{
      if (cameraController!=null) {
        if(cameraController!.value.isStreamingImages){
          await cameraController!.stopImageStream();
        }
        await faceDetector.close();
        await Future.delayed(Duration(milliseconds: 100));
        await cameraController?.dispose();
      }
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunch.cameraClose]$e');
      Tools.showErrorMessage(context, e.toString());
    }on PlatformException catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[FacePunch.cameraClose]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> takePhoto() async {
    try {
      if(cameraController == null){
        Tools.showErrorMessage(context, S.of(context).allowCameraPermissionToTakePictures);
        return ;
      }
      if (!cameraController!.value.isInitialized) {
        return ;
      }
      if (cameraController!.value.isTakingPicture) {
        return ;
      }
      if(cameraController!.value.isStreamingImages){
        await cameraController!.stopImageStream();
      }
      await Future.delayed(Duration(milliseconds: 100));
      XFile file = await cameraController!.takePicture();
      setState(() {_photoPath = file.path;});
      await _punchWithFace(file.path);
      await File(file.path).delete().catchError((e){
        Tools.consoleLog('[FacePunch.takePhoto.delete]$e');
      });
    } on CameraException catch (e) {
      Tools.showErrorMessage(context, e.toString());
      Tools.consoleLog('[FacePunch.takePhoto.CameraException]$e');
    } catch(e){
      Tools.showErrorMessage(context, e.toString());
      Tools.consoleLog('[FacePunch.takePhoto]$e');
    }
  }

  _determinePosition() async {
    Tools.checkLocationPermission(context).then((v){
      if(v){
        Geolocator.getCurrentPosition().then((value){currentPosition = value;}).catchError((e){
          Tools.consoleLog('[FacePunchScreen.getCurrentPosition]$e');
        });
      }else{
        Tools.showErrorMessage(context, S.of(context).locationPermissionDenied);
      }
    });
  }

  _punchWithFace(String path)async{
    try{
      Tools.playSound();
      String base64Image = base64Encode(File(path).readAsBytesSync());
      var result = await context.read<UserProvider>().punchWithFace(
          photo: base64Image,
          latitude: currentPosition?.latitude,
          longitude: currentPosition?.longitude
      );
      if(result is String){
        Tools.showErrorMessage(context, result);
      }else if(result is FacePunchData){
        User employee = result.employee;
        GlobalData.token = employee.token??'';
        result.longitude = currentPosition?.longitude;
        result.latitude = currentPosition?.latitude;
        if(result.punch != null){
          if(result.punch!.isIn()){
            Tools.showSuccessMessage(context, "${S.of(context).welcome}, ${employee.name}");
          }else{
            Tools.showErrorMessage(context, "${S.of(context).bye}, ${employee.name}");
          }
        }else{
          await Navigator.push(context, MaterialPageRoute(
              builder: (context)=>SelectTaskScreen(result)
          ));
        }
        await initDetectFace();
        setState(() {_photoPath="";});
      }
    }catch(e){
      Tools.consoleLog("[EmployeeLogin.punchWithFace] $e");
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Widget _body(){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget closeButton = Positioned(
      top: MediaQuery.of(context).padding.top+30,
      right: 0,
      child: MaterialButton(
        onPressed: ()async{
          await cameraClose();
          if(mounted && Navigator.canPop(context))Navigator.pop(context);
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: CircleBorder(),
        padding: EdgeInsets.zero,
        color: Color(primaryColor),
        child: Icon(Icons.close, color: Colors.white,),
      ),
    );
    Widget captureButton = Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: RoundedLoadingButton(
        child: Text(_photoPath.isEmpty?S.of(context).takePicture.toUpperCase():S.of(context).tryAgain,
          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
        ),
        controller: _btnController,
        width: width-80,
        onPressed: ()async{
          if(_photoPath.isEmpty){
            await takePhoto();
            _btnController.reset();
          }else{
            await initDetectFace();
            setState(() {_photoPath="";});
            _btnController.reset();
          }
        },
        height: 40,
        color: Colors.black87,
      ),
    );

    if(_photoPath.isNotEmpty){
      return Stack(
        children: [
          Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Image.file(
                File(_photoPath),
                fit: BoxFit.cover,
                width: width,
                height: height,
              ),
            ),
          ),
          closeButton,
          captureButton
        ],
      );
    }
    if(cameraController != null && cameraController!.value.isInitialized){
      var tmp = MediaQuery.of(context).size;
      final screenH = math.max(tmp.height, tmp.width);
      final screenW = math.min(tmp.height, tmp.width);
      tmp = cameraController!.value.previewSize!;
      final previewH = math.max(tmp.height, tmp.width);
      final previewW = math.min(tmp.height, tmp.width);
      final screenRatio = screenH / screenW;
      final previewRatio = previewH / previewW;

      return Stack(
        children: [
          ClipRRect(
            child: OverflowBox(
              maxHeight: screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
              maxWidth: screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
              child: CameraPreview(
                cameraController!,
                child: Tools.faceRect(cameraController!, faces, 5.0)
              ),
            ),
          ),
          closeButton,
          captureButton
        ],
      );
    }
    return Stack(
      children: [
        Center(child: CircularProgressIndicator(),),
        closeButton,
        captureButton
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: _body(),
      ),
      backgroundColor: Color(primaryColor),
      resizeToAvoidBottomInset: false,
    );
  }
}