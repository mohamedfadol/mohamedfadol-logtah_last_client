import 'dart:convert';
import 'dart:io';

import 'package:diligov_members/models/disclosure_model.dart';
import 'package:diligov_members/providers/disclosure_page_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NetworkHandler.dart';
import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../models/user.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_disclosure_api.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/date_format_text_form_field.dart';
import '../../../widgets/dropdown_string_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../widgets/loading_sniper.dart';
import '../../../widgets/stand_text_form_field.dart';

class DisclosureListViews extends StatefulWidget {
  const DisclosureListViews({super.key});
  static const routeName = '/DisclosureListViews';

  @override
  State<DisclosureListViews> createState() => _DisclosureListViewsState();
}

class _DisclosureListViewsState extends State<DisclosureListViews> {

  final insertDisclosureFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  // Initial Selected Value
  String yearSelected = '2023';
  List<String> TypeList = ['Competition','Related_Party '];
  String typeL = 'Competition';
  late String _business_id;
  String? _fileBase64;
  String? _fileName;
  FilePickerResult? result;
  String? _fileNameNew;
  PlatformFile? pickedFiles;
  void pickedFile() async {
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        _fileNameNew = result!.files.first.name;
        pickedFiles = result!.files.first;
        _fileName = pickedFiles!.path!;
        print("file name $_fileNameNew");
        print("file pickedFiles with path $_fileName");
      }
    } catch (e) {
      print(e);
    }
  }

  TextEditingController disclosureName = TextEditingController();
  TextEditingController disclosureDate = TextEditingController();
  TextEditingController disclosureType = TextEditingController();
  late DisclosurePageProvider providerDisclosure;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      yearSelected = '2023';
      typeL = 'Competition';
      providerDisclosure = Provider.of<DisclosurePageProvider>(context,listen: false);
      PdfDisclosureApi.getLocale(context);
      PdfDisclosureApi.getTextDirection(context);
      PdfDisclosureApi.getTextAlign(context);
      PdfDisclosureApi.getLocale(context);
      // PdfDisclosureApi.getLang(context);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    disclosureName.dispose();
    disclosureDate.dispose();
    disclosureType.dispose();
    pickedFiles = null;
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";


    return Scaffold(
      appBar: Header(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await openDisclosureCreateDialog();
              },
              child: CustomIcon(
                icon: Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
              backgroundColor: Colors.red,
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                // await openAnnualReportCreateDialog();
              },
              label: CustomText(text: 'Remind non signed members',
                fontSize: 18.0,
                color: Colors.white,
              ),
              icon: CustomIcon(
                icon: Icons.picture_as_pdf,
                color: Colors.white,
              ),
              backgroundColor: Colors.red,
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(committeeId),
              Center(
                child: Consumer<DisclosurePageProvider>(
                    builder: (context, provider, child) {
                      if (provider.disclosuresData?.disclosures == null) {
                        provider.getListOfDisclosures(provider.yearSelected, committeeId);
                        return buildLoadingSniper();
                      }
                      return provider.disclosuresData!.disclosures!.isEmpty
                          ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            showBottomBorder: true,
                            dividerThickness: 5.0,
                            headingRowColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                Colour().darkHeadingColumnDataTables),
                            // dataRowColor: MaterialStateColor.resolveWith((states) => Colour().lightBackgroundColor),
                            columns: <DataColumn>[
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .name,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show minute name"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!.date,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show minute Date"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!.file,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "file"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .type,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "meeting name"),
                              DataColumn(
                                  label: CustomText(
                                    text:
                                    AppLocalizations.of(context)!.owner,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "signed"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!.signed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "owner that add by"),
                              DataColumn(
                                  label: CustomText(
                                    text:
                                    AppLocalizations.of(context)!.actions,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip:
                                  "show buttons for functionality members"),
                            ],
                            rows: provider!.disclosuresData!.disclosures!
                                .map((DisclosureModel disclosure) =>
                                DataRow(cells: [
                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureName!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureDate!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureFile!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureType!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text: disclosure?.user?.name.toString() ?? 'Loading...',
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text: 'status not yet',
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  DataCell(
                                    PopupMenuButton<int>(
                                        padding:
                                        EdgeInsets.only(bottom: 5.0),
                                        icon: CustomIcon(
                                          icon: Icons.settings,
                                          size: 30.0,
                                        ),
                                        onSelected: (value) => 0,
                                        itemBuilder: (context) => [
                                          PopupMenuItem<int>(
                                              value: 0,
                                              child:
                                              CustomElevatedButton(
                                                  verticalPadding:
                                                  0.0,
                                                  text: AppLocalizations
                                                      .of(
                                                      context)!
                                                      .view,
                                                  icon: Icons
                                                      .remove_red_eye_outlined,
                                                  textColor:
                                                  Colors
                                                      .white,
                                                  buttonBackgroundColor:
                                                  Colors.red,
                                                  horizontalPadding:
                                                  10.0,
                                                  callFunction:
                                                      () async {
                                                    print('View done');
                                                    final pdfFile = await PdfDisclosureApi.generate(disclosure,context);
                                                    print(pdfFile);
                                                    PDFApi.openFile(pdfFile);
                                                  })),
                                          PopupMenuItem<int>(
                                              value: 1,
                                              child: CustomElevatedButton(
                                                  verticalPadding:
                                                  0.0,
                                                  text:
                                                  AppLocalizations.of(
                                                      context)!
                                                      .export,
                                                  icon: Icons
                                                      .import_export_outlined,
                                                  textColor:
                                                  Colors.white,
                                                  buttonBackgroundColor:
                                                  Colors.red,
                                                  horizontalPadding:
                                                  10.0,
                                                  callFunction:
                                                      () async {
                                                    await dialogDownloadDisclosure(disclosure);
                                                  })),
                                          PopupMenuItem<int>(
                                              value: 2,
                                              child: CustomElevatedButton(
                                                  verticalPadding:
                                                  0.0,
                                                  text:
                                                  AppLocalizations.of(
                                                      context)!
                                                      .signed,
                                                  icon: Icons
                                                      .checklist_outlined,
                                                  textColor:
                                                  Colors.white,
                                                  buttonBackgroundColor:
                                                  Colors.red,
                                                  horizontalPadding:
                                                  10.0,
                                                  callFunction:() {
                                                    dialogToMakeSignDisclosure(disclosure);
                                                  })),
                                          PopupMenuItem<int>(
                                              value: 4,
                                              child:
                                              CustomElevatedButton(
                                                verticalPadding: 0.0,
                                                text: AppLocalizations
                                                    .of(context)!
                                                    .delete,
                                                icon: Icons
                                                    .restore_from_trash_outlined,
                                                textColor:
                                                Colors.white,
                                                buttonBackgroundColor:
                                                Colors.red,
                                                horizontalPadding:
                                                10.0,
                                                callFunction: () {
                                                  dialogDeleteDisclosure(disclosure);
                                                },
                                              )),
                                        ]),
                                  ),
                                ]))
                                .toList(),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFullTopFilter(String committeeId) {
    return Consumer<DisclosurePageProvider>(
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
                    label: CustomText(text: "Disclosures"),
                    icon: CustomIcon(icon: Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pushReplacementNamed(context,DisclosureListViews.routeName),
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
                      await provider.getListOfDisclosures(provider.yearSelected, committeeId);
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

  Future openDisclosureCreateDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                  title: const Text("Add New Annual Report",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  content: Form(
                    key: insertDisclosureFormGlobalKey,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                          color: Colors.black12,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.45,
                          child: Column(
                            children: [
                              imageProfile(),
                              const SizedBox(height: 10),
                              InkWell(
                                  onTap: () {
                                    pickedFile();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    child: CustomText(text:'Upload Disclosure',color: Colors.red,
                                        fontSize: 15,fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(height: 15),
                              StandTextFormField(
                                color: Colors.redAccent,
                                icon: Icons.people,
                                labelText: "Disclosure Name",
                                valid: (val) {
                                  if (val!.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'Enter a valid Disclosure Name';
                                  }
                                },
                                controllerField: disclosureName,
                              ),
                              const SizedBox(height: 15),
                              DateFormatTextFormField(
                                dateinput: disclosureDate,
                                labelText: "Disclosure Date",
                                onTap: () {
                                  onTapGetDate(disclosureDate);
                                },
                                icon: Icons.calendar_today,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 15),
                              Container(
                                constraints:
                                const BoxConstraints(minHeight: 30.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                    color: Colors.red,
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 2.0,
                                          spreadRadius: 0.4)
                                    ]),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownStringList(
                                      boxDecoration: Colors.white,
                                        hint: CustomText(text:AppLocalizations.of(context)!.type,color: Colors.black),
                                        selectedValue: typeL,
                                        dropdownItems: TypeList,
                                        onChanged: (String? newValue) async {
                                            typeL = newValue!.toString();
                                            setState(() { typeL = newValue; });
                                            print(typeL);
                                          }, color:  Colors.black,)
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                  actions: [
                    Consumer<DisclosurePageProvider>(
                        builder: (context, provider, child) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                provider.loading == true
                                    ? Center(child: CircularProgressIndicator())
                                    : ElevatedButton.icon(
                                  label: CustomText(text:'Add Disclosure', color: Colors.red,
                                        fontSize: 18,fontWeight: FontWeight.bold,
                                  ),
                                  icon: CustomIcon(icon:Icons.add, color: Colors.white),
                                  onPressed: () async {
                                    final SharedPreferences prefs = await SharedPreferences
                                        .getInstance();
                                    user = User.fromJson(
                                        json.decode(prefs.getString("user")!));
                                    setState(() {
                                      _business_id = user.businessId.toString();
                                    });
                                    if (insertDisclosureFormGlobalKey
                                        .currentState!.validate()) {
                                      insertDisclosureFormGlobalKey
                                          .currentState!.save();
                                      if (pickedFiles != null) {
                                        final fileBase64 = base64.encode(
                                            File(_fileName!).readAsBytesSync());
                                        setState(() {
                                          _fileBase64 = fileBase64;
                                        });
                                      }

                                      Map<String, dynamic> data = {
                                        "disclosure_name": disclosureName.text,
                                        "disclosure_date": disclosureDate.text,
                                        "disclosure_type": typeL,
                                        "disclosure_file": _fileNameNew!,
                                        "fileSelf": _fileBase64!,
                                        "business_id": _business_id,
                                        "add_by": user.userId.toString(),
                                      };
                                      await providerDisclosure.insertDisclosure(data);
                                      if (providerDisclosure.isBack == true) {
                                        disclosureName.text = '';
                                        disclosureDate.text = '';
                                        disclosureType.text = '';
                                        pickedFiles = null;
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: CustomText(
                                                text: AppLocalizations.of(
                                                    context)!
                                                    .remove_minute_done),
                                            backgroundColor: Colors.greenAccent,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: CustomText(
                                                text: AppLocalizations.of(
                                                    context)!
                                                    .remove_minute_failed),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]);
                        })
                  ],
                );
              });
        });
  }

  Future dialogToMakeSignDisclosure(DisclosureModel disclosure) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${disclosure.disclosureName!} ${AppLocalizations.of(context)!.to_sign}",
                        color: Colors.green,
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
                                text: AppLocalizations.of(context)!.yes_sure,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                makeSignOnDisclosure(disclosure);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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

  void makeSignOnDisclosure(DisclosureModel disclosure) async {
    Map<String, dynamic> data = {"disclosure_id": disclosure.disclosureId!,"member_id": 7};
    final Future<Map<String, dynamic>> response = providerDisclosure.makeSignedDisclosure(data);
    response.then((response) {
      if (response['status']) {
        providerDisclosure.setIsBack(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_successfully),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      } else {
        providerDisclosure.setIsBack(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_failed),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future dialogDownloadDisclosure(DisclosureModel disclosure) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(text: "${AppLocalizations.of(context)!.yes_sure_download} ${disclosure.disclosureName!} ?",
                        color: Colors.green,
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
                                text: AppLocalizations.of(context)!.yes_download,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.download, color: Colors.white),
                              onPressed: () async {
                                print('no function yet in download');
                                downloadDisclosure(disclosure);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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

  Future<void> downloadDisclosure(DisclosureModel disclosure) async {
    final pdfFile = await PdfDisclosureApi.generate(disclosure, context);
    if (await PDFApi.requestPermission()) {
      await PDFApi.downloadFileToStorage(pdfFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    } else {
      print('permission error--------------');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }


  Future dialogDeleteDisclosure(DisclosureModel disclosure) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(text:"${AppLocalizations.of(context)!.are_you_sure_to_delete} ${disclosure.disclosureName!} ?",
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
                              onPressed: () {
                                removeDisclosure(disclosure);
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

  void removeDisclosure(DisclosureModel disclosure)async {
    await providerDisclosure.removeDisclosure(disclosure);
    if (providerDisclosure.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: AppLocalizations.of(context)!.remove_minute_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void onTapGetDate(TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(pickedDate!);
    print(
        formattedDate); //formatted date output using intl package =>  2021-03-16
    //you can implement different kind of Date Format here according to your requirement

    setState(() {
      passDate.text = formattedDate; //set output date to TextField value.
    });
    }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.brown.shade800,
              radius: 50.0,
              child: pickedFiles?.name == null
                  ? Icon(
                Icons.upload_file,
                size: 24.0,
              )
                  : Text(
                pickedFiles!.name,
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
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

  // void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
  //   MaterialPageRoute(builder: (context) => PDFViewerPageAsyncfusion(file: file,fileName: fileName,)),
  // );


}
