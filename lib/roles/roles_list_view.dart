import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member.dart';
import '../models/roles_model.dart';
import '../providers/member_page_provider.dart';
import '../widgets/custom_message.dart';
import '../widgets/custome_text.dart';
import '../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class RolesListView extends StatelessWidget {
  const RolesListView({super.key});
  static const routeName = '/RolesListView';

  Widget buildEmptyMessage(String message) => CustomMessage(text: message);
  Widget buildLoadingSniper() => const LoadingSniper();

  Widget CombinedCollectionBoardCommitteeDataDropDownList() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<MemberPageProvider>(
        builder: (context, provider, child) {
          final data = provider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData;

          if (data == null) {
            provider.getListOfMembersDependingOnCombinedCollectionBoardAndCommittee();
            return buildLoadingSniper();
          }

          if (data.isEmpty) {
            return buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,
                  items: data.map((item) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: '${item.type}-${item.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.black),
                        ),
                        child: Center(child: CustomText(text: item.name.toString())),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    provider.selectCombinedCollectionBoardCommittee(selectedItem!, context);
                  },
                  hint: CustomText(
                    text: provider.selectedCombined ?? 'Select an item please',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (provider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomText(
                    text: provider.dropdownError!,
                    fontSize: 12,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<DataCell> _buildRoleCheckboxes(
      int groupId,
      String groupType,
      List<Member>? members,
      List<RoleModel> allRoles,
      MemberPageProvider provider,
      BuildContext context,
      ) {
    return allRoles.map((role) {
      bool allHaveRole = members?.isNotEmpty == true &&
          members!.every((m) => m.roles?.any((r) => r.roleId == role.roleId) ?? false);

      bool someHaveRole = members?.any((m) => m.roles?.any((r) => r.roleId == role.roleId) ?? false) ?? false;

      return DataCell(
        provider.isLoadingForGroupRole(groupId.toString(), role.roleId.toString())
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Checkbox(
          value: allHaveRole ? true : (someHaveRole ? null : false),
          tristate: true,
          onChanged: (bool? value) async {
            provider.setLoadingForGroupRole(groupId.toString(), role.roleId.toString(), true);
            try {
              for (var member in members ?? []) {
                final hasRole = member.roles?.any((r) => r.roleId == role.roleId) ?? false;
                if (value == true && !hasRole) {
                  await provider.assignRoleToGroup(groupId, role.roleId!, groupType, context);
                } else if (value == false && hasRole) {
                  await provider.removeRoleFromGroup(groupId, role.roleId!, groupType, context);
                }
              }
            } finally {
              provider.setLoadingForGroupRole(groupId.toString(), role.roleId.toString(), false);
            }
          },
        ),
      );
    }).toList();
  }

  bool hasValidRolesAndMembers(MemberPageProvider provider) =>
      provider.dataOfMembers?.members?.isNotEmpty == true &&
          provider.dataOfRoles?.roles?.isNotEmpty == true;

  bool hasValidGroupsAndRoles(MemberPageProvider provider) =>
      provider.dataOfGroups?.groups?.isNotEmpty == true &&
          provider.dataOfRoles?.roles?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    void _showSnackbar(String message, Color color) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }

    return Scaffold(
      body: Consumer<MemberPageProvider>(
        builder: (context, memP, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => memP.setCurrentIndex(0, context),
                    child: CustomText(text: 'Members Permissions'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => memP.setCurrentIndex(1, context),
                    child: CustomText(text: 'Group Permissions'),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: IndexedStack(
                    index: memP.currentIndex,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CombinedCollectionBoardCommitteeDataDropDownList(),
                            const SizedBox(height: 5),
                            Consumer<MemberPageProvider>(
                              builder: (context, provider, child) {
                                if (!provider.hasFetchedInitialData) {
                                  provider.fetchInitialData(context);
                                  return buildLoadingSniper();
                                }

// Show empty message if no members at all
                                if (provider.dataOfMembers?.members?.isEmpty ?? true) {
                                  return buildEmptyMessage("No members to show.");
                                }

// Show UI even if roles are null or empty
                                final members = provider.dataOfMembers!.members!;
                                final roles = provider.dataOfRoles?.roles ?? [];

                                if (roles.isEmpty) {
                                  return buildEmptyMessage("No roles defined. Please add roles first.");
                                }

// Proceed with DataTable if both are present
                                return _buildDataTable(context, members, roles, provider, _showSnackbar);

                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Consumer<MemberPageProvider>(
                          builder: (context, provider, child) {
                            if (!hasValidGroupsAndRoles(provider)) {
                              provider.getDataOfGroups();
                              return buildEmptyMessage("No groups or roles to show.");
                            }

                            final groups = provider.dataOfGroups!.groups!;
                            final roles = provider.dataOfRoles!.roles!;

                            return _buildGroupPermissionsTable(groups, roles, provider, context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, List<Member> members, List<RoleModel> allRoles,
      MemberPageProvider provider, void Function(String, Color) _showSnackbar) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        int totalColumns = allRoles.length + 1;
        double columnWidth = totalWidth / totalColumns;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            child: DataTable(
              columnSpacing: 0,
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
              columns: [
                DataColumn(label: _columnHeader("Member Name", columnWidth)),
                ...allRoles.map((role) => DataColumn(label: _columnHeader(role.roleName!, columnWidth))),
              ],
              rows: members.map((member) {
                final assignedRoleIds = member.roles?.map((r) => r.roleId).toList() ?? [];

                bool isAllChecked = allRoles.where((r) => r.roleName != "All").every((r) => assignedRoleIds.contains(r.roleId));

                return DataRow(
                  cells: [
                    DataCell(SizedBox(width: columnWidth, child: Center(child: CustomText(text: member.memberFirstName!)))),
                    ...allRoles.map((role) {
                      bool isAssigned = assignedRoleIds.contains(role.roleId);
                      return DataCell(SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: provider.isLoadingForMemberRole(member.memberId!.toString(), role.roleId!.toString())
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Checkbox(
                            value: role.roleName == "All" ? isAllChecked : isAssigned,
                            onChanged: (bool? value) async {
                              provider.setLoadingForMemberRole(member.memberId!.toString(), role.roleId!.toString(), true);
                              try {
                                if (role.roleName == "All") {
                                  for (var r in allRoles.where((r) => r.roleName != "All")) {
                                    if (value == true && !assignedRoleIds.contains(r.roleId)) {
                                      await provider.assignRoleToMember(member.memberId!, r.roleId!, context);
                                    } else if (value == false) {
                                      await provider.removeRoleFromMember(member.memberId!, r.roleId!, context);
                                    }
                                  }
                                } else {
                                  if (value == true) {
                                    await provider.assignRoleToMember(member.memberId!, role.roleId!, context);
                                  } else {
                                    await provider.removeRoleFromMember(member.memberId!, role.roleId!, context);
                                  }
                                }
                                _showSnackbar('Role updated.', Colors.green);
                              } catch (_) {
                                _showSnackbar('Failed to update role.', Colors.red);
                              } finally {
                                provider.setLoadingForMemberRole(member.memberId!.toString(), role.roleId!.toString(), false);
                              }
                            },
                          ),
                        ),
                      ));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupPermissionsTable(List groups, List<RoleModel> roles, MemberPageProvider provider, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double columnWidth = totalWidth / (roles.length + 1);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
            columns: [
              DataColumn(label: CustomText(text: "Board/Committee")),
              ...roles.map((role) => DataColumn(label: CustomText(text: role.roleName!))),
            ],
            rows: groups.expand<DataRow>((group) {
              return [
                DataRow(
                  cells: [
                    DataCell(CustomText(text: group.boardName ?? "Unknown Board")),
                    ..._buildRoleCheckboxes(group.id!, "board", group.members, roles, provider, context),
                  ],
                ),
                ...(group.committees?.map((committee) {
                  return DataRow(
                    cells: [
                      DataCell(Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: CustomText(text: "→ ${committee.committeeName}"),
                      )),
                      ..._buildRoleCheckboxes(committee.id!, "committee", committee.members, roles, provider, context),
                    ],
                  );
                }).toList() ??
                    []),
              ];
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _columnHeader(String text, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: CustomText(
          text: text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
