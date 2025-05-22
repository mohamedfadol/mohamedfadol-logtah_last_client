import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../roles/roles_list_view.dart';
import '../../widgets/actions_icon_bar_widget.dart';
import '../../widgets/global_search_box.dart';
import '../../widgets/notification_header_list.dart';
import '../calenders/calendar_page.dart';
import '../tab_bar_view/member_and_committees.dart';
import '../members_view/members_list.dart';
import '../user/profile.dart';

class Setting extends StatefulWidget {
  final int? initialTabIndex;

  const Setting({Key? key, this.initialTabIndex}) : super(key: key);
  static const routeName = '/setting';

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with SingleTickerProviderStateMixin {
  final insertBoardFormGlobalKey = GlobalKey<FormState>();
  TabController? defaultTabBarViewController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 7 tabs
    defaultTabBarViewController = TabController(length: 7, vsync: this);

    // Set the initial tab index if provided
    if (widget.initialTabIndex != null) {
      defaultTabBarViewController!.animateTo(widget.initialTabIndex!);
    }
  }

  @override
  void dispose() {
    defaultTabBarViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0,
        // leadingWidth: 25,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          iconSize: 20.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboardHome');
          },
        ),
        title: Container(
          width: 600,
          child: GlobalSearchBox(),
        ),
        actions: [
          // Your actions remain the same
          // ...
        ],
        bottom: TabBar(
          indicatorWeight: 5,
          enableFeedback: true,
          controller: defaultTabBarViewController,
          // isScrollable: true,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
          onTap: (index) {
            print(index);
          },
          tabs: [
            Tab(child: Text("Permissions")),
            Tab(child: Text("Committees")),
            Tab(child: Text("Settings")),
            Tab(child: Text("Subscriptions")),
            Tab(child: Text("Stats")),
            Tab(child: Text("User Management")),
            Tab(child: Text("Votes & Survey")),
          ],
        ),
      ),
      body: TabBarView(
        controller: defaultTabBarViewController,
        children: [
          RolesListView(),
          MemberAndCommittees(),
          Center(
              child: Container(
                  color: Colors.yellow,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  )
              )
          ),
          Center(
              child: Container(
                  color: Colors.blueAccent,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  )
              )
          ),
          Center(
              child: Container(
                  color: Colors.grey,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  )
              )
          ),
          Center(
              child: Container(
                color: Colors.black12,
                child: MembersList(),
              )
          ),
          Center(
              child: Container(
                  color: Colors.brown,
                  child: Text(
                    "state",
                    style: TextStyle(color: Colors.green),
                  )
              )
          ),
        ],
      ),
    );
  }
}