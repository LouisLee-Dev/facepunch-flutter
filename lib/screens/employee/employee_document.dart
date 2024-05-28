import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

import '/providers/company_provider.dart';
import '/providers/user_provider.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';

class EmployeeDocument extends StatefulWidget {

  @override
  _EmployeeDocumentState createState() => _EmployeeDocumentState();
}

class _EmployeeDocumentState extends State<EmployeeDocument> {
  DateTime startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime endDate = DateTime.parse("${DateTime.now().year}-12-31");
  DateTime? selectedDate;
  String pdfError = "";
  double? pdfHeight;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = context.watch<UserProvider>().user;
    final settings = context.watch<CompanyProvider>().myCompanySettings;

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            height: kToolbarHeight+MediaQuery.of(context).padding.top,
            alignment: Alignment.center,
            color: Color(primaryColor),
            child: Text(S.of(context).document,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            padding: EdgeInsets.all(4),
            child: WeekPicker(
                selectedDate: selectedDate??DateTime.now(),
                onChanged: (v){
                  setState(() { selectedDate = v.start; pdfError=""; });
                },
                firstDate: startDate,
                lastDate: endDate,
                datePickerLayoutSettings: DatePickerLayoutSettings(
                  contentPadding: EdgeInsets.zero,
                  dayPickerRowHeight: 30,
                  monthPickerPortraitWidth: width,
                  maxDayPickerRowCount: 7,
                  scrollPhysics: NeverScrollableScrollPhysics()
                ),
                datePickerStyles: DatePickerRangeStyles(
                  selectedPeriodLastDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20.0)),
                  ),
                  selectedPeriodStartDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20.0)),
                  ),
                  selectedPeriodMiddleDecoration: BoxDecoration(color: Color(primaryColor)),
                  currentDateStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 18),
                  defaultDateTextStyle: TextStyle(fontSize: 16),
                )
            ),
          ),
          Expanded(
              child: Card(
                elevation: 8,
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        if (pdfError.isNotEmpty) Container(
                          alignment: Alignment.center,
                          height: 200,
                          child: Text(S.of(context).pdfNotGenerated),
                        ) else Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            height: pdfHeight == null ? 200 : pdfHeight!,
                            child: SfPdfViewer.network(
                              user!.pdfUrl(selectedDate),
                              key: Key(user.pdfUrl(selectedDate)),
                              onDocumentLoadFailed: (v){
                                  if(mounted)setState(() {pdfError = v.description;});
                              },
                              onDocumentLoaded: (v){
                                setState(() {
                                  pdfHeight = v.document.pageSettings.size.height/2;
                                });
                              },
                            ),
                          ),
                        ),
                        if(settings!.hasHarvestReport??false)
                          CachedNetworkImage(
                          imageUrl: user!.harvestReportUrl(),
                          width: width,
                          placeholder: (_,__)=>Container(
                            alignment: Alignment.center,
                            height: 200,
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_,__,___)=>Container(
                            alignment: Alignment.center,
                            height: 200,
                            child: Text(S.of(context).harvestReportNotGenerated),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}