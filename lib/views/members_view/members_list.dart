import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:diligov_members/views/members_view/edit_member_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../colors.dart';
import '../../core/domains/app_uri.dart';
import '../../models/member.dart';
import '../../providers/committee_provider_page.dart';
import '../../providers/member_page_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../providers/positions_provider_page.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/stand_text_form_field.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';

import '../modules/disclosures_views/competitions/views/view_competition_with_company.dart';
import '../modules/disclosures_views/confirmation_of_independence/views/view_competition_with_confirmation_of_independence.dart';
import '../modules/disclosures_views/related_parties/views/view_competition_with_related_parties.dart';

class MembersList extends StatefulWidget {
  const MembersList({Key? key}) : super(key: key);
  static const routeName = '/MembersList';
  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  GlobalKey<FormState> insertMemberFormGlobalKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();
  bool isLoading = false;

  late SignatureController signController;
  Uint8List? signature;
  Uint8List? uploadSignature;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    signController = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 1,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    signController.dispose();
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Consumer<MemberPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfMembers?.members == null) {
              context.read<MemberPageProvider>().getListOfMember(context);
              context.read<MemberPageProvider>().fetchDropdownData();
              return buildLoadingSniper();
            }

            return provider.dataOfMembers!.members!.isEmpty
                ? buildEmptyMessage(
                    AppLocalizations.of(context)!.no_data_to_show)
                : Column(
                    children: [
                      Expanded(
                        child: _MemberTable(),
                      ),
                      _AddMemberButton(),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _MemberTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberPageProvider>().dataOfMembers!.members!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showBottomBorder: true,
              dividerThickness: 0.3,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Theme.of(context).primaryColor),
              columns: [
                DataColumn(label: CustomText(text: "Image")),
                DataColumn(label: CustomText(text: "First Name")),
                DataColumn(label: CustomText(text: "Last Name")),
                DataColumn(label: CustomText(text: "E-mail")),
                DataColumn(label: CustomText(text: "Position")),
                DataColumn(label: CustomText(text: "Actions")),
              ],
              rows: members.map((member) {
                return DataRow(cells: [
                  DataCell(CircleAvatar(
                    backgroundImage: member.memberProfileImage != null
                        ? NetworkImage(
                            '${AppUri.profileImages}/${member.businessId}/${member.memberProfileImage!}')
                        : const AssetImage("assets/images/profile.jpg")
                            as ImageProvider,
                    radius: 20,
                  )),
                  DataCell(CustomText(text: member.memberFirstName ?? "-")),
                  DataCell(CustomText(text: member.memberLastName ?? "-")),
                  DataCell(CustomText(text: member.memberEmail ?? "-")),
                  DataCell(CustomText(
                    text: (member.positions?.isNotEmpty ?? false)
                        ? member.positions!
                            .map((p) => p.positionName ?? "-")
                            .join(", ")
                        : "-",
                    fontWeight: FontWeight.bold,
                  )),
                  DataCell(_ActionsRow(member: member)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Member member;

  const _ActionsRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _openEditMemberDialog(context, member),
          icon: CustomIcon(icon: Icons.pending_sharp, color: Colors.white),
          label: CustomText(text: 'Edit'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),
        const SizedBox(width: 5),
        ElevatedButton.icon(
          onPressed: () => _showDeleteConfirmation(context, member),
          icon: CustomIcon(
              icon: Icons.restore_from_trash_outlined, color: Colors.white),
          label: CustomText(text: 'Delete'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),
        // const SizedBox(width: 5),
        // ElevatedButton.icon(
        //   onPressed: ()  {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => RolesListView()
        //             ///PermissionsListView(member: member),
        //       ),
        //     );
        //   },
        //   icon: CustomIcon(icon: Icons.local_attraction_rounded,color: Colors.white),
        //   label: CustomText(text: 'Permissions'),
        //   style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.indigo,
        //       padding: EdgeInsets.symmetric(horizontal: 10.0)
        //   ),
        // ),
        const SizedBox(width: 5),
        ElevatedButton.icon(
          label: CustomText(text: 'Rest Password'),
          icon: CustomIcon(icon: Icons.lock_open_outlined, color: Colors.white),
          onPressed: () {
            print('Rest Password');

            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => RolesListView(),
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),

        const SizedBox(width: 5),
        ElevatedButton(
          child: CustomText(text: 'Competition With Company'),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ViewCompetitionWithCompany(member: member, type: 'competition_with_company')
                )
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          child: CustomText(text: 'Competition With Confirmation Of Independence'),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ViewCompetitionWithConfirmationOfIndependence(member: member, type: 'competition_with_confirmation_of_independence')
                )
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),

        const SizedBox(width: 5),
        ElevatedButton(
          child: CustomText(text: 'Competition With Related Parties'),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ViewCompetitionWithRelatedParties(member: member, type: 'competition_with_related_parties')
                )
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: 10.0)),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: "Confirm Delete"),
          content: CustomText(
            text:
                "Are you sure you want to delete ${member.memberFirstName} ${member.memberLastName}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: CustomText(text: "Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  "member_id": member.memberId,
                };
                // Call the delete method in the provider
                context
                    .read<MemberPageProvider>()
                    .deleteMember(member, updatedData);

                Navigator.of(context).pop(); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: CustomText(text: 'Member remove successfully'),
                    // backgroundColor: message.contains('successfully') ? Colors.greenAccent : Colors.redAccent,
                    backgroundColor: Colors.greenAccent,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: CustomText(text: "Delete"),
            ),
          ],
        );
      },
    );
  }

  void _openEditMemberDialog(BuildContext context, Member member) {
    final provider = context.read<MemberPageProvider>();

    // Fetch member details when opening dialog
    provider.fetchMemberDetails(member.memberId!).then((_) {
      showDialog(
        context: context,
        builder: (context) => EditMemberDialog(member: provider.member),
      );
    });
  }
}

