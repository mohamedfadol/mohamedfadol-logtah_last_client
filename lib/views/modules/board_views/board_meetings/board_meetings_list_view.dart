
import 'package:diligov_members/colors.dart';
import 'package:diligov_members/views/modules/board_views/board_meetings/edit_board_meeting_form.dart';
import 'package:diligov_members/views/modules/board_views/board_meetings/show_board_meeting_details.dart';
import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../models/data/years_data.dart';
import '../../../../models/meeting_model.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../widgets/action_menu_column.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/build_meeting_form_card.dart';
import '../../../../widgets/custom_dialog.dart';
import '../../../../widgets/custom_message.dart';
import '../../../../widgets/custome_text.dart';
import '../../../../widgets/dropdown_string_list.dart';
import '../../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class BoardMeetingsListView extends StatefulWidget {
  const BoardMeetingsListView({super.key});
  static const routeName = '/BoardMeetingsListView';

  @override
  State<BoardMeetingsListView> createState() => _BoardMeetingsListViewState();
}

class _BoardMeetingsListViewState extends State<BoardMeetingsListView> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget CombinedCollectionBoardCommitteeDataDropDownList(){
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<MeetingPageProvider>(
        builder: (context, combinedDataProvider, child) {
          if (combinedDataProvider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData == null) {
            combinedDataProvider.getListOfCombinedCollectionBoardAndCommittee();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              combinedDataProvider.collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.isEmpty
                  ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,
                  items: combinedDataProvider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData?.map((item) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: '${item.type.toString()}-${item.id.toString()}',
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.black),
                        ),
                        child: Center(child: CustomText(text: item.name.toString())),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    combinedDataProvider.setCombinedCollectionBoardCommittee(selectedItem!);
                  },
                  hint: CustomText(
                    text: combinedDataProvider.selectedCombined != null
                        ? combinedDataProvider.selectedCombined!
                        : 'Select an item please',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (combinedDataProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    combinedDataProvider.dropdownError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showUnPublished = context.watch<MeetingPageProvider>().showUnPublished;
    final showPublished = context.watch<MeetingPageProvider>().showPublished;
    final showArchived = context.watch<MeetingPageProvider>().showArchived;
    return Scaffold(
      appBar: Header(context),
      body: SingleChildScrollView(
        child: Consumer<MeetingPageProvider>(
            builder: (BuildContext context, provider, child){
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 200,
                          padding:const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colour().buttonBackGroundRedColor,
                          ),
                          child: DropdownStringList(
                            boxDecoration: Colors.white,
                            hint: CustomText(text: AppLocalizations.of(context)!.select_year),
                            selectedValue: provider.yearSelected,
                            dropdownItems: yearsData,
                            onChanged: (String? newValue) async {
                              provider.setYearSelected(newValue!.toString());
                               await provider.fetchMeetings(true, false, false, provider.yearSelected, provider.combined);
                            },
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 7.0),
                        CombinedCollectionBoardCommitteeDataDropDownList(),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: showUnPublished ? Colour().buttonBackGroundRedColor : Colors.grey,
                          ),
                          onPressed: () {
                            context
                                .read<MeetingPageProvider>()
                                .toggleUnPublished();
                          },
                          child: _buildContainer(
                            text: 'Unpublished',
                            width: 150,
                            theme: theme,
                          ),
                        ),
                        SizedBox(width: 7.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            showPublished ? Colour().buttonBackGroundRedColor : Colors.grey,
                          ),
                          onPressed: () {
                            context.read<MeetingPageProvider>().togglePublished();
                          },
                          child: _buildContainer(
                            text: 'Published',
                            width: 150,
                            theme: theme,
                          ),
                        ),
                        SizedBox(width: 7.0),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              showArchived ? Colour().buttonBackGroundRedColor : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<MeetingPageProvider>().toggleArchived();
                            },
                            child: _buildContainer(
                              text: 'Archived',
                              width: 150,
                              theme: theme,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                Consumer<MeetingPageProvider>(
                  builder: (BuildContext context, MeetingPageProvider provider, Widget? child) {

                    if (provider.dataOfMeetings?.meetings == null) {
                      provider.fetchMeetings(true, false, false, provider.yearSelected, provider.combined);
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

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Builder(
                        builder: (BuildContext context) {
                          return Row(
                            children: [
                              _buildAddMeetingButtonCard(context: context, theme: theme, provider: provider),
                              // SizedBox(height: 15),
                              Expanded(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height -168,
                                  child: provider.dataOfMeetings?.meetings != null && provider.dataOfMeetings!.meetings!.isNotEmpty ? ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.dataOfMeetings!.meetings!.length,
                                    separatorBuilder: (_, index) => SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final meeting = provider.dataOfMeetings!.meetings![index];

                                      return Container(
                                        key: ValueKey(provider.showActionsMap[index]),
                                        padding: EdgeInsets.all(10),
                                        child: _buildMeetingCard(
                                          status: meeting.meetingPublishedStatus ?? '',
                                          index: index,
                                          context: context,
                                          title: meeting.meetingTitle ?? '',
                                          description: meeting.meetingDescription ?? '',
                                          startDate: meeting.meetingStartDate ?? '',
                                          endDate: meeting.meetingEndDate ?? '',
                                          moreInfo: meeting.meetingBy ?? '',
                                          link: meeting.isVisible! ?  '${meeting.meetingMediaName}' : 'Attended Meeting',
                                          theme: theme,
                                          showActions: provider.showActionsMap[index] ?? false,
                                          toggleActions: () => provider.toggleActions(index),
                                          onEdit: () {
                                            meeting.meetingId.toString();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => EditBoardMeetingForm(event: meeting),
                                              ),
                                            );
                                          },
                                          onShowMeetingDetails: () {
                                            if (meeting.meetingPublishedStatus == 'PUBLISHED') {
                                              meeting.meetingId.toString();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => ShowBoardMeetingDetails(meeting: meeting),
                                                ),
                                              );
                                            }
                                          },
                                          onDelete: () {
                                            dialogDeleteMeeting(meeting);
                                          },
                                          onArchive: () {
                                            if (meeting.meetingPublishedStatus != 'ARCHIVED') {
                                              dialogArchivedMeeting(meeting);
                                            }
                                          },
                                          onNotify: () {
                                            dialogNotifyMeeting(meeting);
                                          },
                                          onPublish: () {
                                            if (meeting.meetingPublishedStatus != 'PUBLISHED') {
                                              dialogPublishedMeeting(meeting);
                                            }
                                          },
                                          onUnPublish: () {
                                            if (meeting.meetingPublishedStatus != 'UNPUBLISHED') {
                                              dialogUnPublishedMeeting(meeting);
                                            }
                                          },
                                          onClone: () {
                                            // Handle clone
                                          },
                                        ),
                                      );
                                    },
                                  )
                                      : Center(child: CustomText(text: 'no meeting found',),),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                )

                ],
                ),
              );
            }
        ),
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


  Widget _buildContainer({
    required String text,
    required double width,
    required ThemeData theme,
  }) {

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      decoration: BoxDecoration(
      ),
      child: Center(
        child: CustomText(
          text: text,
          color: Colour().mainWhiteTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future dialogDeleteMeeting(Meeting meeting) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.are_you_sure_to_delete} ${meeting.meetingTitle!} ?',
        onConfirm: () async {
          String message = await removeMeeting(meeting);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              // backgroundColor: message.contains('successfully') ? Colors.greenAccent : Colors.redAccent,
              backgroundColor: message == 'Meeting deleted successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> removeMeeting(Meeting meeting) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    // Step 1: Check if the meeting has associated agendas
    String message = await provider.deleteMeeting(meeting);
    // Step 2: If the meeting has agendas, ask for additional confirmation
    if (message.contains('associated agendas')) {
      message = await showAdditionalConfirmationDialog(context, meeting);
    }
    return message;
  }

  Future<String> showAdditionalConfirmationDialog(BuildContext context, Meeting meeting) async {
    // Await the dialog result and ensure non-null value is returned
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomDialog(
          title: 'This meeting has associated agendas. Are you sure you want to delete it?',
          onConfirm: () async {
            final provider = Provider.of<MeetingPageProvider>(context, listen: false);
            String message = await provider.deleteMeetingWithAgendas(meeting); // Call the final delete function
            Navigator.of(dialogContext).pop(message); // Return the message to the parent dialog
          },
          onCancel: () {
            Navigator.of(dialogContext).pop('Meeting deletion cancelled.');
          },
        );
      },
    );

    // Return result or default message if the dialog result is null
    return result ?? 'Action cancelled.';
  }

  Future dialogPublishedMeeting(Meeting meeting) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.published} ${meeting.meetingTitle!} ?',

        onConfirm: () async {
          String message = await publishedMeeting(meeting);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              backgroundColor: message == 'Meeting published successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> publishedMeeting(Meeting meeting) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    String message = await provider.publishedMeeting(meeting);
    return message;
  }

  Future dialogUnPublishedMeeting(Meeting meeting) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.unPublished} ${meeting.meetingTitle!} ?',
        onConfirm: () async {
          String message = await unPublishedMeeting(meeting);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              backgroundColor: message == 'Meeting unPublished successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
      //
    },
  );

  Future<String> unPublishedMeeting(Meeting meeting) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    String message = await provider.unPublishedMeeting(meeting);
    return message;
  }

  Future dialogArchivedMeeting(Meeting meeting) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.archived} ${meeting.meetingTitle!} ?',
        onConfirm: () async {
          String message = await archivedMeeting(meeting);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              backgroundColor: message == 'Meeting archived successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> archivedMeeting(Meeting meeting) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    String message = await provider.archiveMeeting(meeting);
    return message;
  }

  Future dialogNotifyMeeting(Meeting meeting) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.notify} ${meeting.meetingTitle!} ?',
        onConfirm: () async {
          String message = await notifyMeeting(meeting);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              backgroundColor: message == 'Meeting notify successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> notifyMeeting(Meeting meeting) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    String message = await provider.notifyMeeting(meeting);
    return message;
  }
}



