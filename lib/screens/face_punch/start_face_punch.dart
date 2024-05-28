import 'package:flutter/material.dart';
import '/lang/l10n.dart';
import 'face_punch.dart';
import '../../config/app_const.dart';

class StartFacePunch extends StatefulWidget {

  @override
  _StartFacePunchState createState() => _StartFacePunchState();
}

class _StartFacePunchState extends State<StartFacePunch> {

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width*0.7;
    return Container(
      width: size,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            S.of(context).facePunch.toUpperCase(),
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10,),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>FacePunchScreen()));
            },
            child: Text(S.of(context).startFacePunch.toUpperCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
          ),
        ],
      ),
    );
  }

}