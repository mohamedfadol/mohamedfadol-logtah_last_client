import 'dart:convert';
import 'dart:math';

import 'package:diligov_members/models/agenda_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:logger/logger.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';



import '../../../colors.dart';
import '../../../models/minutes_model.dart';
import '../../../providers/agenda_page_provider.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/loading_sniper.dart';
import '../../../widgets/minutes_form/arabic_generateform_widget.dart';
import '../../../widgets/minutes_form/english_generateform_widget.dart';
import '../../../widgets/reusable_quillEditor_widget.dart';
import 'minutes_meeting_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class EditMinutes extends StatefulWidget {
  final Minute minute;
  const EditMinutes({Key? key, required this.minute}) : super(key: key);
  @override
  State<EditMinutes> createState() => _EditMinutesState();
}

class _EditMinutesState extends State<EditMinutes>  with AutomaticKeepAliveClientMixin , SingleTickerProviderStateMixin{
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  final log = Logger();
  final _formKey = GlobalKey<FormState>();
  late AgendaPageProvider provider;
  int tabIndex = 0;

  bool dataLoaded = false;

  // @override
  // void initState() {
  //   super.initState();
  //   defaultTabBarViewController = TabController(length: 4, vsync: this);
  //   try {
  //     // provider = Provider.of<AgendaPageProvider>(context, listen: false);
  //     provider = AgendaPageProvider();
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //
  //       provider.getListAgendas(widget.minute.meeting!.meetingId.toString()).then((_) {
  //         if (mounted) {
  //           if (provider.listAgenda != null) {
  //             setState(() {
  //               // Initialize controllers with data from provider
  //               for (var agenda in provider.listAgenda!.agendas!) {
  //
  //                 var description = agenda.details?.description ?? '';
  //                 var arabicDescription = agenda.details?.arabicDescription ?? '';
  //                 var reservations = agenda.details?.reservations ?? '';
  //                 var arabicReservations = agenda.details?.arabicReservations ?? '';
  //
  //                 // // If it's plain text, create a new Delta and insert the text
  //                 Delta deltaDescription;
  //                 try {
  //                   deltaDescription = Delta.fromJson(jsonDecode(description));
  //                 } catch (e) {
  //                   // If it fails to decode as JSON, treat it as plain text
  //                   deltaDescription = Delta()..insert(description + '\n');
  //                 }
  //                 _controllerDescription = QuillController(document: Document.fromDelta(deltaDescription),selection: const TextSelection.collapsed(offset: 0));
  //                 provider.descriptionControllerss.add(_controllerDescription);
  //                 //
  //
  //                 Delta deltaArabicDescription;
  //                 try {
  //                   deltaArabicDescription = Delta.fromJson(jsonDecode(arabicDescription));
  //                 } catch (e) {
  //                   // If it fails to decode as JSON, treat it as plain text
  //                   deltaArabicDescription = Delta()..insert(arabicDescription + '\n');
  //                 }
  //                 _controllerArabicDescription = QuillController(document: Document.fromDelta(deltaArabicDescription),selection: const TextSelection.collapsed(offset: 0));
  //                 provider.arabicDescriptionControllerss.add(_controllerArabicDescription);
  //                 //
  //                 //
  //                 Delta deltaReservations;
  //                 try {
  //                   deltaReservations = Delta.fromJson(jsonDecode(reservations));
  //                 } catch (e) {
  //                   // If it fails to decode as JSON, treat it as plain text
  //                   deltaReservations = Delta()..insert(reservations + '\n');
  //                 }
  //                 _controllerReservations= QuillController(document: Document.fromDelta(deltaReservations),selection: const TextSelection.collapsed(offset: 0));
  //                 provider.reservationsControllerss.add(_controllerReservations);
  //
  //
  //                 Delta deltaArabicReservations;
  //                 try {
  //                   deltaArabicReservations = Delta.fromJson(jsonDecode(arabicReservations));
  //                 } catch (e) {
  //                   // If it fails to decode as JSON, treat it as plain text
  //                   deltaArabicReservations = Delta()..insert(arabicReservations + '\n');
  //                 }
  //                 _controllerArabicReservation = QuillController(document: Document.fromDelta(deltaArabicReservations),selection: const TextSelection.collapsed(offset: 0));
  //                 provider.arabicReservationsControllerss.add(_controllerArabicReservation);
  //
  //                 // provider.descriptionControllerss.add(_initQuillController(description));
  //                 // provider.arabicDescriptionControllerss.add(_initQuillController(arabicDescription));
  //                 // provider.reservationsControllerss.add(_initQuillController(reservations));
  //                 // provider.arabicReservationsControllerss.add(_initQuillController(arabicReservations));
  //
  //
  //                 // provider.descriptionControllers.add(TextEditingController(text: agenda.details?.description ?? ''));
  //                 // provider.arabicDescriptionControllers.add(TextEditingController(text: agenda.details?.arabicDescription ?? ''));
  //                 // provider.reservationsControllers.add(TextEditingController(text: agenda.details?.reservations ?? ''));
  //                 // provider.arabicReservationsControllers.add(TextEditingController(text: agenda.details?.arabicReservations ?? ''));
  //                 provider.setAgenda(agenda);
  //               }
  //               dataLoaded = true;
  //
  //               // Add listeners to the text fields (for English and Arabic fields) to update progress when typing
  //               for (int i = 0; i < provider.listAgenda!.agendas!.length; i++) {
  //                 // If _enableEnglish or _enableArabicAndEnglish is true, add listener for English fields
  //                 if (provider.enableEnglish || provider.enableArabicAndEnglish) {
  //                   provider.descriptionControllers[i].addListener(() {
  //                     _updateProgress(i);  // Update progress when typing in the "Description" (English) field
  //                   });
  //                   provider.reservationsControllers[i].addListener(() {
  //                     _updateProgress(i);  // Update progress when typing in the "Reservations" (English) field
  //                   });
  //                 }
  //
  //                 // If _enableArabic or _enableArabicAndEnglish is true, add listener for Arabic fields
  //                 if (provider.enableArabic || provider.enableArabicAndEnglish) {
  //                   provider.arabicDescriptionControllers[i].addListener(() {
  //                     _updateProgress(i);  // Update progress when typing in the "Description" (Arabic) field
  //                   });
  //                   provider.arabicReservationsControllers[i].addListener(() {
  //                     _updateProgress(i);  // Update progress when typing in the "Reservations" (Arabic) field
  //                   });
  //                 }
  //               }
  //
  //             });
  //           }
  //         }
  //       }).catchError((e) {
  //         print("Error fetching data: $e");
  //       });
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       print("Error fetching data: $e");
  //     }
  //   }
  //
  //   // Add listener to the scroll controller to track scrolling events
  //   _scrollController.addListener(() {
  //     final provider = Provider.of<AgendaPageProvider>(context, listen: false);
  //
  //     // Add padding based on the scroll position
  //     if (_scrollController.position.pixels > 50) {
  //       provider.updateBottomPadding(10.0); // Add 10 padding when scrolled
  //     } else {
  //       provider.updateBottomPadding(0.0); // Remove padding when at the start
  //     }
  //   });
  //
  // }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    try {
      provider = AgendaPageProvider();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.getListAgendas(widget.minute.meeting!.meetingId.toString()).then((_) {
          if (mounted) {
            if (provider.listAgenda != null) {
              setState(() {
                // Initialize controllers for each agenda
                for (var agenda in provider.listAgenda!.agendas!) {
                  // For description
                  QuillController descriptionController = _initQuillController(agenda.details?.description ?? '');
                  provider.descriptionControllerss.add(descriptionController);

                  // For reservations
                  QuillController reservationsController = _initQuillController(agenda.details?.reservations ?? '');
                  provider.reservationsControllerss.add(reservationsController);

                  // For Arabic description
                  QuillController arabicDescriptionController = _initQuillController(agenda.details?.arabicDescription ?? '');
                  provider.arabicDescriptionControllerss.add(arabicDescriptionController);

                  // For Arabic reservations
                  QuillController arabicReservationsController = _initQuillController(agenda.details?.arabicReservations ?? '');
                  provider.arabicReservationsControllerss.add(arabicReservationsController);
                }

                dataLoaded = true;  // Mark that data has been loaded
              });
            }
          }
        }).catchError((e) {
          print("Error fetching data: $e");
        });
      });
    } catch (e) {
      print("Error initializing state: $e");
    }
  }

  QuillController _initQuillController(String content) {
    Delta delta;
    try {
      delta = Delta.fromJson(jsonDecode(content));
    } catch (e) {
      // Treat it as plain text if it cannot be parsed as JSON
      delta = Delta()..insert(content + '\n');
    }

    // Initialize the controller with the document
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }


  void _onFieldChanged(int agendaId) {
    final provider = Provider.of<AgendaPageProvider>(context, listen: false);
    provider.calculateProgressForAgenda(agendaId); // Update the progress in the provider
  }



