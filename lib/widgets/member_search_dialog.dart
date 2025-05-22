import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../models/member.dart';

class MemberSearchDialog extends StatelessWidget {
  final Future<List<Member>> fetchMembersFuture;
  final String dialogTitle;
  final Function(List<Member>) onConfirm;
  final Function() onCancel;

  const MemberSearchDialog({
    Key? key,
    required this.fetchMembersFuture,
    required this.dialogTitle,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: fetchMembersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while fetching data
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If no members are available
          return Center(child: Text('No data to show'));
        }

        List<Member> members = snapshot.data!;

        return AlertDialog(
          backgroundColor: Colors.white,
          title: CustomText(
            text: dialogTitle,
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: SizedBox(
            width: 600,
            height: 150,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: MultiSelectDialogField<Member>(
                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                confirmText: const Text(
                  'Add Members',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                cancelText: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                separateSelectedItems: true,
                buttonIcon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),
                title: CustomText(text: 'Members List'),
                buttonText: const Text(
                  'You Could Select Multiple Members',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                items: members.map((member) => MultiSelectItem<Member>(member,'${member.memberFirstName!} ${member.position!.positionName!}',
                ))
                    .toList(),
                searchable: true,
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                onConfirm: onConfirm,
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    // Handle chip tap logic here (e.g. remove the selected member)
                  },
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onCancel();
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: 'Cancel',
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () {
                // Confirm the selected members
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: 'Confirm',
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        );
      },
    );
  }
}
