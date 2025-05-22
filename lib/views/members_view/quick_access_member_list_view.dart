import 'dart:io';
import 'dart:convert';
import 'package:diligov_members/views/members_view/edit_member_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/domains/app_uri.dart';
import '../../models/member.dart';
import '../../permissions/permissions_list_view.dart';
import '../../providers/member_page_provider.dart';
import '../../roles/roles_list_view.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/stand_text_form_field.dart';

class QuickAccessMemberListView extends StatelessWidget {
  const QuickAccessMemberListView({Key? key}) : super(key: key);

  static const routeName = '/QuickAccessMemberListView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Consumer<MemberPageProvider>(
          builder: (context, provider, child) {


            if (provider.dataOfMembers?.members == null) {
              context.read<MemberPageProvider>().getListOfMember(context);
              context.read<MemberPageProvider>().fetchDropdownData();
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
                  )
              );
            }

            return Column(
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          showBottomBorder: true,
          dividerThickness: 0.3,
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).primaryColor),
          columns:   [
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
                    ? NetworkImage('${AppUri.profileImages}/${member.businessId}/${member.memberProfileImage!}')
                    : const AssetImage("assets/images/profile.jpg")
                as ImageProvider,
                radius: 20,
              )),
              DataCell(CustomText(text: member.memberFirstName ?? "-")),
              DataCell(CustomText(text: member.memberLastName ?? "-")),
              DataCell(CustomText(text: member.memberEmail ?? "-")),
              DataCell(CustomText(text: member.position?.positionName ?? "-")),
              DataCell(_ActionsRow(member: member)),
            ]);
          }).toList(),
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
          icon: CustomIcon(icon: Icons.pending_sharp,color: Colors.white),
          label: CustomText(text: 'Edit'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 10.0)
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton.icon(
          onPressed: () => _showDeleteConfirmation(context, member),
          icon: CustomIcon(icon: Icons.restore_from_trash_outlined,color: Colors.white),
          label: CustomText(text: 'Delete'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 10.0)
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton.icon(
          onPressed: ()  {
            Navigator.of(context).push(
            MaterialPageRoute(
            builder: (context) => PermissionsListView(member: member),
            ),
            );
          },
          icon: CustomIcon(icon: Icons.local_attraction_rounded,color: Colors.white),
          label: CustomText(text: 'Permissions'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 10.0)
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton.icon(
          label: CustomText(text: 'Rest Passwordq'),
          icon: CustomIcon(icon:Icons.lock_open_outlined,color: Colors.white),
          onPressed: () {
            print('Rest Password');

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RolesListView(),
              ),
            );
            },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: 10.0)
          ),
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
          content: CustomText(text:
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
                Map<String, dynamic> updatedData = {"member_id": member.memberId,};
                // Call the delete method in the provider
                context.read<MemberPageProvider>().deleteMember(member, updatedData);

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
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(member: member),
    );
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
        label: CustomText(text: 'Add User'),
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
                  SizedBox(height: 15,),
                // Input fields
                StandTextFormField(
                  labelText: "First Name",
                  controllerField: _firstNameController,
                  valid: (val) => val != null && val.isNotEmpty
                      ? null
                      : 'Please enter a valid first name',
                ),
                StandTextFormField(
                  labelText: "Last Name",
                  controllerField: _lastNameController,
                  valid: (val) => val != null && val.isNotEmpty
                      ? null
                      : 'Please enter a valid last name',
                ),
                StandTextFormField(
                  labelText: "Email",
                  controllerField: _emailController,
                  valid: (val) => val != null && val.contains('@')
                      ? null
                      : 'Please enter a valid email',
                ),

                // Dropdown: Position
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  hint: CustomText(text:"Select Position"),
                  items: provider.positions
                      .map((pos) => DropdownMenuItem<String>(
                    value: pos['id'].toString(),
                    child: CustomText(text:pos['position_name']),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPosition = value),
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

                const SizedBox(height: 10),

                // Multi-select: Committees
                MultiSelectDialogField(
                  title: CustomText(text: "Committees"),
                  buttonText: const Text("Select Committees"),
                  items: provider.committees
                      .map((committee) => MultiSelectItem(
                    committee['id'],
                    committee['committee_name'],
                  ))
                      .toList(),
                  initialValue: _selectedCommittees,
                  onConfirm: (values) {
                    setState(() => _selectedCommittees = values);
                  },
                  chipDisplay: MultiSelectChipDisplay(
                    items: _selectedCommittees
                        .map((id) => MultiSelectItem(
                      id,
                      provider.committees
                          .firstWhere((c) => c['id'] == id)['committee_name'],
                    ))
                        .toList(),
                    onTap: (value) {
                      setState(() {
                        _selectedCommittees.remove(value);
                      });
                    },
                  ),
                    confirmText: Text('confirm'),
                  cancelText: Text('cancel'),
                ),

              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: CustomText(text:'Cancel'),
        ),
        ElevatedButton(
          onPressed: () async{
            final tokenCode = await FirebaseMessaging.instance.getToken();
           var _business_id = provider.user.businessId.toString();
            if (_formKey.currentState!.validate()) {

              final data = {
                "member_first_name": _firstNameController.text,
                "member_last_name": _lastNameController.text,
                "member_email": _emailController.text,
                "position_id": _selectedPosition,
                "board_id": _selectedBoard,
                "business_id": _business_id,
                "committee_id": _selectedCommittees,
                "imageName": _imageFile!.path.split("/").last != null ? _imageFile!.path.split("/").last : null,
                "imageSelf": _imageFile != null ? base64Encode(File(_imageFile!.path).readAsBytesSync()) : null,
                'token': tokenCode
              };

              context.read<MemberPageProvider>().insertMember(data);
              Navigator.pop(context);
            }
          },
          child: CustomText(text:'Add'),
        ),
      ],
    );
  }

  Widget _imagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
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
