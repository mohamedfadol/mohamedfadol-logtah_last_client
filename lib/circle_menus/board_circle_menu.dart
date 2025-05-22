import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/constant_name.dart';
import '../providers/icons_provider.dart';
import '../providers/menus_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/menu_button.dart';
import 'committ_circle_menu.dart';

class BoardCircleMenu extends StatefulWidget {

  @override
  State<BoardCircleMenu> createState() => _BoardCircleMenuState();
}
Map<String,String> iconsMap = {
  "Committees": "icons/committee_circle_menu_icons/committee_icon.png"
};
class _BoardCircleMenuState extends State<BoardCircleMenu> {

  Map<String,Widget> circleMenusMap = {
    "Committees": CommitteeCircleMenu(),
  };

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FlowMenuDelegate(),
      //you can change the buttons icons or name and name from here
      children: <List<dynamic>>[
        ["icons/board_circle_menu_icons/action_tracker_icon.png","Action Tracker",ConstantName.actionsTrackerList,"icons/iconsFroDarkMode/action_tracker_icon_dark.png"],//
        ["icons/board_circle_menu_icons/board_evaluation_icon.png","Board Evaluation",ConstantName.evaluationListViews,"icons/iconsFroDarkMode/board_evaluation_icon_dark.png"],//
        ["icons/board_circle_menu_icons/resolutions_icon.png","Resolutions",ConstantName.resolutionsListViews,"icons/iconsFroDarkMode/resolutions_icon_dark.png"],//
        // ["images/diligov_icon.png","Home","Home","images/iconsFroDarkMode/diligov_logo_darkmode.png"],// // howe
        ["icons/board_circle_menu_icons/annual_calendar_icon.png","Annual Calendar",ConstantName.calendarListView,"icons/iconsFroDarkMode/annual_calendar_icon_dark.png"],//
        ["icons/board_circle_menu_icons/meeting-light-mode.png","Board Meetings",ConstantName.boardMeetingsListView,"icons/board_circle_menu_icons/meeting-light-mode.png"],
        ["icons/board_circle_menu_icons/agenda_minutes_icon.png","Agenda & Minutes",ConstantName.minutesMeetingList,"icons/iconsFroDarkMode/agenda_minutes_icon_dark.png"],//
        ["icons/board_circle_menu_icons/disclosures_icon.png","Disclosures",ConstantName.disclosureListViews,"icons/iconsFroDarkMode/disclosures_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/reports_icon.png","Annual Report",ConstantName.committeesAnnualAuditReportListView,"icons/iconsFroDarkMode/annual_report_icon_dark.png"],//
        ["icons/board_circle_menu_icons/committee_icon.png","Committees","/Committees","icons/iconsFroDarkMode/committee_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/financials_icon.png","Financials",ConstantName.financialListViews,"icons/iconsFroDarkMode/financials_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/company_information_icon.png","Board Info",ConstantName.calendarListView,"icons/iconsFroDarkMode/company_information_icon_dark.png"],//
        ["icons/board_circle_menu_icons/power_attorney_icon.png","Power of Attorney",ConstantName.calendarListView,"icons/iconsFroDarkMode/power_attorney_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/kpi_icon.png","KPI",ConstantName.calendarListView,"icons/iconsFroDarkMode/kpi_icon_dark.png"],//
        //Center Icon
      ].map<Widget>(buildFAB).toList(),
    );
  }

  Widget buildFAB(List<dynamic> list) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: (){
        context.read<MenusProvider>().changeMenu(list[1]);
        context.read<MenusProvider>().changeIconName(list[1]);
        context.read<IconsProvider>().updateIcon(iconsMap[list[1]]!,list[3]);
      },
      child: SizedBox(
        height: 100,
        width: 100,
        child: GestureDetector(
          onTap: (){
            if(list[2] == "/Committees"){
              context.read<MenusProvider>().changeMenu("Committees");
              context.read<MenusProvider>().changeIconName("Committees");
              context.read<IconsProvider>().updateIcon(iconsMap["Committees"]!,list[3]);
            }else{
              Navigator.pushReplacementNamed(context, list[2]);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0,top: 10),
            // color: Colors.green,
            child: Column(
              children: [
                // index 0 => The icon or img name from line 22
                // index 1 => the name of the button
                Image.asset(
                  // context.watch<IconsProvider>().getIconPath
                  themeProvider.isDarkMode ? list[3] : list[0],height: 40.0,),
                  MenuButton(text: list[1],fontSize:10.0,fontWeight: FontWeight.bold),
              ],
            ),
          ),
        ),
      ),
    );
  }

}


class FlowMenuDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context){
    final size = context.size;
    final xStart = size.width/2 - 45;
    final yStart = size.height/2 - 30;
    final n = context.childCount;
    for(int i = 0 ; i < n ; i++) {
      const radius = 250;
      final theta = i * pi * 0.5/ (n - 2);
      //to change the circle size you can change the theta inside the Cos and Sin but its limited based on qunantity of buttons
      final x = xStart - (radius) * cos(3.4*theta);
      final y = yStart - (radius) * sin(3.4*theta);
      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(x,y,0),
      );
    }
  }
  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) => false;
}


