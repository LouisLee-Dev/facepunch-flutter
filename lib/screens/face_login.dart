import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:wakelock/wakelock.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/admin/admin_home.dart';
import '/lang/l10n.dart';
import '/screens/employee/employee_home.dart';
import '/config/app_const.dart';
import '/widgets/utils.dart';
import 'dart:math' as math;
import '/providers/company_provider.dart';
import '/providers/user_provider.dart';

class FaceLogin extends StatefulWidget {

  @override
  _FaceLoginState createState() => _FaceLoginState();
}

class _FaceLoginState extends State<FaceLogin> {
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
  String _photoPath="";
  bool _isCameraAllowed = false;
  int _pageIndex = 0;
  String userName = "";

  @override
  void initState() {
    super.initState();
    Tools.checkCameraPermission().then((v){
      if(v && mounted){
        setState(() {_isCameraAllowed = true;});
      }
    });
    Wakelock.enable();
  }

  @override
  void dispose() {
    cameraClose();
    Wakelock.disable();
    super.dispose();
  }

  _initializeCamera() async {
    try{
      if(_isCameraAllowed){
        CameraDescription description = await Tools.getCamera(_direction);
        rotation = Tools.rotationIntToImageRotation(
          description.sensorOrientation,
        );
        cameraController = CameraController(
          description,
          Platform.isIOS? ResolutionPreset.medium
              : ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        await initDetectFace();
      }else{
        Tools.showErrorMessage(context, S.of(context).allowCameraPermissionToTakePictures);
      }
    }on CameraException catch(e){
      Tools.consoleLog('[EmployeeLogin._initializeCamera.err]$e');
    }
  }

  Future<void> initDetectFace()async{
    try{
      if(cameraController!.value.isStreamingImages)return;
      cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || !mounted) return;
        _isDetecting = true;
        Tools.detect(image, GoogleMlKit.vision.faceDetector().processImage, rotation!)
            .then((dynamic result) {
          if(mounted)setState(() {faces = result;});
          _isDetecting = false;
        }).catchError((e) {
          Tools.consoleLog('[EmployeeLogin.initDetectFace.detect.err]$e');
          _isDetecting = false;
        }
        );
      }).catchError((e){
        Tools.consoleLog('[EmployeeLogin.initDetectFace.err]$e');
        Tools.showErrorMessage(context, e.toString());}
      );
    }on CameraException catch(e){
      Tools.consoleLog('[EmployeeLogin.initDetectFace.err]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> cameraClose()async{
    try{
      if (cameraController!=null) {
        await Future.delayed(new Duration(milliseconds: 100));
        await cameraController?.dispose();
      }
    }on CameraException catch(e){
      Tools.consoleLog('[EmployeeLogin.cameraClose.err]$e');
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
      await Future.delayed(new Duration(milliseconds: 100));
      XFile file = await cameraController!.takePicture();
      setState(() {_photoPath = file.path;});
    } on CameraException catch (e) {
      Tools.showErrorMessage(context, e.toString());
      Tools.consoleLog('[EmployeeLogin.takePhoto.CameraException]$e');
    }catch(e){
      Tools.consoleLog('[EmployeeLogin.takePhoto.err]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<bool> loginWithFace(String path)async{
    try{
      String base64Image = base64Encode(File(path).readAsBytesSync());
      String? result = await context.read<UserProvider>().loginWithFace(base64Image);
      if(result==null){
        return true;
      }else{
        Tools.showErrorMessage(context, result);
      }
    }catch(e){
      Tools.consoleLog("[EmployeeLogin.loginWithFace.err] $e");
      Tools.showErrorMessage(context, e.toString());
    }
    return false;
  }

  Widget loginWithFaceWidget(){
    final size = MediaQuery.of(context).size.width*0.7;
    try{
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    width: size,
                    height: size,
                    padding: EdgeInsets.all(8),
                    child: _photoPath.isEmpty
                        ?(cameraController == null || !cameraController!.value.isInitialized)
                        ?Center(child: CircularProgressIndicator(),)
                        :ClipRect(
                      child: Transform.scale(
                          scale: cameraController!.value.aspectRatio,
                          child: Center(
                              child: CameraPreview(
                                cameraController!,
                                child: Tools.faceRect(cameraController!, faces, 2.0),
                              )
                          )
                      ),
                    )
                        :Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.file(
                        File(_photoPath),
                        fit: BoxFit.cover,
                      ),
                    )
                ),
                Container(
                  alignment: Alignment.center,
                  width: size,
                  height: size,
                  child: Image.asset(
                    "assets/images/overlay.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          RoundedLoadingButton(
            child: Text(_photoPath.isEmpty?S.of(context).takePicture.toUpperCase():S.of(context).tryAgain.toUpperCase(),
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
            ),
            controller: _btnController,
            width: size,
            onPressed: ()async{
              if(_photoPath.isEmpty){
                bool result = false;
                await takePhoto();
                if(_photoPath.isNotEmpty){
                  result = await loginWithFace(_photoPath);
                }
                _btnController.reset();
                if(result){
                  final user = context.read<UserProvider>().user;
                  if(mounted){setState(() {_pageIndex = 2; userName = "${user?.getFullName()}";});}
                  await context.read<CompanyProvider>().getMyCompany(user?.companyId);
                  if(mounted){
                    if(user!.role == 'admin' || user.role == 'sub_admin'){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
                    }else{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
                    }

                  }
                }
              }else{
                await initDetectFace();
                setState(() {_photoPath="";});
                _btnController.reset();
              }
            },
            height: 40,
            color: Colors.black87,
          )
        ],
      );
    }catch(e){
      Tools.consoleLog("[EmployeeLogin.loginWithFaceWidget.err] $e");
      return SizedBox();
    }
  }

  Widget mainWidget(){
    if(_pageIndex==0){
      final size = MediaQuery.of(context).size.width*0.7;
      return Column(
        children: [
          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/overlay.png",width: size,),
                  Image.asset("assets/images/person.png",width: size,),
                ],
              )
          ),
          SizedBox(height: 10,),
          MaterialButton(
            minWidth: size,
            height: 40,
            splashColor: Color(primaryColor),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.black87,
            onPressed: (){
              _initializeCamera();
              setState(() {_pageIndex=1;});
            },
            child: Text(S.of(context).faceScanLogin,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
          )
        ],
      );
    }
    if(_pageIndex==1){
      return loginWithFaceWidget();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(S.of(context).welcome,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        Text(userName,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(S.of(context).signIn, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          Expanded(
              child: mainWidget()
          ),
        ],
      ),
    );
  }

}