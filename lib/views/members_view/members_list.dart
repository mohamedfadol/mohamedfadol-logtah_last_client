import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../core/domains/app_uri.dart';
import '../../models/member.dart';
import '../../providers/member_page_provider.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/loading_sniper.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:signature/signature.dart';

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
                : _MemberTable();
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

}

