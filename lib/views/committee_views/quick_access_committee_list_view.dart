import 'package:diligov_members/providers/board_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../NetworkHandler.dart';
import '../../colors.dart';

import '../../models/committee_model.dart';
import '../../models/data/years_data.dart';
import '../../models/user.dart';
import '../../providers/committee_provider_page.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/dropdown_string_list.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/stand_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../modules/remuneration_policy/form/set_committee_remuneration_form.dart';

class QuickAccessCommitteeListView extends StatefulWidget {
  const QuickAccessCommitteeListView({Key? key}) : super(key: key);
  static const routeName = '/QuickAccessCommitteeListView';

  @override
  State<QuickAccessCommitteeListView> createState() => _QuickAccessCommitteeListViewState();
}

class _QuickAccessCommitteeListViewState extends State<QuickAccessCommitteeListView> {
  final insertCommitteeFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late String _business_id;

  TextEditingController _search = TextEditingController();
  TextEditingController boardStartDate = TextEditingController();
  TextEditingController endFiscalYear = TextEditingController();
  TextEditingController _committeeName = TextEditingController();
  TextEditingController _boardName = TextEditingController();

  String? _fileBase64 ;
  String? _fileName ;
  FilePickerResult? result;
  String? _fileNameNew;
  PlatformFile? pickedfile;
  File? fileToDisplay;
  bool isLoading = false;
  void pickedFile() async {
    try{
      setState(() {
        isLoading = true;
      });

      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf']
      );
      if(result != null){
        _fileNameNew = result!.files.first.name;
        pickedfile = result!.files.first;
        _fileName = pickedfile!.path!;
        print("file name $_fileNameNew");
        print("file pickedfile with path $_fileName");
        print("file fileToDisplay $fileToDisplay");
      }

      setState(() {
        isLoading = false;
      });
    }catch(e){
      print(e);
    }
  }
  late List _listOfBoardsData = [];
  String? _board="";
  Future getListBoards() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'] ;
      setState((){
        _listOfBoardsData = boardsData['boards'];
        log.d(_listOfBoardsData);
      });

    } else {
      print(json.decode(response.body)['message']);
    }

  }

  // Initial Selected Value
  String dropdownvalue = '51';
  // List of items in our dropdown menu
  var items = ['51','66','70'];

  // Initial Selected Value
  String yearSelected = '2023';
  // List of items in our dropdown menu
  var yeasList = ['2021','2022','2023','2024','2025','2026','2027','2028','2029','2030','2031','2032'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    boardStartDate.text = "";
    endFiscalYear.text = "";
    _committeeName.text = "";
    _boardName.text = "";
    _fileNameNew = "";
    _fileName = "";

    Future.delayed(Duration.zero, (){
      getListBoards();
    });
  }

  Widget buildFullTopFilter() {
    return Consumer<CommitteeProviderPage>(
        builder: (BuildContext context, provider, child){
          return Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colour().buttonBackGroundMainColor,
                    ),
                    child: CustomText(
                        text: 'Committees',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(text: AppLocalizations.of(context)!.select_year,color: Colour().mainWhiteTextColor),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getListOfMeetingsCommitteesByFilter(provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),

                Container(
                  width: 200,
                  padding:const EdgeInsets.symmetric(vertical: 1.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: ElevatedButton.icon(
                    label: CustomText(text: 'New Committee', color: Colors.white,),
                    onPressed: () => openCommitteeCreateDialog(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:  Colour().buttonBackGroundRedColor,
                        padding: EdgeInsets.symmetric(horizontal: 10.0)
                    ),
                  ),
                ),



              ],
            ),
          );
        }
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }
  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  Widget buildCommitteeActions(Committee committee) {
    final provider = Provider.of<CommitteeProviderPage>(context, listen: false);
    return Row(
      children: [

        SizedBox(width: 5),
        ElevatedButton.icon(
          label: CustomText(text: 'Edit'),
          icon: CustomIcon(icon: Icons.checklist_outlined),
          onPressed: () => openEditCommitteeDialog(committee, provider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        SizedBox(width: 5),
        ElevatedButton.icon(
          label: CustomText(text: 'Delete'),
          icon: CustomIcon(icon: Icons.restore_from_trash_outlined),
          onPressed: () => confirmDelete(committee, provider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        SizedBox(width: 5),
        ElevatedButton.icon(
          label: CustomText(text: 'Set Remuneration'),
          icon: CustomIcon(icon: Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetCommitteeRemunerationForm(committee: committee)));
            },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),

      ],
    );
  }





  Widget buildCommitteeTable() {
    return Consumer<CommitteeProviderPage>(
      builder: (context, provider, child) {
        if (provider.committeesData?.committees == null) {

          provider.getListOfMeetingsCommitteesByFilter(provider.yearSelected);
          return buildLoadingSniper();
        }

        return provider.committeesData!.committees!.isEmpty
            ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: DataTable(
              columnSpacing: 100,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colour()
                        .darkHeadingColumnDataTables),
                borderRadius: BorderRadius.circular(20),
              ),
              // showBottomBorder: true,
              headingRowHeight: 60,
              dividerThickness: 0.3,
              headingRowColor:
              MaterialStateColor.resolveWith((states) =>
              Colour().darkHeadingColumnDataTables),
              columns: [
                DataColumn(label: CustomText(text: "Committee Name",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
                DataColumn(label: CustomText(text: "Committee Board",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
                DataColumn(label: CustomText(text: "Actions",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
              ],
              rows: provider.committeesData!.committees!.map((committee) {
                return DataRow(
                  cells: [
                    DataCell(CustomText(text: committee.committeeName ?? '', fontWeight: FontWeight.bold, fontSize: 14.0)),
                    DataCell(CustomText(text: committee.board?.boardName ?? '', fontWeight: FontWeight.bold, fontSize: 14.0)),
                    DataCell(buildCommitteeActions(committee)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color color, Duration duration) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing Snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: CustomText(text: message), backgroundColor: color, duration: duration),
    );
  }

  Future<void> deleteCommittee(Committee committeeId) async {
    final provider = Provider.of<CommitteeProviderPage>(context, listen: false);
    bool isDeleted = await provider.deleteCommittee(committeeId);

    if (isDeleted) {
      _showSnackBar('Committee deleted successfully!', Colors.green, Duration(seconds: 3));
    } else {
      _showSnackBar('Failed to delete committee. Try again!', Colors.red, Duration(seconds: 3));
    }
  }

  void confirmDelete(Committee committeeId, CommitteeProviderPage provide) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title:  CustomText(text: "Confirm Deletion"),
        content:  CustomText(text: "Are you sure you want to delete this committee?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  CustomText(text: "Cancel",color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent user from closing dialog while deleting
                builder: (context) => AlertDialog(
                  title: CustomText(text: "Deleting..."),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 10),
                      CustomText(text: "Please wait while we delete the committee..."),
                    ],
                  ),
                ),
              );

              final provider = Provider.of<CommitteeProviderPage>(context, listen: false);
              bool isDeleted = await provider.deleteCommittee(committeeId);
              await Future.delayed(const Duration(seconds: 5));

              if (isDeleted) {
                _showSnackBar('Committee deleted successfully!', Colors.green, Duration(seconds: 3));
              } else {
                _showSnackBar('Failed to delete committee. Try again!', Colors.red, Duration(seconds: 3));
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: provide.loading ? CircularProgressIndicator() : CustomText(text: "Delete",  color: Colors.white),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        children: [
          buildFullTopFilter(),
          Expanded(child: buildCommitteeTable()),
        ],
      ),
    ),
      ),
    );
  }

  void openEditCommitteeDialog(Committee committee, CommitteeProviderPage provider) {
    TextEditingController nameController = TextEditingController(text: committee.committeeName);

    // Set selectedBoardId to the currently assigned board of the committee
    String? selectedBoardId = committee.board?.boarId?.toString();

    PlatformFile? pickedFile;
    String? pickedFileName;
    String? fileBase64;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 100.0),
            title: CustomText(text: "Edit Committee", fontWeight: FontWeight.bold),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                children: [
                  // Committee Name Input
                  StandTextFormField(
                    controllerField: nameController,
                    labelText: "Committee Name",
                    valid: (val) => val!.isNotEmpty ? null : 'Enter a valid committee name',
                    icon: Icons.people,
                    color: Colors.redAccent,
                  ),

                  SizedBox(height: 15),

                  // Board Selection Dropdown
                  Container(
                    // width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        elevation: 2,
                        isExpanded: true,
                        isDense: true,
                        menuMaxHeight: 300,
                        style: Theme.of(context).textTheme.titleLarge,
                        hint: const Text("Select a Board", style: TextStyle(color: Colors.black)),
                        dropdownColor: Colors.white60,
                        focusColor: Colors.redAccent[300],

                        // Set initial selected value
                        value: selectedBoardId,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),

                        // Populate dropdown items with available boards
                        items: [
                          const DropdownMenuItem(
                            value: "",
                            child: Text("Select a Board", style: TextStyle(color: Colors.black)),
                          ),
                          ..._listOfBoardsData.map((item) {
                            return DropdownMenuItem(
                              value: item['id'].toString(),
                              child: CustomText(text: item['board_name'], color: Colors.black),
                            );
                          }).toList(),
                        ],

                        // On selection change
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBoardId = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // File Upload Section
                  InkWell(
                    onTap: () async {
                      PlatformFile? selectedFile = await pickFile();
                      if (selectedFile != null) {
                        setState(() {
                          pickedFile = selectedFile;
                          pickedFileName = selectedFile.name;
                        });

                        // Convert the file to Base64
                        fileBase64 = await convertFileToBase64(selectedFile);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Text(
                        pickedFileName ?? 'Upload Charter',
                        style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: CustomText(text: "Cancel", color: Colors.grey),
              ),
              ElevatedButton(
                onPressed: () async {
                  final  board =   Provider.of<BoardPageProvider>(context, listen: false);
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  user = User.fromJson(json.decode(prefs.getString("user")!)) ;
                  setState((){
                    isLoading = true;
                    _business_id = user.businessId.toString();
                  });
                  if (nameController.text.isEmpty || board.selectedBoardId! == null || board.selectedBoardId! == "") {
                    _showSnackBar("All fields are required!", Colors.red, Duration(seconds: 3));
                    return;
                  }

                  // Create data object for updating the committee
                  Map<String, dynamic> data = {
                    'committee_id': committee.id.toString(),
                    'committee_name': nameController.text,
                    'board_id': selectedBoardId!,
                    'file': fileBase64, // Send file only if it's changed
                    "business_id": _business_id
                  };

                  bool isUpdated = await provider.updateCommittee(data);

                  if (isUpdated) {
                    _showSnackBar("Committee updated successfully!", Colors.green, Duration(seconds: 3));
                    Navigator.pop(context);
                  } else {
                    _showSnackBar("Failed to update committee!", Colors.red, Duration(seconds: 3));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: CustomText(text: "Save", color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }




  Widget CombinedCollectionBoardCommitteeDataDropDownList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<BoardPageProvider>(
        builder: (context, provider, child) {
          if (provider.boardsData?.boards == null) {
            provider.getListOfBoards(context);
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.boardsData!.boards!.isEmpty
                  ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,

                  // Set the selected value to boardId
                  value: provider.selectedBoardId,

                  // Populate dropdown items with `boardId` as value
                  items: provider.boardsData?.boards?.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.boarId.toString(), // Store boardId
                      child: CustomText(text: item.boardName.toString()),
                    );
                  }).toList(),

                  // On selection change, update provider with the selected boardId
                  onChanged: (selectedItem) {
                    provider.selectCollectionBoard(selectedItem!, context);
                  },

                  // Display selected board name
                  hint: CustomText(
                    text: provider.selectedBoardName ?? 'Select a Board',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (provider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomText(
                    text: provider.dropdownError!,
                    fontSize: 12,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }


  Future  openCommitteeCreateDialog() => showDialog(
      context: context,
      builder:  (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100.0),
                title: const Text("Add New Committee",style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.bold)),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Form(
                    key: insertCommitteeFormGlobalKey,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                          color: Colors.black12,
                          width: MediaQuery.of(context).size.width*0.45,
                          child: Column(
                            children: [
                              imageProfile(),
                              const SizedBox(height:15),
                              InkWell(
                                  onTap: () async{
                                    pickedFile();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right:10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:  BorderRadius.circular(0.0),
                                    ),
                                    child: const Text('Upload Charter',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
                                  )
                              ),
                              const SizedBox(height:15),
                              StandTextFormField(
                                color: Colors.redAccent,
                                icon: Icons.people,
                                labelText: "Committee Name",
                                valid: (val){
                                  if (val!.isNotEmpty ) {
                                    return null;
                                  } else {
                                    return 'Enter a valid committee Name';
                                  }
                                },
                                controllerField: _committeeName,
                              ),
                              Container(
                                constraints: BoxConstraints(minHeight: 30.0),
                                padding: EdgeInsets.all(7),
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    borderRadius:  BorderRadius.circular(10.0),
                                    color: Colors.white38,
                                    boxShadow:  [
                                      BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
                                    ]),
                                child: CombinedCollectionBoardCommitteeDataDropDownList(),
                              ),

                            ],
                          )
                      ),
                    ),
                  ),
                ),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        ElevatedButton.icon(
                          onPressed: () async {
                            final  board =   Provider.of<BoardPageProvider>(context, listen: false);
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            user = User.fromJson(json.decode(prefs.getString("user")!)) ;
                            setState((){
                              isLoading = true;
                              _business_id = user.businessId.toString();
                            });
                            if (insertCommitteeFormGlobalKey.currentState!.validate()) {
                              insertCommitteeFormGlobalKey.currentState!.save();
                              if (pickedfile != null) {
                                final fileBase64 = base64.encode(File(_fileName!).readAsBytesSync());
                                setState(() {
                                  _fileBase64 = fileBase64;
                                });
                              }

                              Map<String, dynamic> data = {
                                "committee_name": _committeeName.text,'charter_committee': _fileNameNew!,'fileSelf': _fileBase64!,
                                "board_id": board.selectedBoardId!,"business_id": _business_id
                              };
                              CommitteeProviderPage providerCommittee =  Provider.of<CommitteeProviderPage>(context, listen: false);
                              Future.delayed(Duration.zero, () {
                                providerCommittee.insertCommittee(data);
                              });

                              if(providerCommittee.isBack == true){
                                Navigator.pop(context);
                                Flushbar(
                                  title: "Create Committee has been Successfully",
                                  message: "Create Committee has been Successfully",
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.greenAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              } else {
                                Flushbar(
                                  title: "Create Committee has been Faild",
                                  message: "Create Committee has been Faild",
                                  duration: Duration(seconds: 6),
                                  backgroundColor: Colors.redAccent,
                                  titleColor: Colors.white,
                                  messageColor: Colors.white,
                                ).show(context);
                              }
                            }
                          },
                          icon: const Icon(Icons.add,size: 30,color: Colors.white,),
                          label: const Text('Add Committee',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',style: TextStyle(color: Colors.red,fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ]
                  ),
                ],
              );
            }
        );
      }
  );

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.brown.shade800,
              radius: 50.0,
              child: pickedfile == null ? Icon(Icons.upload_file ,size: 24.0,) : Text(pickedfile!.name,style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );
  }

  Future<String?> convertFileToBase64(PlatformFile file) async {
    try {
      File fileToConvert = File(file.path!);
      List<int> fileBytes = await fileToConvert.readAsBytes();
      return base64Encode(fileBytes); // Convert file to Base64
    } catch (e) {
      print("Error encoding file: $e");
      return null;
    }
  }



  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict file type to PDF
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first; // Return the selected file
      } else {
        return null; // No file selected
      }
    } catch (e) {
      print("File picking error: $e");
      return null;
    }
  }


  void openPDF(BuildContext context, String file,String fileName) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPageSyncfusionPackage(file: file, fileName: fileName,)),
  );


}
