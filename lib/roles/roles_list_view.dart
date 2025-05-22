import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member.dart';
import '../models/roles_model.dart';
import '../providers/meeting_page_provider.dart';
import '../providers/member_page_provider.dart';
import '../widgets/custom_message.dart';
import '../widgets/custome_text.dart';
import '../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class RolesListView extends StatelessWidget {
  const RolesListView({super.key});
  static const routeName = '/RolesListView';

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }


  Widget CombinedCollectionBoardCommitteeDataDropDownList(){
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<MemberPageProvider>(
        builder: (context, combinedDataProvider, child) {
          if (combinedDataProvider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData == null) {
            combinedDataProvider.getListOfMembersDependingOnCombinedCollectionBoardAndCommittee();
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
                    combinedDataProvider.selectCombinedCollectionBoardCommittee(selectedItem!, context);
                  },
                  hint: CustomText(
                    text: combinedDataProvider.selectedCombined != null
                        ? combinedDataProvider.selectedCombined!
                        : 'Select an item pleace',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (combinedDataProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomText(text:
                  combinedDataProvider.dropdownError!,
                    fontSize: 12 ,
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
    void _showSnackbar(String message, Color color) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }

    /// ✅ Builds checkboxes based on whether members in a Board/Committee have roles
    List<DataCell> _buildRoleCheckboxes(
        int groupId,
        String groupType,
        List<Member>? members,
        List<RoleModel> allRoles,
        MemberPageProvider provider,
        BuildContext context,
        ) {
      // ✅ Get all role assignments for this group
      List<Object?> allMemberRoles = members?.expand((m) => m.roles?.map((r) => r.roleId) ?? []).toList() ?? [];

      return allRoles.map<DataCell>((role) {
        // ✅ Check if ALL members have this role
        bool allHaveRole = members != null &&
            members.isNotEmpty &&
            members.every((m) => m.roles?.any((r) => r.roleId == role.roleId) ?? false);

        // ✅ Check if AT LEAST ONE member has this role (partial selection)
        bool someHaveRole = members != null &&
            members.isNotEmpty &&
            members.any((m) => m.roles?.any((r) => r.roleId == role.roleId) ?? false);

        return DataCell( provider.isLoadingForGroupRole(groupId.toString(), role.roleId!.toString())
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            :
          Checkbox(
            value: allHaveRole ? true : (someHaveRole ? null : false), // Null for partial selection
            tristate: true, // Allows the "some checked" state
            onChanged: (bool? value) async {
              provider.setLoadingForGroupRole(groupId.toString(), role.roleId!.toString(), true);

              try {
                if (value == true) {
                  // Assign role to all members
                  for (var member in members ?? []) {
                    if (!(member.roles?.any((r) => r.roleId == role.roleId) ?? false)) {
                      await provider.assignRoleToGroup(groupId!, role.roleId!,groupType , context);
                    }
                  }
                } else {
                  // Remove role from all members
                  for (var member in members ?? []) {
                    if (member.roles?.any((r) => r.roleId == role.roleId) ?? false) {
                      await provider.removeRoleFromGroup(groupId!, role.roleId!,groupType , context);
                    }
                  }
                }
              } finally {
                provider.setLoadingForGroupRole(groupId.toString(), role.roleId!.toString(), false);
              }
            },
          ),
        );
      }).toList();
    }

    return Scaffold(
      body: Consumer<MemberPageProvider>(
          builder: (BuildContext context, memP, child){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        memP.setCurrentIndex(0, context);
                      },
                      child: CustomText(text: 'Members Permissions'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        memP.setCurrentIndex(1, context);
                      },
                      child: CustomText(text: 'Group Permissions'),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: IndexedStack(
                    index: memP.currentIndex,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CombinedCollectionBoardCommitteeDataDropDownList(),
                            SizedBox(height: 5),
                            Consumer<MemberPageProvider>(
                              builder: (context, provider, child) {
                                if (provider.dataOfMembers?.members == null || provider.dataOfRoles?.roles == null) {
                                  provider.fetchInitialData(context);
                                  return buildLoadingSniper();
                                }
                  
                                if (provider.dataOfMembers!.members!.isEmpty) {
                                  return buildEmptyMessage("No members to show");
                                }
                  
                                final members = provider.dataOfMembers!.members!;
                                final allRoles = provider.dataOfRoles!.roles!;
                  
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    double totalWidth = constraints.maxWidth;
                                    int totalColumns = allRoles.length + 1; // Member Name + Roles
                                    double columnWidth = totalWidth / totalColumns;
                  
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: totalWidth,
                                        child: DataTable(
                                          columnSpacing: 0, // No default spacing, we handle manually
                                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                                          columns: [
                                            DataColumn(
                                              label: SizedBox(
                                                width: columnWidth,
                                                child: Center(
                                                  child: CustomText(
                                                    text: "Member Name",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ...allRoles.map(
                                                  (role) => DataColumn(
                                                label: SizedBox(
                                                  width: columnWidth,
                                                  child: Center(
                                                    child: CustomText(
                                                      text: role.roleName!,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: members.map((member) {
                                            final assignedRoleIds = member.roles?.map((role) => role.roleId).toList();
                  
                                            // Determine if "All" should be checked
                                            bool isAllChecked = allRoles
                                                .where((r) => r.roleName != "All")
                                                .every((r) => assignedRoleIds?.contains(r.roleId) ?? false);
                  
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: columnWidth,
                                                    child: Center(
                                                      child: CustomText(
                                                        text: member.memberFirstName!,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                  
                                                // Role Checkboxes
                                                ...allRoles.map((role) {
                                                  final isAssigned = assignedRoleIds?.contains(role.roleId);
                  
                                                  return DataCell(
                                                    SizedBox(
                                                      width: columnWidth,
                                                      child: Center(
                                                        child: provider.isLoadingForMemberRole(
                                                            member.memberId!.toString(), role.roleId!.toString())
                                                            ? const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(strokeWidth: 2),
                                                        )
                                                            : Checkbox(
                                                          value: role.roleName == "All" ? isAllChecked : isAssigned,
                                                          onChanged: (bool? value) async {
                                                            print("role id is ${role.roleId!.toString()} and role name is ${role.roleName!.toString()}");
                                                            provider.setLoadingForMemberRole(member.memberId!.toString(),role.roleId!.toString(),true);
                  
                                                            try {
                                                              if (role.roleName == "All") {
                                                                if (value == true) {
                                                                  // Assign all roles when "All" is checked
                                                                  for (var r in allRoles.where((r) => r.roleName != "All")) {
                                                                    if (!assignedRoleIds!.contains(r.roleId)) {
                                                                      await provider.assignRoleToMember(member.memberId!, r.roleId!, context);
                                                                    }
                                                                  }
                                                                  _showSnackbar('All roles assigned.', Colors.green);
                                                                } else {
                                                                  // Remove all roles when "All" is unchecked
                                                                  for (var r in allRoles.where((r) => r.roleName != "All")) {
                                                                    await provider.removeRoleFromMember(member.memberId!, r.roleId!, context);
                                                                  }
                                                                  _showSnackbar('All roles removed.', Colors.green);
                                                                }
                                                              } else {
                                                                // Assign/remove individual roles
                                                                if (value == true) {
                                                                  await provider.assignRoleToMember(member.memberId!, role.roleId!, context);
                                                                  _showSnackbar('Role assigned.', Colors.green);
                                                                } else {
                                                                  await provider.removeRoleFromMember(member.memberId!, role.roleId!, context);
                                                                  _showSnackbar('Role removed.', Colors.green);
                                                                }
                                                              }
                                                            } catch (error) {
                                                              _showSnackbar('Failed to update role. Please try again.', Colors.red);
                                                            } finally {
                                                              provider.setLoadingForMemberRole(member.memberId!.toString(),role.roleId!.toString(),false);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Consumer<MemberPageProvider>(
                              builder: (context, provider, child) {
                  
                  
                                if (provider.dataOfGroups?.groups == null || provider.dataOfGroups!.groups!.isEmpty) {
                                  provider.getDataOfGroups();
                                  return buildEmptyMessage("No groups to show.");
                                }
                  
                                final groups = provider.dataOfGroups!.groups!;
                                final allRoles = provider.dataOfRoles!.roles!;
                  
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    double totalWidth = constraints.maxWidth;
                                    int totalColumns = allRoles.length + 1; // Member Name + Roles
                                    double columnWidth = totalWidth / totalColumns;
                  
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: totalWidth,
                                        child: DataTable(
                                          columnSpacing: 20,
                                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                                          columns: [
                                              DataColumn(label: CustomText(text: "Board/Committee")),
                                            ...allRoles.map((role) => DataColumn(label: CustomText(text: role.roleName!))),
                                          ],
                                          rows: groups.expand<DataRow>((group) {
                                            return [
                                              // ✅ Board Row
                                              DataRow(cells: [
                                                DataCell(CustomText(text: group.boardName ?? "Unknown Board")),
                                                ..._buildRoleCheckboxes(group.id!, "board" , group.members, allRoles, provider, context),
                                              ]),
                  
                                              // ✅ Committees Inside This Board
                                              ...group.committees?.map<DataRow>((committee) {
                                                return DataRow(cells: [
                                                  DataCell(Padding(
                                                    padding: const EdgeInsets.only(left: 20), // Indent for committees
                                                    child: CustomText(text: "→ ${committee.committeeName}"),
                                                  )),
                                                  ..._buildRoleCheckboxes(committee.id!, "committee", committee.members, allRoles, provider, context),
                                                ]);
                                              })?.toList() ?? [],
                                            ];
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
      ),
    );


  }

}
