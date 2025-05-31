import 'dart:math';

import 'package:diligov_members/colors.dart';
import 'package:diligov_members/models/agenda_model.dart';
import 'package:diligov_members/views/modules/minutes_meeting_views/minutes_meeting_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logger/logger.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../models/detail_details_model.dart';
import '../../../providers/agenda_page_provider.dart';
import '../../../providers/minutes_provider_page.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class AgendaDetailsWithMinutes extends StatefulWidget {
  final String meetingId;

  AgendaDetailsWithMinutes({Key? key, required this.meetingId})
      : super(key: key);

  @override
  _AgendaDetailsWithMinutesState createState() =>
      _AgendaDetailsWithMinutesState();
}

class _AgendaDetailsWithMinutesState extends State<AgendaDetailsWithMinutes> {
  QuillController _controller = QuillController.basic();
  final log = Logger();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late AgendaPageProvider provider;


  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    try {
      provider = Provider.of<AgendaPageProvider>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.getListAgendas(widget.meetingId).then((_) {
          if (provider.listAgenda != null) {
            setState(() {
              // Initialize controllers with data from provider
              for (var agenda in provider.listAgenda!.agendas!) {
                provider.descriptionControllers.add(TextEditingController(text: agenda.details?.description ?? ''));
                provider.reservationsControllers.add(TextEditingController(text: agenda.details?.reservations ?? ''));
                provider.arabicDescriptionControllers.add(TextEditingController(text: agenda.details?.arabicDescription ?? ''));
                provider.arabicReservationsControllers.add(TextEditingController(text: agenda.details?.arabicReservations ?? ''));

              }
              // Add listeners to the text fields (for English and Arabic fields) to update progress when typing
              for (int i = 0; i < provider.listAgenda!.agendas!.length; i++) {
                // If _enableEnglish or _enableArabicAndEnglish is true, add listener for English fields
                if (provider.enableEnglish || provider.enableArabicAndEnglish) {
                  provider.descriptionControllers[i].addListener(() {
                    _updateProgress(i);  // Update progress when typing in the "Description" (English) field
                  });
                  provider.reservationsControllers[i].addListener(() {
                    _updateProgress(i);  // Update progress when typing in the "Reservations" (English) field
                  });
                }

                // If _enableArabic or _enableArabicAndEnglish is true, add listener for Arabic fields
                if (provider.enableArabic || provider.enableArabicAndEnglish) {
                  provider.arabicDescriptionControllers[i].addListener(() {
                    _updateProgress(i);  // Update progress when typing in the "Description" (Arabic) field
                  });
                  provider.arabicReservationsControllers[i].addListener(() {
                    _updateProgress(i);  // Update progress when typing in the "Reservations" (Arabic) field
                  });
                }
              }
              dataLoaded = true;
            });
          }
        }).catchError((e) {
          print("Error fetching data: $e");
        });
      });
    } catch (e) {
      if (mounted) {
        print("Error fetching data: $e");
      }
    }

    // Add listener to the scroll controller to track scrolling events
    _scrollController.addListener(() {
      final provider = Provider.of<AgendaPageProvider>(context, listen: false);

      // Add padding based on the scroll position
      if (_scrollController.position.pixels > 50) {
        provider.updateBottomPadding(10.0); // Add 10 padding when scrolled
      } else {
        provider.updateBottomPadding(0.0); // Remove padding when at the start
      }
    });
  }

  void _updateProgress(int index) {
    final provider = Provider.of<AgendaPageProvider>(context, listen: false);

    final currentAgenda = provider.listAgenda!.agendas![index];

    // Get the description and reservations for both languages
    String? descriptionEn = provider.enableEnglish || provider.enableArabicAndEnglish ? provider.descriptionControllers[index].text : null;
    String? descriptionAr = provider.enableArabic || provider.enableArabicAndEnglish ? provider.arabicDescriptionControllers[index].text : null;
    String? reservationsEn = provider.enableEnglish || provider.enableArabicAndEnglish ? provider.reservationsControllers[index].text : null;
    String? reservationsAr = provider.enableArabic || provider.enableArabicAndEnglish ? provider.arabicReservationsControllers[index].text : null;

    // Update the progress based on filled fields
    provider.updateAgendaProgress(
        currentAgenda.agendaId!,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        reservationsEn: reservationsEn,
        reservationsAr: reservationsAr
    );
  }

  @override
  void dispose() {
    // Dispose all text editing controllers
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

    _disposeControllers(provider.descriptionControllers);
    _disposeControllers(provider.reservationsControllers);
    _disposeControllers(provider.arabicDescriptionControllers);
    _disposeControllers(provider.arabicReservationsControllers);

    provider.dispose();  // Dispose provider if necessary
    print("Disposing Widget");
    // provider.disposeControllers();

    _controller.dispose();
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
    return ChangeNotifierProvider<AgendaPageProvider>(
      create: (_) => provider,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colour().buttonBackGroundRedColor,
          leading: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MinutesMeetingList(),
                ),
              );
            },
            child: CustomText(
              text: AppLocalizations.of(context)!.back,
              color: Colors.white,
            ),
          ),
        ),
        body: Consumer<AgendaPageProvider>(
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
                      elevation: 0.0,
                      type: StepperType.horizontal,
                      currentStep: provider.currentIndex,
                      onStepTapped: (index) {
                        provider.setStepIndex(index);
                      },

                        onStepContinue: () {
                          if (_formKey.currentState!.validate()) {

                            _formKey.currentState?.save();
                            if (provider.currentIndex >= 1) {
                              submitForm(context);
                            } else {
                              provider.setStepIndex(provider.currentIndex + 1);
                            }

                            if (provider.currentIndex < provider.listAgenda!.agendas!.length - 1) {
                              provider.onStepContinue();
                            } else {
                              submitForm(context);
                            }

                            final currentAgenda = provider.listAgenda!.agendas![provider.currentIndex];

                            // Get the description and reservations for both languages
                            String? descriptionEn = provider.enableEnglish || provider.enableArabicAndEnglish ? provider.descriptionControllers[provider.currentIndex].text : null;
                            String? descriptionAr = provider.enableArabic || provider.enableArabicAndEnglish ? provider.arabicDescriptionControllers[provider.currentIndex].text : null;
                            String? reservationsEn = provider.enableEnglish || provider.enableArabicAndEnglish ? provider.reservationsControllers[provider.currentIndex].text : null;
                            String? reservationsAr = provider.enableArabic || provider.enableArabicAndEnglish ? provider.arabicReservationsControllers[provider.currentIndex].text : null;

                            // Update the progress based on the fields filled
                            provider.updateAgendaProgress(
                                currentAgenda.agendaId!,
                                descriptionEn: descriptionEn,
                                descriptionAr: descriptionAr,
                                reservationsEn: reservationsEn,
                                reservationsAr: reservationsAr
                            );


                          }
                        },
                        onStepCancel: () {
                        if (provider.currentIndex > 0) {
                          provider.setStepIndex(provider.currentIndex - 1);
                        }
                      },
                      steps: <Step>[
                        Step(
                          state: provider.currentIndex > 0 ? StepState.complete : StepState.indexed,
                          isActive: provider.currentIndex >= 0,
                          title: CustomText(text: 'Minutes Meeting'),
                          content: SizedBox(
                            height: 550,
                            child: buildAgendaDetailsStep(provider),
                          ),
                        ),
                        Step(
                          state: provider.currentIndex > 1 ? StepState.complete : StepState.indexed,
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
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              child: CustomText(text: isLastStep ? 'Save' : 'Next'),
                            ),
                            if (provider.currentIndex > 0)
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: CustomText(text: 'Back'),
                              ),
                            // Spacer(),
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
                                                percent: percentCompleted,
                                                center: Text(
                                                  '${(percentCompleted * 100).toStringAsFixed(0)}%',  // Show the percentage
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                                ),
                                                progressColor: percentCompleted == 1.0 ? Colors.green : Colors.orange,
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






  void submitForm(BuildContext context) async{
    log.i("hi there");
    final provider = Provider.of<AgendaPageProvider>(context, listen: false);
    final providerM = Provider.of<MinutesProviderPage>(context, listen: false);


    // Collect data for each agenda
    List<Map<String, dynamic>> agendaDataList = [];
    for (int i = 0; i < provider.listAgenda!.agendas!.length; i++) {
      var agenda = provider.listAgenda!.agendas![i];
      // Save the details from the controllers back into the agenda
      provider.saveDetails(agenda);

      // Collect data for the current agenda
      Map<String, dynamic> agendaData = {
        'index': i,
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
    for (int i = 0; i < provider.listAgenda!.agendas!.length; i++) {
      updatedDetails.add({
        'agendaId': provider.listAgenda!.agendas![i].agendaId,
        'missions': provider.descriptionControllers[i].text,
        'arabicMissions': provider.arabicDescriptionControllers[i].text,
        'reservations': provider.reservationsControllers[i].text,
        'arabicReservations': provider.arabicReservationsControllers[i].text,
        'listOfAgendas': agendaDataList,
      });
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
      'agendas': updatedDetails,
      'attendance': updatedAttendance,
      "meeting_id": widget.meetingId,
      'missions': provider.descriptionControllers.map((controller) => controller.text).toList(),
      'reservations': provider.reservationsControllers.map((controller) => controller.text).toList(),

    };
    log.i(data);
    // Update provider with collected data and submit to backend
    // await providerM.submitAgendaDetails(data);
    provider.setLoading(false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MinutesMeetingList(),
      ),
    );
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // SizedBox(
            //   height: 300,
            //   child: QuillSimpleToolbar(
            //     configurations:   QuillSimpleToolbarConfigurations(controller: _controller),
            //   ),
            // ),
            // SizedBox(
            //   child: QuillEditor.basic(
            //     configurations:   QuillEditorConfigurations(controller: _controller),
            //   ),
            // )
            // ,
            Container(
              child: buildLanguageToggle(context),
            ),
            SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.listAgenda!.agendas!.length,
                itemBuilder: (BuildContext context, int agendaIndex) {
                  final agenda = provider.listAgenda!.agendas![agendaIndex];
                  final missionsController = provider.descriptionControllers[agendaIndex];
                  final reservationsController = provider.reservationsControllers[agendaIndex];
                  final arabicMissionsController = provider.arabicDescriptionControllers[agendaIndex];
                  final arabicReservationsController = provider.arabicReservationsControllers[agendaIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (enableEnglish)
                        generateEnglishSide(agenda: agenda, missionsController: missionsController, reservationsController: reservationsController, provider: provider),
                      if (enableArabicAndEnglish)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: generateEnglishSide(agenda: agenda, missionsController: missionsController, reservationsController: reservationsController, provider: provider),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: generateArabicSide(agenda: agenda, arabicMissionsController: arabicMissionsController, arabicReservationsController: arabicReservationsController, provider: provider),
                              ),
                            ),
                          ],
                        ),
                      if (enableArabic)
                        generateArabicSide(agenda: agenda, arabicMissionsController: arabicMissionsController, arabicReservationsController: arabicReservationsController, provider: provider),
                      SizedBox(
                        height: 40,
                      ),
                      Divider(color: Colour().buttonBackGroundRedColor, height: 0.2,thickness: 3,endIndent: 5,indent: 5,),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  );
                },
              ),
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
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        child: Column(
          children: [
            buildAddButton(provider),
            const SizedBox(height: 10),
            for (int i = 0; i < provider.attendedNameControllers.length; i++)
              Column(
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
                                return 'Please enter position name';
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
          ],
        ),
      ),
    );
  }


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
    required this.arabicMissionsController,
    required this.arabicReservationsController,
    required this.provider

  });

  final Agenda agenda;
  final TextEditingController arabicMissionsController;
  final TextEditingController arabicReservationsController;
  final AgendaPageProvider provider;
  @override
  Widget build(BuildContext context) {
    return Directionality(
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
          SizedBox(
            height: 100,
            child: TextFormField(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: null,
              expands: true,

              controller: arabicMissionsController,

              onChanged: (value) {
                provider.updateAgendaProgress(agenda.agendaId!, descriptionAr: value);
              },
              decoration: InputDecoration(
                hintText: 'أدخل النقاش',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'أدخل النقاش';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10.0),
          arabicGenerateForm(context ,provider,agenda),

          const SizedBox(height: 10.0),
          CustomText(
            text: 'التحفظات',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            // color: Colors.black,
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            height: 100,
            child: TextFormField(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: null,
              expands: true,
              controller: arabicReservationsController,
              onChanged: (value) {
                provider.updateAgendaProgress(agenda.agendaId!, reservationsAr: value);
              },
              decoration: InputDecoration(
                hintText: 'أدخل التحفظات',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'أدخل التحفظات';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class generateEnglishSide extends StatelessWidget {
  const generateEnglishSide({
    super.key,
    required this.agenda,
    required this.missionsController,
    required this.reservationsController,
    required this.provider
  });

  final Agenda agenda;
  final TextEditingController missionsController;
  final TextEditingController reservationsController;
  final AgendaPageProvider provider;
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
        SizedBox(
          height: 100,
          child: TextFormField(
            controller: missionsController,
            onChanged: (value) {
              provider.updateAgendaProgress(agenda.agendaId!, descriptionEn: value);
            },
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              hintText: 'Enter Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10.0),
        englishGenerateForm(context ,provider, agenda),
        const SizedBox(height: 10.0),
        CustomText(
          text: 'Reservations',
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          // color: Colors.black,
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          height: 100,
          child: TextFormField(
            maxLines: null,
            expands: true,
            controller: reservationsController,
            onChanged: (value) {
              provider.updateAgendaProgress(agenda.agendaId!, reservationsEn: value);
            },
            decoration: InputDecoration(
              hintText: 'Enter reservations',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter reservations';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}

Widget arabicGenerateForm(BuildContext context ,AgendaPageProvider provider, Agenda agenda) {
  // Filter Arabic resolutions and directions separately
  final List<DetailDetails> arabicResolutions = agenda.details?.detailDetails
      ?.where((detail) => detail.serialNumberResolutionAr != null)
      .toList() ??
      [];
  final List<DetailDetails> arabicDirections = agenda.details?.detailDetails
      ?.where((detail) => detail.serialNumberDirectionAr != null)
      .toList() ??
      [];

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Resolutions Column
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => provider.addArResolution(agenda), // Pass the specific agenda
              child: CustomText(text: 'اضافة قرار'),
            ),
            arabicResolutions.isNotEmpty ?
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Set max height as 50% of screen height
              ),
              child: ListView.builder(
                itemCount: arabicResolutions.length,
                itemBuilder: (context, index) {
                  final arResolution = arabicResolutions[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: arResolution.serialNumberResolutionAr ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        height: 100,
                        child: buildCustomTextFormField(
                          controller: provider.getOrCreateController(provider.arabicResolutionControllers, arResolution.detailId ?? 0, arResolution.textResolutionAr),
                          hint: 'القرار',
                          validatorMessage: 'القرار',
                        ),
                      ),
                      IconButton(
                        icon: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,),
                        onPressed: () => provider.removeArabicResolution(agenda, arResolution.detailId!),
                      ),
                    ],
                  );
                },
              ),
            ): SizedBox.shrink(),
          ],
        ),
      ),
      const SizedBox(width: 10.0),
      // Directions Column
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => provider.addArDirection(agenda), // Pass the specific agenda
              child: CustomText(text: 'اضافة توجيه'),
            ),
            arabicDirections.isNotEmpty ?
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Set max height as 50% of screen height
              ),
              child: ListView.builder(
                itemCount: arabicDirections.length,
                itemBuilder: (context, index) {
                  final arDirection = arabicDirections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: arDirection.serialNumberDirectionAr ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        height: 100,
                        child: buildCustomTextFormField(
                          controller: provider.getOrCreateController(provider.arabicDirectionControllers, arDirection.detailId ?? 0, arDirection.textDirectionAr),
                          hint: 'التوجيه',
                          validatorMessage: 'التوجيه',
                        ),
                      ),
                      IconButton(
                        icon: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,),
                        onPressed: () => provider.removeArabicDirection(agenda, arDirection.detailId!),
                      ),
                    ],
                  );
                },
              ),
            ): SizedBox.shrink(),
          ],
        ),
      ),
    ],
  );
}


