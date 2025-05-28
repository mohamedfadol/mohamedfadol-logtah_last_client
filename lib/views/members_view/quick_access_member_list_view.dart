
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../core/domains/app_uri.dart';
import '../../models/member.dart';
import '../../providers/member_page_provider.dart';
import '../../roles/roles_list_view.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custome_text.dart';

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

            return _MemberTable();
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
    return ElevatedButton.icon(
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
    );
  }






}