Widget _buildInfoContainer(String text, double fontSize, FontWeight fontWeight) {
  return Flexible(
    child: Material(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 0.1),
            left: BorderSide(width: 0.1),
            bottom: BorderSide(width: 0.1),
          ),
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), // (x,y)
              blurRadius: 6.0,
            ),
          ],
          borderRadius: BorderRadius.circular(2),
        ),
        child: CustomText(
          text: text,
          // color: Colour().mainBlackTextColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    ),
  );
}



Widget _buildMeetingCard({
  required BuildContext context,
  required String title,
  required String description,
  required String startDate,
  required String endDate,
  required String moreInfo,
  required String link,
  required ThemeData theme,
  required bool showActions,
  required int index,
  required VoidCallback toggleActions,
  required VoidCallback onEdit,
  required VoidCallback onShowMeetingDetails,
  required VoidCallback onDelete,
  required String status,
  required VoidCallback onArchive,
  required VoidCallback onNotify,
  required VoidCallback onPublish,
  required VoidCallback onUnPublish,
  required VoidCallback onClone,
}) {
  final provider = Provider.of<MeetingPageProvider>(context, listen: true);
  bool currentShowActions = provider.visibleActionIndex == index; // Determine visibility
  bool isArchived = status == 'ARCHIVED';
  bool isPublished = status == 'PUBLISHED';
  bool isUnpublished = status == 'UNPUBLISHED';

  return InkWell(
    onTap: toggleActions,
    child: Stack(
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          dashPattern: [10, 10],
          color: Colour().buttonBackGroundRedColor,
          strokeWidth: 4,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInfoContainer(title, 18, FontWeight.bold),
                SizedBox(height: 5.0),
                _buildInfoContainer(description, 16, FontWeight.normal),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoContainer(startDate,  14, FontWeight.normal),
                    SizedBox(width: 20),
                    _buildInfoContainer(endDate,  14, FontWeight.normal),
                  ],
                ),
                SizedBox(height: 10.0),
                _buildInfoContainer(moreInfo,  14, FontWeight.normal),
                SizedBox(height: 5.0),

                // Clickable TextButton for link
                TextButton(
                  onPressed: () async {
                    // Trim the link to remove any leading/trailing spaces
                    final String trimmedLink = link.trim();

                    try {
                      final Uri url = Uri.parse(trimmedLink);

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        // Handle the case where the URL cannot be opened
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cannot open the link')),
                        );
                      }
                    } catch (e) {
                      // Handle any format exceptions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid URL format: $trimmedLink')),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      CustomIcon(icon: Icons.link),
                      SizedBox(width: 10,),
                      CustomText(text: "Visit meeting ${link}",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),

        if (currentShowActions)
          Positioned(
            right: 15,
            top: 19,
            child: Container(
              height: 450,
              width: 220,
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(width: 0.1),
              ),
              child: ActionMenuColumn(
                actions: {
                  AppLocalizations.of(context)!.edit: Icons.edit,
                  if (isPublished) AppLocalizations.of(context)!.view: Icons.arrow_forward_sharp,
                  AppLocalizations.of(context)!.delete: Icons.delete,
                  if (!isArchived) AppLocalizations.of(context)!.archived : Icons.archive,
                  AppLocalizations.of(context)!.notifications: Icons.notifications,
                  AppLocalizations.of(context)!.copy: Icons.copy,
                  if (!isPublished) AppLocalizations.of(context)!.published : Icons.public,
                  if (!isUnpublished) AppLocalizations.of(context)!.unPublished : Icons.public_off_outlined,
                },
                callbacks: {
                  AppLocalizations.of(context)!.edit: onEdit,
                  if (isPublished) AppLocalizations.of(context)!.view: onShowMeetingDetails,
                  AppLocalizations.of(context)!.delete: onDelete,
                  if (!isArchived) AppLocalizations.of(context)!.archived : onArchive,
                  AppLocalizations.of(context)!.notifications: onNotify,
                  AppLocalizations.of(context)!.copy: onClone,
                  if (!isPublished) AppLocalizations.of(context)!.published: onPublish,
                  if (!isUnpublished) AppLocalizations.of(context)!.unPublished : onUnPublish,
                },
              ),
            ),
          ),
      ],
    ),
  );
}


Widget _buildAddMeetingButtonCard({
  required BuildContext context,
  required ThemeData theme,
  required MeetingPageProvider provider}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor ;

  return Container(
    width: 300,
    height: MediaQuery.of(context).size.height -168,
    padding: const EdgeInsets.all(5.0),
    margin: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      border: Border(
          right: BorderSide(width: 0.1),
          left: BorderSide(width: 0.1),
          bottom: BorderSide(width: 0.1)
      ),
      color: containerColor,
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0),
          blurRadius: 6.0,
        ),
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BuildMeetingFormCard(),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Aligns children to the center along the main axis
          crossAxisAlignment: CrossAxisAlignment.center, // Aligns children to the center along the cross axis
          children: [
            CustomIcon(
              icon: Icons.add,
              color: Colour().buttonBackGroundRedColor,
              size: 180,
            ),
            // SizedBox(height: 10.0),
            CustomText(
              text: AppLocalizations.of(context)!.add_meeting,
              fontSize: 20,
            ),
          ],
        )
    ),
  );
}
