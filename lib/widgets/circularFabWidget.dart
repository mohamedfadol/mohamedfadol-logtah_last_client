
import 'dart:math';
import 'package:diligov_members/providers/menus_provider.dart';
import 'package:diligov_members/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:diligov_members/circle_menus/board_circle_menu.dart';
import 'package:diligov_members/providers/icons_provider.dart';
import 'package:provider/provider.dart';
import '../core/constants/constant_name.dart';
import '../providers/theme_provider.dart';

class CircularFabWidget extends StatefulWidget {

  @override
  State<CircularFabWidget> createState() => _CircularFabWidgetState();
}

  Map<String,String> iconsMap = {
  "Board": "icons/board_circle_menu_icons/board_main_icon.png"
  };

class _CircularFabWidgetState extends State<CircularFabWidget> {

  Map<String,Widget> circleMenusMap = {
    "Board": BoardCircleMenu(),
  };

  @override
  Widget build(BuildContext context) {

    var currentWidget = context.watch<MenusProvider>().getCurrentMenu;

    return currentWidget != null ? context.watch<MenusProvider>().getCurrentMenu : Flow(
      delegate: FlowMenuDelegate(),
      //you can change the buttons icons and name from here
      children: <List<dynamic>>[
        ["icons/homepage_circle_menu_icons/risk_icon.png","Risk","/Risk","icons/homepage_circle_menu_icons/risk_icon.png"],
        ["icons/homepage_circle_menu_icons/shareholders_icon.png","Shareholders","/Shareholders","icons/homepage_circle_menu_icons/shareholders_icon.png"],
        ["icons/homepage_circle_menu_icons/entities_icon.png","Entities","/Entities","icons/homepage_circle_menu_icons/entities_icon.png"],
        ["icons/homepage_circle_menu_icons/board_icon.png","Board","/Board","icons/homepage_circle_menu_icons/board_icon.png"],
        ["icons/homepage_circle_menu_icons/reports_icon.png","Reports",ConstantName.reportsListViews,"icons/iconsFroDarkMode/annual_report_icon_dark.png"],
        ["icons/homepage_circle_menu_icons/minutes_icon.png","Minutes",ConstantName.minutesMeetingList,"icons/iconsFroDarkMode/agenda_minutes_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/compliance_icon.png","Compliance","/Compliance","icons/homepage_circle_menu_icons/compliance_icon.png"],
        ["icons/homepage_circle_menu_icons/legal_contracts_icon.png","Legal & Contracts","/LegalContracts","icons/homepage_circle_menu_icons/legal_contracts_icon.png"],
        ["icons/homepage_circle_menu_icons/company_information_icon.png","Company Information","/CompanyInformation","icons/iconsFroDarkMode/company_information_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/environment_governance_icon.png","Env Sus & Gov","/EnvironmentSustainabilityGovernance","icons/homepage_circle_menu_icons/environment_governance_icon.png"],//
        ["icons/homepage_circle_menu_icons/financials_icon.png","Financials","Financials","icons/iconsFroDarkMode/financials_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/kpi_icon.png","KPI","KPI","icons/iconsFroDarkMode/kpi_icon_dark.png"],//
        ["icons/homepage_circle_menu_icons/delegation_authority_icon.png","Delegate Of Author","/DelegationOfAuthority","icons/homepage_circle_menu_icons/delegation_authority_icon.png"],
        ["icons/homepage_circle_menu_icons/audit_icon.png","Audit","Audit","icons/homepage_circle_menu_icons/audit_icon.png"],

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
          onTap: () {
            if(list[2] == "/Board"){
              context.read<MenusProvider>().changeMenu("Board");
              context.read<MenusProvider>().changeIconName("Board");
              context.read<IconsProvider>().updateIcon(iconsMap["Board"]!, list[3]);
            }else{
              Navigator.pushReplacementNamed(context, list[2]);
            }
          }
          ,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0,top: 10),
            // color: Colors.red,
            child: Column(
              children: [
                Image.asset(
                  themeProvider.isDarkMode ? list[3] : list[0]
                  // context.watch<IconsProvider>().getIconPath
                  ,height: 40.0,),
                MenuButton(text: list[1],fontSize:10.0,fontWeight: FontWeight.bold)
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
    final yStart = size.height/2 - 45;
    final n = context.childCount;
    for(int i = 0 ; i < n ; i++) {
      const radius = 260;
      final theta = i * pi * 0.5/ (n - 2);
      //to change the circle size you can change the theta inside the Cos and Sin but its limited based on qunantity of buttons
      final x = xStart - (radius) * cos(3.5*theta);
      final y = yStart - (radius) * sin(3.5*theta);
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