// Helper function to check if a QuillController is not empty
  bool _isQuillControllerNotEmpty(QuillController controller) {
    return controller.document.toPlainText().trim().isNotEmpty;
  }


  @override
  void dispose() {
    provider.descriptionControllers.forEach((controller) => controller.dispose());
    provider.reservationsControllers.forEach((controller) => controller.dispose());
    provider.arabicDescriptionControllers.forEach((controller) => controller.dispose());
    provider.arabicReservationsControllers.forEach((controller) => controller.dispose());
    provider.resolutions
        .forEach((resolution) => resolution['controller'].dispose());
    provider.directions
        .forEach((direction) => direction['controller'].dispose());
    provider.arabicResolutions
        .forEach((resolution) => resolution['controller'].dispose());
    provider.arabicDirections
        .forEach((direction) => direction['controller'].dispose());


    // Dispose all text editing controllers if they haven't already been disposed
    _disposeControllers(provider.descriptionControllers);
    _disposeControllers(provider.reservationsControllers);
    _disposeControllers(provider.arabicDescriptionControllers);
    _disposeControllers(provider.arabicReservationsControllers);

    provider.dispose();  // Dispose provider if necessary
    print("Disposing Widget");
    // provider.disposeControllers();
    // for (var controller in _controllerDescription) {
    // }
    super.dispose();
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (!controller.hasListeners) {
        controller.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<AgendaPageProvider>(
      create: (_) => provider,
      // value: provider,
      child: Scaffold(

        appBar: PreferredSize(
          preferredSize: Size.fromHeight(5.0),
          child: AppBar(
            backgroundColor: Colour().buttonBackGroundRedColor,

            // actions: buildEditingActions(context),
          ),
        ),
        body: provider.loading
            ? Center(child: CircularProgressIndicator())
            :  Consumer<AgendaPageProvider>(
          builder: (context, provider, child) {
            if (provider.listAgenda?.agendas == null) {
              return buildLoadingSpinner();
            }

            return provider.listAgenda?.agendas?.isEmpty ?? true
                ? buildEmptyMessage(AppLocalizations.of(context)!
                .there_no_agendas_add_selected_meeting_please_fill_it)
                : Form(
              key: _formKey,
              child: Stepper(
                elevation: 2.0,
                type: StepperType.horizontal,
                currentStep: provider.currentIndex,
                onStepTapped: (index) {
                  provider.setStepIndex(index);
                },
                onStepContinue: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();  // Save the form state
                    // if (provider.currentIndex < provider.listAgenda!.agendas!.length - 1) {
                    //   provider.onStepContinue();
                    // } else {
                      submitForm(context);
                    // }
                  }
                },
                onStepCancel: () {
                  if (provider.currentIndex > 0) {
                    provider.setStepIndex(provider.currentIndex - 1);
                  }
                },
                steps: <Step>[
                  Step(
                    state: provider.currentIndex > 0
                        ? StepState.complete
                        : StepState.indexed,
                    isActive: provider.currentIndex >= 0,
                    title: CustomText(text: 'Minutes Meeting'),
                    content: SizedBox(
                      height: 550,
                      child: buildAgendaDetailsStep(provider),
                    ),
                  ),
                  Step(
                    state: provider.currentIndex > 1
                        ? StepState.complete
                        : StepState.indexed,
                    isActive: provider.currentIndex >= 1,
                    title: CustomText(text: 'Add Guest Attendance from Details'),
                    content: SizedBox(
                        height: 550,
                        child: buildAttendanceFromAbroadStep(provider)
                    ),
                  ),
                ],
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  final isLastStep = provider.currentIndex > 0;
                  return Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MinutesMeetingList(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIcon(icon: Icons.arrow_back_rounded),
                            SizedBox(width: 10.0,),
                            CustomText(
                              text: "Minutes home",
                              // color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: CustomText(text: isLastStep ? 'Save' : 'Next'),
                      ),
                      if (provider.currentIndex > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: CustomText(text: 'Back'),
                        ),


                      Spacer(),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            left: 8.0,
                            // bottom: 8.0, // Dynamic bottom padding
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(width: 0.1),
                                left: BorderSide(width: 0.1),
                                bottom: BorderSide(width: 0.1)
                            ),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey,
                            //     offset: Offset(0.0, 0.0),
                            //     blurRadius: 9.0,
                            //   ),
                            // ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true, // Always show the scrollbar
                            thickness: 6.0, // Thickness of the scrollbar
                            radius: const Radius.circular(10.0), // Rounded corners
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController, // Attach the scroll controller
                              child: Consumer<AgendaPageProvider>(
                                builder: (context, provider, child){
                                  return Row(
                                    children: List.generate(provider.listAgenda!.agendas!.length, (index) {
                                      final agenda = provider.listAgenda!.agendas![index];
                                      int filledFields = provider.getFilledFieldsCount(agenda.agendaId!);
                                      int totalFields = provider.getTotalFieldsCount();
                                      double progress = provider.getAgendaProgress(agenda.agendaId!);
                                      // Ensure the percentCompleted value is between 0.0 and 1.0
                                      double percentCompleted = min(filledFields / totalFields, 1.0);

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 10.0, // Dynamic bottom padding
                                        ),
                                        child: CircularPercentIndicator(
                                          radius: 20.0,
                                          lineWidth: 5.0,
                                          percent: progress,
                                          center: Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',  // Show the percentage
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                          ),
                                          progressColor: progress == 1.0 ? Colors.green : Colors.orange,
                                          backgroundColor: Colors.grey[300]!,
                                          circularStrokeCap: CircularStrokeCap.round,
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void submitForm(BuildContext context) async {
    final provider = Provider.of<AgendaPageProvider>(context, listen: false);

    if (provider.listAgenda == null || provider.listAgenda!.agendas == null) {
      // Log the issue and prevent form submission
      print("Agenda list is null, cannot submit form.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot submit form, agendas not loaded."),
        ),
      );
      return;
    }
    // provider.setLoading(true);




// Collect data for each agenda
    List<Map<String, dynamic>> agendaDataList = [];

    for (var agenda in provider.listAgenda!.agendas!) {
      // Save the details from the controllers back into the agenda
      provider.saveDetails(agenda);

      // Collect data for the current agenda
      Map<String, dynamic> agendaData = {
        'details': agenda.details?.detailDetails?.map((detail) {
          return {
            'detailId': detail.detailId,
            'agenda_detail_id': detail.agendaDetailId,
            'serialNumberResolutionEn': detail.serialNumberResolutionEn,
            'textResolutionEn': detail.textResolutionEn,
            'serialNumberDirectionEn': detail.serialNumberDirectionEn,
            'textDirectionEn': detail.textDirectionEn,
            'serialNumberResolutionAr': detail.serialNumberResolutionAr,
            'textResolutionAr': detail.textResolutionAr,
            'serialNumberDirectionAr': detail.serialNumberDirectionAr,
            'textDirectionAr': detail.textDirectionAr,
          };
        }).toList(),
      };
      // Add the collected data to the list
      agendaDataList.add(agendaData);
    }

    // Collect data from controllers
    List<Map<String, dynamic>> updatedDetails = [];

  // Loop through each agenda and retrieve text from QuillControllers
    for (int i = 0; i < provider.listAgenda!.agendas!.length; i++) {
      if (provider.descriptionControllerss.length > i &&
          provider.reservationsControllerss.length > i &&
          provider.arabicDescriptionControllerss.length > i &&
          provider.arabicReservationsControllerss.length > i) {

        // Now safe to access the controllers
        updatedDetails.add({
          'agendaId': provider.listAgenda!.agendas![i].agendaId,
          'missions': provider.descriptionControllerss[i].document.toPlainText().trim(),
          'reservations': provider.reservationsControllerss[i].document.toPlainText().trim(),
          'arabicMissions': provider.arabicDescriptionControllerss[i].document.toPlainText().trim(),
          'arabicReservations': provider.arabicReservationsControllerss[i].document.toPlainText().trim(),
          'listOfAgendas': agendaDataList,
        });
      } else {
        print("Error: Missing controllers for agenda at index $i");
      }
    }



    List<Map<String, String>> updatedAttendance = [];
    for (int i = 0; i < provider.attendedNameControllers.length; i++) {
      updatedAttendance.add({
        'name': provider.attendedNameControllers[i].text,
        'position': provider.positionControllers[i].text,
        'name_ar': provider.arabicAttendedNameControllers[i].text,
        'position_ar': provider.arabicPositionControllers[i].text,
      });
    }

    // Prepare data for submission
    final data = {
      'minute_id': widget.minute.minuteId,
      'agendas': updatedDetails,
      'attendance': updatedAttendance,
      "meeting_id": widget.minute.meeting!.meetingId,
    };
  log.i(data);
    // // Update provider with collected data and submit to backend
    await provider.submitUpdateMinuteAgendaDetails(data);
    provider.setLoading(false);
    Navigator.of(context).pushReplacementNamed(MinutesMeetingList.routeName);
  }

  Widget buildLanguageToggle(BuildContext context) {
    final enableArabic = context.watch<AgendaPageProvider>().enableArabic;
    final enableEnglish = context.watch<AgendaPageProvider>().enableEnglish;
    final enableArabicAndEnglish = context.watch<AgendaPageProvider>().enableArabicAndEnglish;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableEnglish == true
                ? Colour().buttonBackGroundMainColor
                : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<AgendaPageProvider>().toggleEnableEnglish();
          },
          child: CustomText(
            text: "English Only",
            color: Colors.white,
          ),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabicAndEnglish == true
                ? Colour().buttonBackGroundMainColor
                : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context
                .read<AgendaPageProvider>()
                .toggleEnableArabicAndEnglish();
          },
          child: CustomText(
            text: "Dual",
            color: Colors.white,
          ),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabic == true
                ? Colour().buttonBackGroundMainColor
                : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<AgendaPageProvider>().toggleEnableArabic();
          },
          child: CustomText(
            text: "Arabic Only",
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildAgendaDetailsStep(AgendaPageProvider provider) {
    final enableArabic = context.watch<AgendaPageProvider>().enableArabic;
    final enableEnglish = context.watch<AgendaPageProvider>().enableEnglish;
    final enableArabicAndEnglish = context.watch<AgendaPageProvider>().enableArabicAndEnglish;

    // Check if listAgenda or agendas is null
    if (provider.listAgenda?.agendas == null || provider.listAgenda!.agendas!.isEmpty) {
      // Return a message or an empty widget when the list is null or empty
      return Center(
        child: Text(
          'No agendas available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: buildLanguageToggle(context),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.listAgenda!.agendas!.length,
              itemBuilder: (BuildContext context, int agendaIndex) {
                final agenda = provider.listAgenda!.agendas![agendaIndex];

                // Access the controllers from the provider
                final QuillController descriptionsController = provider.descriptionControllerss[agendaIndex];
                final QuillController reservationsController = provider.reservationsControllerss[agendaIndex];
                final QuillController arabicDescriptionController = provider.arabicDescriptionControllerss[agendaIndex];
                final QuillController arabicReservationsController = provider.arabicReservationsControllerss[agendaIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (enableEnglish)
                      generateEnglishSide(
                        agenda: agenda,
                        descriptionsController: descriptionsController,
                        reservationsController: reservationsController,
                        provider: provider,
                        tabController: _tabController
                      ),
                    if (enableArabicAndEnglish)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: generateEnglishSide(
                              agenda: agenda,
                              descriptionsController: descriptionsController,
                              reservationsController: reservationsController,
                              provider: provider,
                              tabController: _tabController
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: generateArabicSide(
                                agenda: agenda,
                                arabicDescriptionControllers: arabicDescriptionController,
                                arabicReservationsController: arabicReservationsController,
                                provider: provider,
                                  tabController: _tabController
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (enableArabic)
                      generateArabicSide(
                        agenda: agenda,
                        arabicDescriptionControllers: arabicDescriptionController,
                        arabicReservationsController: arabicReservationsController,
                        provider: provider,
                          tabController: _tabController
                      ),
                    SizedBox(height: 40),
                    Divider(
                      color: Colour().buttonBackGroundRedColor,
                      height: 0.2,
                      thickness: 3,
                      endIndent: 5,
                      indent: 5,
                    ),
                    SizedBox(height: 40),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAttendanceFromAbroadStep(AgendaPageProvider provider) {
    final enableArabic = context.watch<AgendaPageProvider>().enableArabic;
    final enableEnglish = context.watch<AgendaPageProvider>().enableEnglish;
    final enableArabicAndEnglish = context.watch<AgendaPageProvider>().enableArabicAndEnglish;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          buildAddButton(provider),
          const SizedBox(height: 10),
          for (int i = 0; i < provider.attendedNameControllers.length; i++)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                children: [
                  if (enableEnglish)
                    Column(
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.attended_name_ar,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          // color: Colors.black,
                        ),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: provider.attendedNameControllers[i],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.attended_name,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter attended name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 5.0),
                        CustomText(
                          text: AppLocalizations.of(context)!.position,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          // color: Colors.black,
                        ),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: provider.positionControllers[i],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.position,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter position name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        buildRemoveButton(provider, i),
                      ],
                    ),
                  if (enableArabicAndEnglish)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 200,
                            child: Column(
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.attended_name,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    // color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Expanded(child: buildCustomTextFormField(
                                  controller: provider.attendedNameControllers[i],
                                  hint: AppLocalizations.of(context)!.attended_name,
                                  validatorMessage: 'enter attended name',
                                ))
                                ,

                                const SizedBox(height: 5.0),
                                Expanded(child: CustomText(
                                  text: AppLocalizations.of(context)!.position,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  // color: Colors.black,
                                ),),
                                const SizedBox(height: 5.0),

                                Expanded(child: buildCustomTextFormField(
                                  controller: provider.positionControllers[i],
                                  hint: AppLocalizations.of(context)!.position,
                                  validatorMessage: 'enter attended position',
                                ),)

                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .attended_name_ar,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    // color: Colors.black,
                                  ),
                                )),
                                const SizedBox(height: 5.0),
                                Expanded(child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: buildCustomTextFormField(
                                    controller: provider.arabicAttendedNameControllers[i],
                                    hint: AppLocalizations.of(context)!.attended_name_ar,
                                    validatorMessage: 'enter attended attended name arabic',
                                  ),
                                )),
                                const SizedBox(height: 5.0),
                                Expanded(child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.position_ar,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    // color: Colors.black,
                                  ),
                                )),
                                const SizedBox(height: 5.0),
                                Expanded(child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: buildCustomTextFormField(
                                      controller: provider.arabicPositionControllers[i],
                                      hint: AppLocalizations.of(context)!.position_ar,
                                      validatorMessage: 'enter attended attended position arabic',
                                    )
                                )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        buildRemoveButton(provider, i),
                      ],
                    ),
                  if (enableArabic)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: CustomText(
                            text: AppLocalizations.of(context)!.attended_name_ar,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            // color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            controller: provider.arabicAttendedNameControllers[i],
                            decoration: InputDecoration(
                              hintText:
                              AppLocalizations.of(context)!.attended_name_ar,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter attended name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: CustomText(
                            text: AppLocalizations.of(context)!.position_ar,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            // color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            controller: provider.arabicPositionControllers[i],
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.position_ar,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter position name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildRemoveButton(provider, i),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // List<Widget> buildEditingActions(BuildContext context) => [
  //   TextButton(
  //     style: ButtonStyle(
  //         backgroundColor: MaterialStateProperty.all(Colour().buttonBackGroundRedColor)),
  //     onPressed: provider.listAgenda != null && provider.listAgenda!.agendas != null
  // ? () => submitForm(context)
  //     : null,
  //     child: CustomText(text:
  //     AppLocalizations.of(context)!.save,
  //       color: Colors.white,
  //       fontWeight: FontWeight.bold ,
  //     ),
  //   ),
  // ];

  Widget buildLoadingSpinner() => Center(child: LoadingSniper());

  Widget buildEmptyMessage(String message) =>
      Center(child: CustomMessage(text: message));

  Widget buildAddButton(AgendaPageProvider provider) => TextButton(
    style:
    ButtonStyle(backgroundColor: MaterialStateProperty.all(Colour().buttonBackGroundRedColor)),
    onPressed: provider.addField,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIcon(icon: Icons.add, color: Colors.white,),
        CustomText(text: AppLocalizations.of(context)!.add_details, color: Colors.white, fontWeight: FontWeight.bold),
      ],
    ),
  );

  Widget buildRemoveButton(AgendaPageProvider provider, int index) =>
      TextButton(
        style:
        ButtonStyle(backgroundColor: MaterialStateProperty.all(Colour().buttonBackGroundRedColor)),
        onPressed: () => provider.removeField(index),
        child: CustomIcon(icon: Icons.delete, color: Colors.white,),
      );
}

class generateArabicSide extends StatelessWidget {
  const generateArabicSide({
    super.key,
    required this.agenda,
    required this.arabicDescriptionControllers,
    required this.arabicReservationsController,
    required this.provider,
    required this.tabController

  });

  final Agenda agenda;
  final QuillController arabicDescriptionControllers;
  final QuillController arabicReservationsController;
  final AgendaPageProvider provider;
  final TabController tabController;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: '${agenda.agendaTitleAr}' ?? '',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              // color: Colors.black,
            ),
            CustomText(
              text: 'وصف النقاش',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              // color: Colors.black,
            ),
            const SizedBox(height: 5.0),
            ReusableQuillEditorWidget(
              controller: arabicDescriptionControllers,
              height: 300,
              toolbarAxis: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              backgroundColor: Colors.grey[50],
              borderColor: Colour().buttonBackGroundRedColor,
              showListNumbers: true,
              showBoldButton: true,
              showListBullets: true,
            ),

            const SizedBox(height: 10.0),
            Container(
                padding: const EdgeInsets.only(top: 30.0),
                // color: Colors.grey,
                child: ArabicGenerateFormWidget(provider: provider, agenda: agenda,  tabController: tabController,)
            ),

            const SizedBox(height: 10.0),
            CustomText(
              text: 'التحفظات',
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              // color: Colors.black,
            ),
            const SizedBox(height: 5.0),
            ReusableQuillEditorWidget(
              controller: arabicReservationsController,
              height: 300,
              toolbarAxis: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              backgroundColor: Colors.grey[50],
              borderColor: Colour().buttonBackGroundRedColor,
              showListNumbers: true,
              showBoldButton: true,
              showListBullets: true,
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class generateEnglishSide extends StatelessWidget {
  const generateEnglishSide({
    super.key,
    required this.agenda,
    required this.descriptionsController,
    required this.reservationsController,
    required this.provider,
    required this.tabController
  });

  final Agenda agenda;
  final QuillController descriptionsController;
  final QuillController reservationsController;
  final AgendaPageProvider provider;
  final TabController tabController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: '${agenda.agendaTitle}' ?? '',
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          // color: Colors.black,
        ),
        const SizedBox(height: 5.0),
        CustomText(
          text: 'Description',
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          // color: Colors.black,
        ),
        const SizedBox(height: 5.0),

        ReusableQuillEditorWidget(
          controller: descriptionsController,
          height: 300,
          toolbarAxis: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          backgroundColor: Colors.grey[50],
          borderColor: Colour().buttonBackGroundRedColor,
          showListNumbers: true,
          showBoldButton: true,
          showListBullets: true,
        ),


        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.only(top: 30),
            child: EnglishGenerateFormWidget(provider: provider, agenda: agenda, tabController: tabController,)
        ),
        const SizedBox(height: 10.0),
        CustomText(
          text: 'Reservations',
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          // color: Colors.black,
        ),
        const SizedBox(height: 5.0),

        ReusableQuillEditorWidget(
          controller: reservationsController,
          height: 300,
          toolbarAxis: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          backgroundColor: Colors.grey[50],
          borderColor: Colour().buttonBackGroundRedColor,
          showListNumbers: true,
          showBoldButton: true,
          showListBullets: true,
        ),

        const SizedBox(height: 10.0),
      ],
    );
  }
}


Widget buildCustomTextFormField({
  required TextEditingController controller,
  required String hint,
  required String validatorMessage,
  IconData? icon,
}) {
  return TextFormField(
    maxLines: null,
    expands: true,
    controller: controller,
    // validator: (val) => val != null && val.isEmpty ? validatorMessage : null,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return validatorMessage; // Validation message
      }
      return null;
    },
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      prefixIcon: icon != null ? CustomIcon(icon: icon) : null,
    ),
    onTapOutside: (event){
      // FocusScope.of(context).unfocus();
    },
  );
}

