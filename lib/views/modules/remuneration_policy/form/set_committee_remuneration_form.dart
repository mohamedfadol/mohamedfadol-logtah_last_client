import 'dart:convert';

import 'package:diligov_members/models/committee_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../colors.dart';
import '../../../../models/user.dart';
import '../../../../providers/remuneration_provider_page.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custome_text.dart';
import '../../../committee_views/quick_access_committee_list_view.dart';
import 'package:flutter/services.dart';

import '../remuneration_policy_list_views.dart';


class SetCommitteeRemunerationForm extends StatefulWidget {
  final Committee committee;
  const SetCommitteeRemunerationForm({super.key, required this.committee});
  static const routeName = '/SetCommitteeRemunerationForm';

  @override
  State<SetCommitteeRemunerationForm> createState() => _SetCommitteeRemunerationFormState();
}

class _SetCommitteeRemunerationFormState extends State<SetCommitteeRemunerationForm> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(
              height: 15.0,
            ),
            _buildBoardTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardTable() {
    return Consumer<RemunerationProviderPage>(
        builder: (BuildContext context, provider, _){
          return Column(
            children: [
              // Table header
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Committee Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Membership Fees',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Attendance Fees',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Table rows (members)

              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(text: "${widget.committee.committeeName}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 100,
                          child: buildCustomTextFormField(
                            controller: provider.membershipFee,
                            hint: 'Enter Membership Fee',
                            validatorMessage: 'please enter membership fee',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 100,
                          child: buildCustomTextFormField(
                            controller: provider.attendanceFee,
                            hint: 'Enter Attendance Fee',
                            validatorMessage: 'please enter attendance fee',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(text: provider.formatNumber(provider.totalFee.toInt()),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          );
        }
    );
  }

  // Add this to your _SetRemunerationFormState class
  Widget _buildSaveButton() {
    return Consumer<RemunerationProviderPage>(
      builder: (context, provider, _) {
        return ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
            var user;
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
            var businessId = user.businessId;

            Map<String, dynamic> data = {
                'business_id': businessId,
                'committee_id': widget.committee.id,
                'quarter': provider.selectedQuarter,
                'membership_fee': double.tryParse(provider.membershipFee.text) ?? 0,
                'attendance_fee': double.tryParse(provider.attendanceFee.text) ?? 0,
              };
            bool success = await provider.saveRemunerationData(data);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Remuneration saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Optionally navigate back
              // Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error ?? 'Failed to save remuneration'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colour().buttonBackGroundRedColor,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: provider.isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            'Save Remuneration',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget buildCustomTextFormField({
    required TextEditingController controller,
    required String hint,
    required String validatorMessage,
    IconData? icon,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      maxLines: null,
      expands: true,
      controller: controller,
      validator: (val) => val != null && val.isEmpty ? validatorMessage : null,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        CurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        prefixIcon: icon != null ? Icon(icon) : null,
        // You can also add currency symbol as prefix
        prefixText: '₹ ', // Change to your currency symbol
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(
                vertical: 7.0, horizontal: 15.0),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
              color: Colour().buttonBackGroundRedColor,
            ),
            child: CustomText(
                text: 'Set Remuneration for ${widget.committee.committeeName}',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
            )
        ),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: 0.0, horizontal: 15.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
            color: Colour().buttonBackGroundRedColor,
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, QuickAccessCommitteeListView.routeName);
            },
            child: CustomText(
              text: 'Back',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: 0.0, horizontal: 15.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
            color: Colour().buttonBackGroundRedColor,
          ),
          child: ElevatedButton.icon(
            label: CustomText(text: 'Remuneration view'),
            icon: CustomIcon(icon: Icons.list_alt_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => RemunerationPolicyListViews()));
            },
            // style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          ),
        ),

        const SizedBox(
          width: 5.0,
        ),

        _buildSaveButton(),

      ],
    );
  }
}

// Custom formatter for currency input
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow digits and a single decimal point
    if (newValue.text.contains('.')) {
      // Check if more than one decimal point
      if (newValue.text.split('.').length > 2) {
        return oldValue;
      }

      // Limit to 2 decimal places
      String beforeDecimal = newValue.text.split('.')[0];
      String afterDecimal = newValue.text.split('.')[1];

      if (afterDecimal.length > 2) {
        return TextEditingValue(
          text: '$beforeDecimal.${afterDecimal.substring(0, 2)}',
          selection: TextSelection.collapsed(offset: beforeDecimal.length + 3),
        );
      }
    }

    // Check if it's a valid number
    if (double.tryParse(newValue.text) == null) {
      return oldValue;
    }

    return newValue;
  }
}

