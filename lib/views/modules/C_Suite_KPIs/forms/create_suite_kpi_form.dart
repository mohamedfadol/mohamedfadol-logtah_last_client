import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../colors.dart';
import '../../../../models/data/years_data.dart';
import '../../../../models/meeting_model.dart';
import '../../../../models/user.dart';
import '../../../../providers/financial_page_provider.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../providers/suite_kpi_provider_page.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custom_message.dart';
import '../../../../widgets/custome_text.dart';
import '../../../../widgets/dropdown_string_list.dart';
import '../../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../suite_kpi_list_view.dart';

class CreateSuiteKpiForm extends StatefulWidget {
  const CreateSuiteKpiForm({super.key });
  static const routeName = '/CreateSuiteKpiForm';

  @override
  State<CreateSuiteKpiForm> createState() => _CreateSuiteKpiFormState();
}

class _CreateSuiteKpiFormState extends State<CreateSuiteKpiForm> {
  User user = User();


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

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    return Scaffold(
      appBar: Header(context),
      body: Column(
        children: [
          buildFullTopFilter(),
          Expanded(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  child: Consumer<SuiteKpiProviderPage>(
                      builder: (context, provider, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // CEO KPI Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                    fileKey: 'ceo-kpi',
                                    buttonText: "CEO Key Performance Indicators",
                                    fileType: "kpi"
                                ),

                                SizedBox(width: 20),

                                // Long Term Incentive Plan Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                    fileKey: 'long-term-incentive',
                                    buttonText: "Long term Incentive Plan",
                                    fileType: "long-term"
                                ),

                                SizedBox(width: 20),

                                // Short Term Incentive Plan Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                    fileKey: 'short-term-incentive',
                                    buttonText: "Short term Incentive Plan",
                                    fileType: "short-term"
                                ),
                              ],
                            ),

                            SizedBox(height: 40),

                            // Submit button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                backgroundColor: Colour().primaryColor,
                              ),
                              onPressed: provider.uploadedFiles.isEmpty
                                  ? null  // Disable if no files are uploaded
                                  : () => _submitAllFiles(context, provider, committeeId),
                              child: provider.loading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : CustomText(
                                text: "Submit All Files",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

// Function to handle submission
  Future<void> _submitAllFiles(BuildContext context, SuiteKpiProviderPage provider, String committeeId) async {
    final scaffold = ScaffoldMessenger.of(context);

    if (provider.validateAllRequired()) {
        await provider.submitAllFiles(committeeId);

      if (!provider.loading) {
        scaffold.showSnackBar(
          SnackBar(
            content: CustomText(text: "All files uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // Optional: Navigate back or to another screen
        // Navigator.pop(context);
      } else {
        scaffold.showSnackBar(
          SnackBar(
            content: CustomText(text: "Failed to upload one or more files. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      scaffold.showSnackBar(
        SnackBar(
          content: CustomText(text: "Please upload all required files."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildUploadButton({
    required BuildContext context,
    required SuiteKpiProviderPage provider,
    required String fileKey,
    required String buttonText,
    required String fileType, // Add fileType parameter
  }) {
    String? uploadedFileName = provider.getUploadedFileName(fileKey);
    bool isFileMissing = provider.fileValidationErrors[fileKey] ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
          width: 300,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colour().buttonBackGroundRedColor,
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            icon: CustomIcon(icon: Icons.upload_file),
            label: CustomText(text: buttonText),
            onPressed: () => provider.pickFile(fileKey, fileType), // Pass fileType to pickFile
          ),
        ),
        if (uploadedFileName != null) ...[
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: CustomText(
                  text: "Uploaded: $uploadedFileName",
                  color: Colors.green,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: CustomIcon(icon: Icons.clear, size: 20, color: Colors.red,),
                onPressed: () => provider.clearUploadedFile(fileKey),
              ),
            ],
          ),
        ],
        if (isFileMissing) ...[
          SizedBox(height: 10),
          CustomText(
              text: "File is required!",
              color: Colors.red,
              fontWeight: FontWeight.bold
          ),
        ],
        if (provider.loading) ...[
          SizedBox(height: 10),
          CircularProgressIndicator(),
        ],
      ],
    );
  }


  Widget buildFullTopFilter() {
    return Consumer<FinancialPageProvider>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 15.0, right: 15.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 15.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0.0),
                      ),
                      // minimumSize: Size(200, 200), // Make it square
                      // padding: EdgeInsets.all(10),
                    ),
                    label: CustomText(text: "C-Suite KPI’s"),
                    icon: CustomIcon(icon: Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pushReplacementNamed(context,SuiteKpiListView.routeName),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                      vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(
                        text: AppLocalizations.of(context)!.select_year),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getListOfFinancials(provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                ),


              ],
            ),
          );
        }
    );
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


  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }
}
