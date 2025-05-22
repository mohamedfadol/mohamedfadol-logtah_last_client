import 'dart:convert';

import 'package:diligov_members/models/nomination_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../colors.dart';
import '../../../core/domains/app_uri.dart';
import '../../../models/data/years_data.dart';
import '../../../models/user.dart';
import '../../../providers/nomination_page_provider.dart';
import '../../../utility/custome_pdf_viewr.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';

class NominationsList extends StatefulWidget {
  const NominationsList({super.key});
  static const routeName = '/NominationsList';
  @override
  State<NominationsList> createState() => _NominationsListState();
}

class _NominationsListState extends State<NominationsList> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setLandscapeMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetOrientation();
    super.dispose();
  }

  // Force landscape mode
  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Reset to default orientation
  void _resetOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }


  // Ensure landscape mode remains when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setLandscapeMode();
    }
  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return PopScope(
      canPop: false, // Determines whether the screen can pop
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Reset to default orientation when leaving the screen
          _resetOrientation(); // Reset orientation only when actually leaving
        }
      },
      child: Scaffold(
        appBar: Header(context),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Static filter section (no scrolling)
              buildFullTopFilter(),

              // Consumer to load nominations
              Expanded(
                child: Consumer<NominationPageProvider>(
                  builder: (BuildContext context, provider, widget) {
                    if (provider.nominationsData?.nominations == null) {
                      provider.getListOfNominations(provider.yearSelected);
                      return buildLoadingSniper();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Only Row scrolls
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 400,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                    color: Colour().buttonBackGroundRedColor,
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                         showUploadDialog(context, 'test');
                                    },
                                    child: CustomText(
                                      text: 'Add Candidate',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // This Row should be scrollable, not the whole page
                          provider.nominationsData!.nominations!.isEmpty
                              ? buildEmptyMessage(
                              AppLocalizations.of(context)!.no_data_to_show)
                              : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: provider.loading ? Center(child: CircularProgressIndicator(),) : buildNominationList(provider.nominationsData!.nominations!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  /// **Builds nomination cards in a two-column format**
  Widget buildNominationList(List<NominationModel> nominations) {
    List<Widget> rows = [];

    for (int i = 0; i < nominations.length; i += 2) {
      List<Widget> rowChildren = [];

      // First nomination in the row
      rowChildren.add(buildNominationCard(nominations[i].nominateName!, nominations[i]));

      // Second nomination (if exists)
      if (i + 1 < nominations.length) {
        rowChildren.add(SizedBox(width: 20)); // Space between columns
        // rowChildren.add(buildNominationCard(nominations[i + 1].nominateName!, nominations[i]));
        rowChildren.add(buildNominationCard(nominations[i + 1].nominateName!, nominations[i + 1]));

      }

      rows.add(Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: rowChildren,
      ));

      rows.add(SizedBox(height: 20)); // Space between rows
    }

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rows,
    );
  }

  /// **Creates a card for a nomination**
  Widget buildNominationCard(String nominateName,NominationModel nominate) {
    return  Consumer<NominationPageProvider>(
        builder: (BuildContext context, provider, widget) {
          return Container(
            width: 500,
            // height: 100,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async { await dialogDeleteNominate(nominate);},
                    child: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,)
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                    onPressed: () async{
                      provider.setLoading(true);
                      final  String  url = '${AppUri.baseUntilPublicDirectoryMeetings}';
                      String fullUrl = '$url/${nominate.nominateCv?.trim()}';
                      print("fullUrl path is -------- $fullUrl");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder:
                                  (context) =>
                                  CustomPdfView(path: fullUrl)));
                      provider.setLoading(false);
                    },
                    child: CustomIcon(icon: Icons.open_in_new)
                ),
                SizedBox(width: 10,),
                CustomText(
                  text: nominateName,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  // color: Colors.white,
                ),
              ],
            ),
          );
        }
          );

  }

  Future dialogDeleteNominate(NominationModel nominate) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.are_you_sure_to_delete} ${nominate.nominateName!} ?",
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_delete,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: ()  {
                                 removeNominate(nominate);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void removeNominate(NominationModel nominate) {
    final provider = Provider.of<NominationPageProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      provider.removeNominate(nominate);
    });
    if (provider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: "remove done"),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: "remove failed",),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }


  /// **Dialog for Uploading PDF/Word Files**
  void showUploadDialog(BuildContext context, String nomineeName) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NominationPageProvider>(
          builder: (context, uploadProvider, child) {
            String? uploadedFileName = uploadProvider.getUploadedFileName(nomineeName);
            bool isFileMissing = uploadProvider.fileValidationErrors[nomineeName] ?? false;
            return SingleChildScrollView(
              child: AlertDialog(
                title: CustomText(text: "Upload Document for $nomineeName"),
                content: SizedBox(
                  width: 500,
                  height: 300,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          validator: (val) => val != null && val.isEmpty ? "Name Required" : null,
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Enter Name",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            uploadProvider.saveEnteredName(nomineeName, value);
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(0.0),
                            ),
                            // minimumSize: Size(200, 200), // Make it square
                            // padding: EdgeInsets.all(10),
                          ),
                          icon: CustomIcon(icon: Icons.upload_file),
                          label: CustomText(text: "Upload CV"),
                          onPressed: () => uploadProvider.pickFile(nomineeName),
                        ),
                        if (uploadedFileName != null) ...[
                          SizedBox(height: 10),
                          CustomText(text: "Uploaded: $uploadedFileName",color: Colors.green),
                        ],
                        if (isFileMissing) ...[
                          SizedBox(height: 10),
                          CustomText(text:"File is required!", fontWeight: FontWeight.bold),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: CustomText(text: "Close"),
                  ),
                  TextButton(
                    onPressed: () async{
                      User user = User();
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      user =  User.fromJson(json.decode(prefs.getString("user")!)) ;

                      bool isValid = uploadProvider.validateFile(nomineeName);
                      final FormState form = _formKey.currentState!;
                      if (form.validate()) {
                        String? base64File = await uploadProvider.getFileAsBase64(nomineeName);
                        if (isValid) {

                          Map<String, dynamic> data = {
                            "nominate_name": nameController.text,
                            "cv_file": base64File,
                            'business_id': user.businessId.toString(),
                          };

                          Future.delayed(Duration.zero, () {
                            uploadProvider.insertNewNomination(data);
                          });

                          if(uploadProvider.loading == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomText(text:"Nominate added successfully"),
                                backgroundColor: Colors.greenAccent,
                              ),
                            );
                              Navigator.pop(context);
                          }else{
                            uploadProvider.setLoading(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomText(text: "Nominate added failed" ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: CustomText(text: "No file uploaded!", color: Colors.red,)));
                        }
                      }
                    },
                    child: CustomText(text: "Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  Widget buildFullTopFilter() {
    return Consumer<NominationPageProvider>(
        builder: (BuildContext context, provider, child) {
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
                    child: CustomText(
                        text: "Nominations",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )),
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
                      await provider.getListOfNominations(
                          provider.yearSelected);
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
}
