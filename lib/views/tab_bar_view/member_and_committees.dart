import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../NetworkHandler.dart';
import '../../models/user.dart';
import '../../widgets/date_format_text_form_field.dart';
import '../../widgets/stand_text_form_field.dart';

import '../boards_views/quick_access_board_list_view.dart';
import '../committee_views/quick_access_committee_list_view.dart';


import '../members_view/quick_access_member_list_view.dart';

class MemberAndCommittees extends StatefulWidget {
  const MemberAndCommittees({Key? key}) : super(key: key);
  static const routeName = '/MemberAndCommittees';
  @override
  State<MemberAndCommittees> createState() => _MemberAndCommitteesState();
}

class _MemberAndCommitteesState extends State<MemberAndCommittees> {



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 40.0,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            label: const Text('View List Of Board',style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.arrow_circle_right_outlined,color: Colors.red,size: 25.0),
            onPressed: () { Navigator.pushReplacementNamed(context, QuickAccessBoardListView.routeName); },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 5.0)
            ),
          ),

          // const SizedBox(height:30.0),
          ElevatedButton.icon(
            label: const Text('View List Of Committee',style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.arrow_circle_right_outlined,color: Colors.red,size: 25.0),
            onPressed: () { Navigator.pushReplacementNamed(context, QuickAccessCommitteeListView.routeName); },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 5.0)
            ),
          ),
          // const SizedBox(height:30.0),
          // Row(
          //   children: [
          //     ElevatedButton.icon(
          //       label: const Text('Members',style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold)),
          //       icon: const Icon(Icons.add,color: Colors.red,size: 40.0,),
          //       onPressed: () {Navigator.pushReplacementNamed(context, QuickAccessMemberListView.routeName);},
          //       style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.white,
          //           padding: EdgeInsets.symmetric(horizontal: 10.0,)
          //       ),
          //     ),
          //   ],
          // ),

        ],
      ),
    );
  }







}
