import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../models/board_model.dart';
import '../../../models/committee_model.dart';
import '../../../models/data/years_data.dart';
import '../../../models/member.dart';
import '../../../models/remuneration.dart';
import '../../../providers/remuneration_provider_page.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custom_model_dropdown.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';

class RemunerationPolicyListViews extends StatefulWidget {
  const RemunerationPolicyListViews({super.key});
  static const routeName = '/RemunerationPolicyListViews';

  @override
  State<RemunerationPolicyListViews> createState() => _RemunerationPolicyListViewsState();
}

class _RemunerationPolicyListViewsState extends State<RemunerationPolicyListViews> {

  @override
  void initState() {
    super.initState();
    // Initialize data in the next frame to avoid build errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RemunerationProviderPage>(context, listen: false);
      provider.initializeData(); // Use the new centralized initialization method
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: Column(
          children: [
            // Header with filters
            buildFullTopFilter(),
          Consumer<RemunerationProviderPage>(
              builder: (BuildContext context, provider, _) {

                if (provider.isLoading) {
                  return buildLoadingSniper();
                }



                if (provider.remunerationsData?.remunerations == null) {
                  provider.getListOfRemunerationsByFilterDate(provider.yearSelected);
                  return buildLoadingSniper();
                }

                return Expanded(
                  child: SingleChildScrollView(
                    child: provider.remunerationsData!.remunerations!.isEmpty
                        ? buildEmptyMessage(
                        AppLocalizations.of(context)!.no_data_to_show)
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        for (var group in provider.groupedRemunerations.entries.toList()
                          ..sort((a, b) {
                            if (a.key.toLowerCase().contains('board') && b.key.toLowerCase().contains('committee')) return -1;
                            if (a.key.toLowerCase().contains('committee') && b.key.toLowerCase().contains('board')) return 1;
                            return 0;
                          }))
                          _buildGroupSection(
                            context: context,
                            groupName: group.key,
                            remunerations: group.value,
                          ),

                        SizedBox(height: 20),
                        // Totals and export section
                        _buildTotalsSection(provider),
                      ],
                    ),
                  ),
                );
              }
          )



          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection({
    required BuildContext context,
    required String groupName,
    required List<Remuneration> remunerations,
  }) {
    final isExpanded = remunerations.first.committee?.isExpanded ??
        remunerations.first.board?.isExpanded ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            final provider = Provider.of<RemunerationProviderPage>(context, listen: false);
            for (var rem in remunerations) {
              if (rem.committee != null) {
                rem.committee!.isExpanded = !isExpanded;
              } else if (rem.board != null) {
                rem.board!.isExpanded = !isExpanded;
              }
            }
            provider.notifyListeners();
          },
          child: Row(
            children: [
              Text(isExpanded ? '- ' : '+ ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(groupName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                for (var rem in remunerations) _buildMemberTable(rem),
                _buildFormulaInfo(),
              ],
            ),
          ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            for (var title in [
              'Member Name',
              'Annual Fee',
              'Per Meeting',
              'Meetings Total',
              'Attended',
              'Remuneration'
            ])
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberTable(Remuneration remuneration) {
    final members = remuneration.committee?.members ?? remuneration.board?.members ?? [];

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      children: [
        for (var member in members)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${member.memberFirstName ?? ''} ${member.memberLastName ?? ''}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(formatNumber(double.parse(remuneration.membershipFees ?? '0')), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(formatNumber(double.parse(remuneration.attendanceFees ?? '0')), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${remuneration.totalMeetings}", textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${remuneration.memberAttendance[member.memberId] ?? 0}", textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      formatNumber(remuneration.getTotalRemuneration(member.memberId ?? 0)),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "(${formatNumber(remuneration.getProRatedMembershipFee(member.memberId ?? 0))} + ${formatNumber(remuneration.getAttendanceFee(member.memberId ?? 0))})",
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFormulaInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Calculation Formula:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text("• Annual Fee ÷ Total Meetings × Attended Meetings", style: TextStyle(fontSize: 12)),
            Text("• + (Attendance Fee per Meeting × Attended Meetings)", style: TextStyle(fontSize: 12)),
          ],
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

  Widget buildFullTopFilter() {
    return Consumer<RemunerationProviderPage>(
        builder: (BuildContext context, provider, _) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.0, horizontal: 15.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                        color: Colour().buttonBackGroundRedColor,
                      ),
                      child: CustomText(
                          text: "Remuneration",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      )),
                  const SizedBox(
                    width: 5.0,
                  ),

                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: DropdownStringList(
                      boxDecoration: Colors.white,
                      hint: CustomText(
                          text: AppLocalizations.of(context)!.select_year),
                      selectedValue: provider.yearSelected,
                      dropdownItems: yearsData,
                      onChanged: (newValue) => provider.setYearSelected(newValue!),
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    width: 15.0,
                  ),

                  // Filter Options
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter options in rows
                        Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: [

                            // Committee filter
                            _buildCommitteeFilter(context, provider),

                            // Board filter
                            _buildBoardFilter(context, provider),

                            // Member filter
                            _buildMemberFilter(context, provider),

                            // Clear filters button
                            ElevatedButton.icon(
                              onPressed: () => provider.clearFilters(),
                              icon: CustomIcon(icon: Icons.clear),
                              label: CustomText(text: 'Clear Filters'),
                              style: ElevatedButton.styleFrom(
                                // backgroundColor: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildCommitteeFilter(BuildContext context, RemunerationProviderPage provider) {

      if (provider.dataOfCommittees?.committees == null) {
        provider.getCommittees();
        return buildLoadingSniper();
      }

      return provider.dataOfCommittees!.committees!.isEmpty
          ? buildEmptyMessage(
          AppLocalizations.of(context)!.no_data_to_show)
          : Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
      ),
      child: CustomModelDropdown<Committee>(
        value: provider.committees.any((c) => c.id == provider.committeeIdSelected)
            ? provider.committees.firstWhere((c) => c.id == provider.committeeIdSelected)
            : null,
        items: provider.committees,
        getValue: (c) => c.id,
        getLabel: (c) => c.committeeName ?? 'Unknown',
        onChanged: provider.setCommitteeIdSelected,
        hintText: 'Select Committee',
        allItemsLabel: 'All Committees',
      )
        ,
    );
  }

  Widget _buildBoardFilter(BuildContext context, RemunerationProviderPage provider) {
    if (provider.dataOfBoards?.boards == null) {
      provider.getBoards();
      return buildLoadingSniper();
    }

    return provider.dataOfBoards!.boards!.isEmpty
        ? buildEmptyMessage(
        AppLocalizations.of(context)!.no_data_to_show)
        : Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
      ),
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: CustomModelDropdown<Board>(
          value: provider.boards.any((c) => c.boarId == provider.boardIdSelected)
              ? provider.boards.firstWhere((c) => c.boarId == provider.boardIdSelected)
              : null,
          items: provider.boards,
          getValue: (b) => b.boarId,
          getLabel: (b) => b.boardName ?? 'Unknown Board',
          onChanged: provider.setBoardIdSelected,
          hintText: 'Select Board',
          allItemsLabel: 'All Boards',
        ),
      ),
    );
  }


  Widget _buildMemberFilter(BuildContext context, RemunerationProviderPage provider) {
    if (provider.dataOfMembers?.members == null) {
      provider.getMembers();
      return buildLoadingSniper();
    }

    return provider.dataOfMembers!.members!.isEmpty
        ? buildEmptyMessage(
        AppLocalizations.of(context)!.no_data_to_show)
        : Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
      ),
      child: CustomModelDropdown<Member>(
        value: provider.members.any((m) => m.memberId == provider.memberIdSelected)
            ? provider.members.firstWhere((m) => m.memberId == provider.memberIdSelected)
            : null,
        items: provider.members,
        getValue: (m) => m.memberId,
        getLabel: (m) => m.fullName ?? 'Unknown Member',
        onChanged: provider.setMemberIdSelected,
        hintText: 'Select Member',
        allItemsLabel: 'All Members',
      )

    );
  }