englishGenerateForm(BuildContext context ,AgendaPageProvider provider, Agenda agenda) {

  // Filter resolutions and directions separately
  final List<DetailDetails> resolutions = agenda.details?.detailDetails
      ?.where((detail) => detail.serialNumberResolutionEn != null)
      .toList() ??
      [];
  final List<DetailDetails> directions = agenda.details?.detailDetails
      ?.where((detail) => detail.serialNumberDirectionEn != null)
      .toList() ??
      [];

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Resolutions Column
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => provider.addResolution2(agenda),
              child: CustomText(text: 'Add Resolution'),
            ),
            resolutions.isNotEmpty ?
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Set max height as 50% of screen height
              ),
              child: ListView.builder(
                itemCount: resolutions.length,
                itemBuilder: (context, index) {
                  final resolution = resolutions[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: resolution.serialNumberResolutionEn ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        height: 100,
                        child: buildCustomTextFormField(
                          controller:  provider.getOrCreateController(provider.englishResolutionControllers, resolution.detailId ?? 0, resolution.textResolutionEn),
                          hint: 'Enter resolution',
                          validatorMessage: 'Please enter resolution',
                        ),
                      ),
                      IconButton(
                        icon: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,),
                        onPressed: () =>
                            provider.removeResolution(agenda, resolution.detailId!),
                      ),
                    ],
                  );
                },
              ),
            ) : SizedBox.shrink(),
          ],
        ),
      ),
      const SizedBox(width: 10.0),
      // Directions Column
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed:  () => provider.addDirection2(agenda),
              child: CustomText(text: 'Add Direction',),
            ),
            directions.isNotEmpty ?
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Set max height as 50% of screen height
              ),
              child: ListView.builder(
                itemCount: directions.length,
                itemBuilder: (context, index) {
                  final direction = directions[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: direction.serialNumberDirectionEn ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                          color: Colors.orange
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        height: 100,
                        child: buildCustomTextFormField(
                          controller: provider.getOrCreateController(provider.englishDirectionControllers, direction.detailId ?? 0, direction.textDirectionEn),
                          hint: 'Enter direction',
                          validatorMessage: 'Please enter direction',
                        ),
                      ),
                      IconButton(
                        icon: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,),
                        onPressed: () =>
                            provider.removeDirection(agenda,direction.detailId!),
                      ),
                    ],
                  );
                },
              ),
            ) : SizedBox.shrink(),
          ],
        ),
      ),
    ],
  );

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
    validator: (val) => val != null && val.isEmpty ? validatorMessage : null,

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