class _AddMemberButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
      child: ElevatedButton.icon(
        onPressed: () => _openMemberCreateDialog(context),
        icon: CustomIcon(icon: Icons.add),
        label: CustomText(text: 'Add New Member'),
      ),
    );
  }

  void _openMemberCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddMemberDialog(),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog();

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  XFile? _imageFile;
  String? _selectedPosition;
  String? _selectedBoard;
  List<dynamic> _selectedCommittees = [];
  bool _isAdmin = false; // New variable for admin checkbox

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberPageProvider>();

    return AlertDialog(
      title: CustomText(text: "Add New Member"),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image Upload
                _imagePicker(context),
                SizedBox(
                  height: 15,
                ),
                // Input fields
                StandTextFormField(
                  labelText: "First Name",
                  controllerField: _firstNameController,
                  valid: (val) => val != null && val.isNotEmpty
                      ? null
                      : 'Please enter a valid first name',
                ),
                SizedBox(
                  height: 15,
                ),
                StandTextFormField(
                  labelText: "Last Name",
                  controllerField: _lastNameController,
                  valid: (val) => val != null && val.isNotEmpty
                      ? null
                      : 'Please enter a valid last name',
                ),
                SizedBox(
                  height: 15,
                ),
                StandTextFormField(
                  labelText: "Email",
                  controllerField: _emailController,
                  valid: (val) => val != null && val.contains('@')
                      ? null
                      : 'Please enter a valid email',
                ),
                SizedBox(
                  height: 15,
                ),

                Consumer<PositionsProviderPage>(
                  builder: (context, positionProvider, child) {
                    if (positionProvider.dataOfPositions?.positions == null) {
                      positionProvider.getDataOfPositions();
                      return buildLoadingSniper();
                    }

                    return positionProvider.dataOfPositions!.positions!.isEmpty
                        ? buildEmptyMessage(
                            AppLocalizations.of(context)!.no_data_to_show)
                        : MultiSelectDialogField(
                            title: CustomText(text: "Positions"),
                            buttonText: const Text("Select Positions"),
                            items: positionProvider.dataOfPositions!.positions!
                                .map((position) => MultiSelectItem(
                                      position.positionId,
                                      position.positionName.toString(),
                                    ))
                                .toList(),
                            initialValue: positionProvider.selectedPositionsIds,
                            onConfirm: (values) {
                              for (var id in values) {
                                positionProvider.addSelectedPosition(id);
                              }
                            },
                            chipDisplay: MultiSelectChipDisplay(
                              items: positionProvider.selectedPositionsIds
                                  .map((id) => MultiSelectItem(
                                        id,
                                        positionProvider
                                            .dataOfPositions!.positions!
                                            .firstWhere(
                                                (p) => p.positionId == id)
                                            .positionName
                                            .toString(),
                                      ))
                                  .toList(),
                              onTap: (value) {
                                positionProvider.removeSelectedPosition(value);
                              },
                            ),
                            confirmText: Text('Confirm'),
                            cancelText: Text('Cancel'),
                          );
                  },
                ),

                SizedBox(
                  height: 15,
                ),

                // Dropdown: Board
                DropdownButtonFormField<String>(
                  value: _selectedBoard,
                  hint: CustomText(text: "Select Board"),
                  items: provider.boards
                      .map((board) => DropdownMenuItem<String>(
                            value: board['id'].toString(),
                            child: CustomText(text: board['board_name']),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBoard = value),
                ),

                SizedBox(
                  height: 15,
                ),

                Consumer<CommitteeProviderPage>(
                    builder: (context, committeeProvider, child) {
                  if (committeeProvider.committeesData?.committees == null) {
                    committeeProvider.getListOfCommitteesData();
                    return buildLoadingSniper();
                  }

                  return committeeProvider.committeesData!.committees!.isEmpty
                      ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                      : MultiSelectDialogField(
                          title: CustomText(text: "Committees"),
                          buttonText: const Text("Select Committees"),
                          items: committeeProvider.committeesData!.committees!
                              .map((committee) => MultiSelectItem(
                                    committee.id,
                                    committee.committeeName.toString(),
                                  ))
                              .toList(),
                          initialValue: committeeProvider.selectedCommitteesIds,
                          onConfirm: (values) {
                            for (var id in values) {
                              committeeProvider.addSelectedCommittees(id);
                            }
                          },
                          chipDisplay: MultiSelectChipDisplay(
                            items: committeeProvider.selectedCommitteesIds
                                .map((id) => MultiSelectItem(
                                      id,
                                      committeeProvider
                                          .committeesData!.committees!
                                          .firstWhere((c) => c.id == id)
                                          .committeeName
                                          .toString(),
                                    ))
                                .toList(),
                            onTap: (value) {
                              committeeProvider.removeSelectedCommittees(value);
                            },
                          ),
                          confirmText: Text('confirm'),
                          cancelText: Text('cancel'),
                        );
                }),
                // Multi-select: Committees
                SizedBox(
                  height: 15,
                ),

                // Checkbox for isAdmin
                CheckboxListTile(
                  title: CustomText(text: "Is Admin"),
                  value: _isAdmin,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAdmin = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: CustomText(text: 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final tokenCode = await FirebaseMessaging.instance.getToken();
            var _business_id = provider.user.businessId.toString();
            if (_formKey.currentState!.validate()) {
              var selectedPositionIds =
                  Provider.of<PositionsProviderPage>(context, listen: false)
                      .selectedPositionsIds;
              var selectedCommitteesIds =
                  Provider.of<CommitteeProviderPage>(context, listen: false)
                      .selectedCommitteesIds;
              final data = {
                "member_first_name": _firstNameController.text,
                "member_last_name": _lastNameController.text,
                "member_email": _emailController.text,
                "position_ids": selectedPositionIds,
                "board_id": _selectedBoard,
                "business_id": _business_id,
                "committee_id": selectedCommitteesIds,
                "is_admin": _isAdmin,
                "imageName": _imageFile!.path.split("/").last != null
                    ? _imageFile!.path.split("/").last
                    : null,
                "imageSelf": _imageFile != null
                    ? base64Encode(File(_imageFile!.path).readAsBytesSync())
                    : null,
                'token': tokenCode
              };

              context.read<MemberPageProvider>().insertMember(data);
              Navigator.pop(context);
            }
          },
          child: CustomText(text: 'Add'),
        ),
      ],
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

  Widget CommitteesDataDropDownList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<CommitteeProviderPage>(
        builder: (context, committeeProvider, child) {
          if (committeeProvider.committeesData?.committees == null) {
            committeeProvider.getListOfCommitteesData();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              committeeProvider.committeesData!.committees!.isEmpty
                  ? buildEmptyMessage(
                      AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        style: Theme.of(context).textTheme.titleLarge,
                        elevation: 2,
                        iconEnabledColor: Colors.white,
                        items: committeeProvider.committeesData?.committees
                            ?.map((committee) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.center,
                            value: '${committee.id}',
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.1, color: Colors.black),
                              ),
                              child: Center(
                                  child: CustomText(
                                      text:
                                          committee.committeeName.toString())),
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedItem) {
                          var selectedCommittee = committeeProvider
                              .committeesData!.committees!
                              .firstWhere((committee) =>
                                  committee.id.toString() == selectedItem);
                          committeeProvider.setCombinedCollectionBoardCommittee(
                            selectedItem,
                            selectedCommittee.committeeName.toString(),
                          );
                        },
                        hint: CustomText(
                          text: committeeProvider.selectedCombined != null
                              ? committeeProvider.selectedCombined!
                              : 'Select an item please',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              if (committeeProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    committeeProvider.dropdownError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _imagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        setState(() => _imageFile = image);
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _imageFile == null
            ? const AssetImage("assets/images/profile.jpg") as ImageProvider
            : FileImage(File(_imageFile!.path)),
      ),
    );
  }
}
