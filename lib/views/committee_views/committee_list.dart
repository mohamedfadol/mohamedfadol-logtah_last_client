import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../NetworkHandler.dart';
import '../../core/domains/app_uri.dart';
import '../../models/user.dart';
import '../../providers/committee_provider_page.dart';
import '../../providers/meeting_page_provider.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/stand_text_form_field.dart';

class CommitteeList extends StatefulWidget {
  const CommitteeList({Key? key}) : super(key: key);
  static const routeName = '/CommitteeList';

  @override
  State<CommitteeList> createState() => _CommitteeListState();
}

class _CommitteeListState extends State<CommitteeList> {

  final insertCommitteeFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:5.0, horizontal: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Consumer<MeetingPageProvider>(
                builder: (context,  provider, child){
                  if(provider.dataOfMeetings?.meetings == null){
                    provider.getListOfMeetingsCommittees(context);
                    return Center(
                      child: SpinKitThreeBounce(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: index.isEven ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return provider.dataOfMeetings!.meetings!.isEmpty ?
                  Center(child: CustomText(text:'no data found',fontWeight: FontWeight.bold,color: Colors.red,),) :
                    SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        showBottomBorder: true,
                        dividerThickness: 5.0,
                        columns:const [
                          DataColumn(
                              label: Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "show Committee name"),

                          DataColumn(
                              label: Text("Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "show Committee Date"),

                          DataColumn(
                              label: Text("File",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "File"),

                          DataColumn(
                              label: Text("Presented at",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "Presented at"),

                          DataColumn(
                              label: Text("Owner",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "Owner"),

                          DataColumn(
                              label: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                              tooltip: "show buttons for functionality members"),
                        ],
                        rows: provider!.dataOfMeetings!.meetings!.map((meeting) =>
                            DataRow(
                                cells: [
                                  DataCell(Text(meeting!.meetingTitle!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                  DataCell(Text('${meeting!.meetingStart!}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                  DataCell(
                                    TextButton(
                                      onPressed: () async{
                                        var businessName = meeting!.committee!.business!.businessId!;
                                        String charterName = meeting!.meetingFile!;
                                        String url = "${AppUri.publicUploadCharters}/$businessName/$charterName";
                                        print(url);
                                        openPDF(context,url,charterName);
                                      },
                                      child: Text(meeting?.meetingFile ?? 'Circular',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),),
                                    ),

                                  ),
                                  DataCell(Text(meeting?.meetingBy ?? 'loading ...',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),
                                  DataCell(Text(meeting?.user?.firstName ?? 'loading ...',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0),)),

                                  DataCell(
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.min,
                                          children:[
                                            ElevatedButton.icon(
                                              label: const Text('View',style: TextStyle(color: Colors.white),),
                                              icon: const Icon(Icons.remove_red_eye_outlined,color: Colors.white),
                                              onPressed: () {print('View');},
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(horizontal: 10.0)
                                              ),
                                            ),
                                            const SizedBox(width: 5.0,),
                                            ElevatedButton.icon(
                                              label: const Text('Export',style: TextStyle(color: Colors.white),),
                                              icon: const Icon(Icons.import_export_outlined,color: Colors.white),
                                              onPressed: () {print('Export');},
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(horizontal: 10.0)
                                              ),
                                            ),
                                            const SizedBox(width: 5.0,),
                                            ElevatedButton.icon(
                                              label: const Text('Sign',style: TextStyle(color: Colors.white),),
                                              icon: const Icon(Icons.checklist_outlined,color: Colors.white),
                                              onPressed: () {print('Sign');},
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(horizontal: 10.0)
                                              ),
                                            ),

                                          ]
                                      ),
                                    ),
                                  ),
                                ]
                            )
                        ).toList(),
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }




  void openPDF(BuildContext context, String file,String fileName) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPageSyncfusionPackage(file: file, fileName: fileName,)),
  );
}
