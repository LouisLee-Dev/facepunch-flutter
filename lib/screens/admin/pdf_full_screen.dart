import 'package:facepunch/config/app_const.dart';

import '/lang/l10n.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFFullScreen extends StatefulWidget{
  final String url;
  PDFFullScreen({required this.url});

  @override
  _PDFFullScreenState createState() => _PDFFullScreenState();
}

class _PDFFullScreenState extends State<PDFFullScreen> {

  String? pdfError;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).timeSheet),
        centerTitle: true,
        backgroundColor: Color(primaryColor),
        elevation: 0,
      ),
      body: pdfError!=null?Center(
        child: Text(S.of(context).pdfNotGenerated),
      ):SfPdfViewer.network(
        widget.url,
        key: Key(widget.url),
        onDocumentLoadFailed: (v){
          if(mounted)setState(() {pdfError = v.description;});
        },
        enableDoubleTapZooming: true,
      ),
    );
  }
}