import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../colors.dart';
import '../../../../models/meeting_model.dart';
import '../../../../models/user.dart';
import '../../../../providers/financial_page_provider.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custom_message.dart';
import '../../../../widgets/custome_text.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../../widgets/header_language_widget.dart';
import '../../../../widgets/loading_sniper.dart';
import '../financial_list_views.dart';


class CreateFinancialForm extends StatefulWidget {
  final String committeeId;
  const CreateFinancialForm({super.key, required this.committeeId});
  static const routeName = '/CreateFinancialForm';
  @override
  State<CreateFinancialForm> createState() => _CreateFinancialFormState();
}

class _CreateFinancialFormState extends State<CreateFinancialForm> {
  User user = User();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }
  
  Widget buildMeetingAndMinutesDropDownList() {
    return Consumer<MeetingPageProvider>(
      builder: (BuildContext context, Mprovider, widget) {
        if (Mprovider.dataOfMeetings?.meetings == null) {
          Mprovider.getListOfPublishedMeetingsThatNotHasMinutes();
          return buildLoadingSniper();
        }

        if (Mprovider.dataOfMeetings!.meetings!.isEmpty) {
          return buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show);
        }

        List<DropdownMenuItem<String>> dropdownItems = [
          DropdownMenuItem<String>(
            value: "",
            child: CustomText(
                text: AppLocalizations.of(context)!.select_meeting_name,
                color: Colors.white),
          )
        ];

        dropdownItems.addAll(Mprovider.dataOfMeetings!.meetings!.map((Meeting meeting) {
          return DropdownMenuItem<String>(
            value: meeting.meetingId.toString(),
            child: CustomText(text: meeting.meetingTitle!, color: Colors.black),
          );
        }).toList());

        return Container(
          constraints: const BoxConstraints(minHeight: 30.0),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.red,
              boxShadow: const [
                BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
              ]),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.titleLarge,
              // Dynamic hint based on whether an item is selected
              hint: Mprovider.selectedMeetingId == null || Mprovider.selectedMeetingId == ""
                  ? CustomText(
                  text: AppLocalizations.of(context)!.select_meeting_name,
                  color: Colors.white)
                  : CustomText(
                  text: Mprovider.dataOfMeetings!.meetings!.firstWhere(
                          (meeting) => meeting.meetingId.toString() == Mprovider.selectedMeetingId,
                      orElse: () => Meeting(meetingTitle: 'No meeting found')).meetingTitle!,
                  color: Colors.black),
              value: Mprovider.selectedMeetingId == "" ? null : Mprovider.selectedMeetingId,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white),
              dropdownColor: Colors.white60,
              focusColor: Colors.redAccent[300],
              items: dropdownItems,
              onChanged: (String? newValue) {
                Mprovider.setSelectedMeetingId(newValue);
                Provider.of<MeetingPageProvider>(context, listen: false).selectedMeetingId;

              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              buildFullTopFilter(),
              SizedBox(height: 20,),
              Center(
                child: Consumer<FinancialPageProvider>(
                    builder: (context, provider, child) {
                      final enableArabic = context.watch<MeetingPageProvider>().enableArabic;
                      final enableEnglish = context.watch<MeetingPageProvider>().enableEnglish;
                      final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;


                      String? uploadedFileName = provider.getUploadedFileName('financial');
                      bool isFileMissing = provider.fileValidationErrors['financial'] ?? false;

                      final TextEditingController financialEnglishName = TextEditingController();
                      final TextEditingController financialArabicName = TextEditingController();

                     return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if(enableEnglish)
                                  Container(
                                    width: 700,
                                    child: TextFormField(
                                      controller: financialEnglishName,
                                      decoration: InputDecoration(
                                        labelText: "Financial Name",
                                        labelStyle: TextStyle(color: Colors.redAccent),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (val) {
                                        if (val!.isNotEmpty) {
                                          return null;
                                        } else {
                                          return 'Enter a valid statements Name';
                                        }
                                      },
                                    ),
                                  ),

                                  if(enableArabic)
                                    Container(
                                      width: 700,
                                      child: TextFormField(
                                        controller: financialArabicName,
                                        decoration: InputDecoration(
                                          labelText: "التقرير المالي",
                                          labelStyle: TextStyle(color: Colors.redAccent),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (val) {
                                          if (val!.isNotEmpty) {
                                            return null;
                                          } else {
                                            return 'أدخل التقرير المالي';
                                          }
                                        },
                                      ),
                                    ),

                                  const SizedBox(height: 15),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7.0, horizontal: 15.0),
                                      width: 700,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10),
                                        ),
                                        color: Colour().buttonBackGroundRedColor,
                                      ),
                                      child: buildMeetingAndMinutesDropDownList()
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.0, horizontal: 15.0),
                                    width: 700,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10),
                                      ),
                                      color: Colour().buttonBackGroundRedColor,
                                      ),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                      icon: CustomIcon(icon: Icons.upload_file),
                                      label: CustomText(text: "Import File"),
                                      onPressed: () => provider.pickFile('financial'),
                                    ),
                                  ),
                                  if (uploadedFileName != null) ...[
                                    SizedBox(height: 10),
                                    CustomText(text: "Uploaded: $uploadedFileName", color: Colors.green),
                                  ],
                                  if (isFileMissing) ...[
                                    SizedBox(height: 10),
                                    CustomText(text: "File is required!", fontWeight: FontWeight.bold),
                                  ],
                                  if (provider.loading) ...[
                                    SizedBox(height: 10),
                                    CircularProgressIndicator(),
                                  ],
                                  SizedBox(height: 15,),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.0, horizontal: 15.0),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                                      color: Colour().buttonBackGroundRedColor,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: provider.loading
                                          ? null
                                          : () async {

                                          provider.setLoading(true);


                                        User user = User();
                                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                                        user = User.fromJson(json.decode(prefs.getString("user")!));

                                        bool isValid = provider.validateFile('financial');
                                        final FormState? form = _formKey.currentState;
                                        String? meetingId = Provider.of<MeetingPageProvider>(context, listen: false).selectedMeetingId;

                                        if (form != null && form.validate()) {
                                          String? base64File = await provider.getFileAsBase64('financial');
                                          print(base64File);
                                          Map<String, dynamic> data = {
                                            "financial_name_ar": financialArabicName.text,
                                            "financial_name_en": financialEnglishName.text,
                                            "meeting_id": meetingId,
                                            "financial_file": base64File,
                                            "business_id": user.businessId.toString(),
                                            "committee_id": widget.committeeId,
                                            "add_by": user.userId.toString()
                                          };
                                          await provider.insertFinancial(data);
                                          if (provider.isBack) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: CustomText(text: "Financial File added successfully"),
                                                backgroundColor: Colors.greenAccent,
                                              ),
                                            );
                                            provider.clearUploadedFile('financial');
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: CustomText(text: "Financial File added failed"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: CustomText(text: "No bonus scheme file uploaded!", color: Colors.red),
                                            ),
                                          );
                                        }
                                        provider.setLoading(false);
                                      },
                                      child: provider.loading
                                          ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                          : CustomText(text: "Save"),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      );
                    }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget buildFullTopFilter() {
    return Consumer<FinancialPageProvider>(
        builder: (BuildContext context, provider, child) {

          final enableArabic = context.watch<MeetingPageProvider>().enableArabic;
          final enableEnglish = context.watch<MeetingPageProvider>().enableEnglish;
          final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;

          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: ElevatedButton(
                        onPressed: () async{
                          Navigator.pushReplacementNamed(context, FinancialListViews.routeName);
                        },
                        child: CustomIcon(icon: Icons.arrow_back_rounded)
                    ),
                ),

                Spacer(),
                LanguageWidget(
                    enableEnglish: enableEnglish,
                    enableArabicAndEnglish: enableArabicAndEnglish,
                    enableArabic: enableArabic),
              ],
            ),
          );
        }
    );
  }
}
