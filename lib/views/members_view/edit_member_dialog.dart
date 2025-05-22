import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../core/domains/app_uri.dart';
import '../../models/committee_model.dart';
import '../../models/member.dart';
import '../../providers/committee_provider_page.dart';
import '../../providers/member_page_provider.dart';
import '../../providers/positions_provider_page.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/loading_sniper.dart';

class EditMemberDialog extends StatefulWidget {
  final Member member;

  const EditMemberDialog({required this.member});

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  String? _selectedPosition;
  String? _selectedBoard;

  List<dynamic> selectedPositions = [];
  List<dynamic> selectedCommittees = [];
  XFile? _newImageFile;
  String? _imageFileName;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.member.memberFirstName);
    _lastNameController = TextEditingController(text: widget.member.memberLastName);
    _emailController = TextEditingController(text: widget.member.memberEmail);
    _selectedPosition = widget.member.position?.positionId.toString();
    _selectedBoard = null;
    // _selectedCommittees = widget.member.committees ?? [];
    _imageFileName = widget.member.memberProfileImage;
    selectedPositions = widget.member.positions?.map((p) => p.positionId).toList() ?? [];
    selectedCommittees = widget.member.committees?.map((c) => c.id).toList() ?? [];
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
    final provider = context.watch<MemberPageProvider>();
    bool _isAdmin = false; // New variable for admin checkbox

    return AlertDialog(
      title: CustomText(text: "Edit Member"),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _imagePicker(context),
                SizedBox(height: 15,),
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: "First Name"),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Please enter a valid first name',
                ),
                SizedBox(height: 15,),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name"),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Please enter a valid last name',
                ),
                SizedBox(height: 15,),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Please enter a valid email',
                ),
                SizedBox(height: 15,),

                // Dropdown: Position
                Consumer<PositionsProviderPage>(
                  builder: (context, positionProvider, child) {
                    if (positionProvider.dataOfPositions?.positions == null) {
                      positionProvider.getDataOfPositions();
                      return buildLoadingSniper();
                    }

                    return positionProvider.dataOfPositions!.positions!.isEmpty
                        ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
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
                        items:  positionProvider.selectedPositionsIds
                            .map((id) => MultiSelectItem(
                          id,
                          positionProvider.dataOfPositions!.positions!
                              .firstWhere((p) => p.positionId == id)
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


                SizedBox(height: 15,),

                // Dropdown: Board
                DropdownButtonFormField<String>(
                  value: _selectedBoard,
                  hint: CustomText(text: "Select Board"),
                  items: provider.boards.map((board) {
                    return DropdownMenuItem(
                      value: board['id'].toString(),
                      child: CustomText(text: board['board_name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBoard = value),
                ),

                SizedBox(height: 15,),

                // Multi-select: Committees
                Consumer<CommitteeProviderPage> (
                    builder: (context, committeeProvider, child) {

                      if (committeeProvider.committeesData ?.committees == null) {
                        committeeProvider.getListOfCommitteesData();
                        return buildLoadingSniper();
                      }

                      return committeeProvider.committeesData!
                          .committees!.isEmpty
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
                          items:  committeeProvider.selectedCommitteesIds
                              .map((id) => MultiSelectItem(
                            id,
                            committeeProvider.committeesData!.committees!
                                .firstWhere((p) => p.id == id)
                                .committeeName
                                .toString(),
                          ))
                              .toList() ?? [],
                          onTap: (value) {
                            committeeProvider.removeSelectedCommittees(value);
                          },
                        ),

                        confirmText: Text('confirm'),
                        cancelText: Text('cancel'),
                      );
                    }
                ),

                SizedBox(height: 15,),

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
          onPressed: () async{
            var selectedPositionIds = Provider.of<PositionsProviderPage>(context, listen: false).selectedPositionsIds;
            var selectedCommitteesIds = Provider.of<CommitteeProviderPage>(context, listen: false).selectedCommitteesIds;
            if (_formKey.currentState!.validate()) {
              final tokenCode = await FirebaseMessaging.instance.getToken();
              Map<String, dynamic> updatedData = {
                "id": widget.member.memberId,
                "business_id": widget.member.businessId,
                "member_first_name": _firstNameController.text,
                "member_last_name": _lastNameController.text,
                "member_email": _emailController.text,
                "position_ids": selectedPositionIds,
                "board_id": _selectedBoard,
                "committee_id": selectedCommitteesIds,
                "is_admin": _isAdmin,
                "imageName": _imageFileName,
                "imageSelf": _newImageFile != null ? base64Encode(File(_newImageFile!.path).readAsBytesSync()) : null,
                'token': tokenCode
              };
              context.read<MemberPageProvider>().updateMember(widget.member,updatedData);
              _showSnackbar('update in processing ...', Colors.green, Duration(seconds: 5));
              Navigator.pop(context);
            }
          },
          child: CustomText(text: 'Save'),
        ),
      ],
    );
  }

  void _showSnackbar(String message, Color color, Duration duration) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing Snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: color, duration: duration),
    );
  }

  // Image Picker
  Widget _imagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _newImageFile = image;
            _imageFileName = image.name; // Update the image file name
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _newImageFile != null
            ? FileImage(File(_newImageFile!.path))
            : widget.member.memberProfileImage != null
            ? NetworkImage('${AppUri.profileImages}/${widget.member.businessId}/${widget.member.memberProfileImage!}') as ImageProvider
            : const AssetImage('assets/images/profile.jpg'),
      ),
    );
  }
}
