import '/lang/l10n.dart';
import '../config/app_const.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).aboutApp),
        centerTitle: true,
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Text("App Version: 2.0.0",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Text("Created By Philippe Vernier & Li Qiang",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}