  Widget _totalCell(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _totalValueCell(double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Text(
          formatNumber(value),
          style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTotalsSection(RemunerationProviderPage provider) {
    double totalMembershipFees = 0;
    double totalAttendanceFees = 0;

    if (provider.remunerationsData?.remunerations != null) {
      for (var remuneration in provider.remunerationsData!.remunerations!) {
        for (var member in remuneration.members) {
          int memberId = member.memberId ?? 0;
          double proratedFee = remuneration.getProRatedMembershipFee(memberId);
          double attendanceFee = remuneration.getAttendanceFee(memberId);

          totalMembershipFees += proratedFee;
          totalAttendanceFees += attendanceFee;
        }
      }
    }

    double grandTotal = totalMembershipFees + totalAttendanceFees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 2, color: Colors.grey.shade400),
        SizedBox(height: 10),
        Table(
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                Container(),
                _totalCell('Total Membership Fees'),
                _totalCell('Total Attendance Fees'),
                _totalCell('Total Remuneration'),
              ],
            ),
            TableRow(
              children: [
                Container(),
                _totalValueCell(totalMembershipFees),
                _totalValueCell(totalAttendanceFees),
                _totalValueCell(grandTotal, bold: true),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildExportButton(title: 'EXPORT'),
            SizedBox(width: 20),
            _buildExportButton(title: 'EXPORT ALL XIs'),
          ],
        ),
      ],
    );
  }

// Helper function to format number with commas
  String formatNumber(double number) {
    if (number == 0) return '0';

    // Format with commas as thousands separator and 2 decimal places
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(number);
  }

  Widget _buildExportButton({required String title}) {
    return ElevatedButton(
      onPressed: () {
        // Implement export functionality
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}


