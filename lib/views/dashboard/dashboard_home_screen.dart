import 'dart:math';

import 'package:diligov_members/providers/member_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/domains/app_uri.dart';
import '../../models/member.dart';
import '../../providers/meeting_page_provider.dart';
import '../../providers/menus_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/actions_icon_bar_widget.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/drawer/NavigationDrawerWidget.dart';
import '../../widgets/drowpdown_list_languages_widget.dart';
import '../../widgets/global_search_box.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/mini_calendar_widget.dart';
import '../../widgets/notification_header_list.dart';
import '../../widgets/circularFabWidget.dart';
import '../../widgets/custome_text.dart';
import '../../views/calenders/calendar_page.dart';
import '../../views/user/profile.dart';
import '../../views/dashboard/setting.dart';
import '../../widgets/footer_home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../modules/evaluation_views/member_evaluation_details.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool menuPressed = false;
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingPageProvider>(context, listen: false).fetchUpComingMeetings();
    });
  }

  List<Widget> _buildPages() {
    return [
      _buildMemberGrid(),
      Center(child: MiniCalendarWidget()),
      Center(child: CustomText(text: "📂 Documents Widget Placeholder", fontSize: 18)),
      Center(child: CustomText(text: "⚙️ Settings Panel Placeholder", fontSize: 18)),
    ];
  }

  Widget _buildMemberGrid() {
    return Center(
      child: Consumer<MemberPageProvider>(
        builder: (context, provider, _) {
          if (provider.dataOfMembers?.members == null) {
            provider.getListOfMembers();
            return buildLoadingSniper();
          }
          if (provider.dataOfMembers!.members!.isEmpty) {
            return buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show);
          }
          return provider.dataOfMembers!.members!.isEmpty
              ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
              : GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 7,
                  childAspectRatio: 1,
                ),
                itemCount: provider.dataOfMembers!.members!.length,
                itemBuilder: (ctx, i) {
              final Member member = provider.dataOfMembers!.members![i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemberEvaluationDetails(member: member),
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 30,
                  child: Container(
                    width: 75.0,
                    height: 75.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: member.memberProfileImage == null
                            ? const AssetImage("assets/images/profile.jpg")
                            : NetworkImage(
                          '${AppUri.baseUntilPublicDirectory}/profile_images/${member.businessId}/${member.memberProfileImage}',
                        ) as ImageProvider,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        leading: ActionsIconBarWidget(
          onPressed: () {
            _scaffoldState.currentState?.openDrawer();
          },
          buttonIcon: Icons.chrome_reader_mode_outlined,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 30,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 80.0,
          containerBackgroundColor: Colors.white,
        ),
        title: SizedBox(
          width: 600,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.4,
                ),
              ],
            ),
            child: GlobalSearchBox(),
          ),
        ),
        actions: [
          Center(child: DropdownListLanguagesWidget()),
          const SizedBox(width: 10),
          ActionsIconBarWidget(
            onPressed: () {
              Navigator.pushReplacementNamed(context, CalendarPage.routeName);
            },
            buttonIcon: Icons.calendar_month_outlined,
            buttonIconColor: Theme.of(context).iconTheme.color,
            buttonIconSize: 30,
            boxShadowColor: Colors.grey,
            boxShadowBlurRadius: 2.0,
            boxShadowSpreadRadius: 0.4,
            containerBorderRadius: 30.0,
            containerBackgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          ActionsIconBarWidget(
            onPressed: () {
              bool value = themeProvider.isDarkMode ? false : true;
              themeProvider.toggleTheme(value);
            },
            buttonIcon: Icons.brightness_medium,
            buttonIconColor: Theme.of(context).iconTheme.color,
            buttonIconSize: 30,
            boxShadowColor: Colors.grey,
            boxShadowBlurRadius: 2.0,
            boxShadowSpreadRadius: 0.4,
            containerBorderRadius: 30.0,
            containerBackgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          NotificationHeaderList(),
          const SizedBox(width: 10),
          ActionsIconBarWidget(
            onPressed: () {
              Navigator.pushReplacementNamed(context, ProfileUser.routeName);
            },
            buttonIcon: Icons.manage_accounts_outlined,
            buttonIconColor: Theme.of(context).iconTheme.color,
            buttonIconSize: 30,
            boxShadowColor: Colors.grey,
            boxShadowBlurRadius: 2.0,
            boxShadowSpreadRadius: 0.4,
            containerBorderRadius: 30.0,
            containerBackgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          ActionsIconBarWidget(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Setting.routeName);
            },
            buttonIcon: Icons.brightness_low,
            buttonIconColor: Theme.of(context).iconTheme.color,
            buttonIconSize: 30,
            boxShadowColor: Colors.grey,
            boxShadowBlurRadius: 2.0,
            boxShadowSpreadRadius: 0.4,
            containerBorderRadius: 30.0,
            containerBackgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
        ],
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldState,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: NavigationDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Consumer<MenusProvider>(
          builder: (BuildContext context, provider, widget) {
            return Stack(
              children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 50),
                      Center(
                        child: GestureDetector(
                          onDoubleTap: () {
                            Provider.of<MenusProvider>(context, listen: false)
                                .goToPreviousMenu();
                          },
                          onTap: () {
                            Provider.of<MenusProvider>(context, listen: false)
                                .changeMenuPressed();
                          },
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  String iconPath = provider.getIconName == "Home" &&
                                      (themeProvider.getIconPath ==
                                          "icons/committee_circle_menu_icons/committee_icon.png" ||
                                          themeProvider.getIconPath ==
                                              "icons/iconsFroDarkMode/committee_icon_dark.png")
                                      ? (themeProvider.isDarkMode
                                      ? 'icons/homepage_circle_menu_icons/board_icon.png'
                                      : "icons/homepage_circle_menu_icons/board_icon.png")
                                      : provider.getIconName == "Board"
                                      ? "icons/board_circle_menu_icons/board_main_icon.png"
                                      : provider.getIconName == "Committees" &&
                                      (themeProvider.getIconPath ==
                                          "icons/board_circle_menu_icons/committee_icon.png" ||
                                          themeProvider.getIconPath ==
                                              "icons/iconsFroDarkMode/committee_icon_dark.png")
                                      ? themeProvider.isDarkMode
                                      ? 'icons/iconsFroDarkMode/committee_icon_dark.png'
                                      : "icons/committee_circle_menu_icons/committee_icon.png"
                                      : themeProvider.getIconPath;

                                  double imageSize =
                                      constraints.maxWidth * 0.2;

                                  return Image.asset(
                                    iconPath,
                                    width: imageSize,
                                    height: imageSize,
                                  );
                                },
                              ),
                              if (provider.getIconName != "Home")
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: CustomText(
                                    text: provider.getIconName,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      FooterHomePage(),
                    ],
                  ),

                  // Existing FAB logic
                  Visibility(
                    visible: provider.menuPressed,
                    child: CircularFabWidget(),
                  ),

                  // Right-center floating button
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 3 - 60,
                    child: GestureDetector(
                      onTap: provider.toggleMeetingsListInDashboardVisibility,
                      child: Container(
                        width: 17,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: CustomIcon(icon:
                            provider.isVisibleMeetingInDashboard ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3-column list view popup
                  if (provider.isVisibleMeetingInDashboard)
                    Positioned(
                      top: 100,
                      right: 20,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 500,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 6, spreadRadius: 2)],
                        ),
                        child: Consumer<MeetingPageProvider>(
                          builder: (context, meetingProvider, _) {

                            if (meetingProvider.loading) {
                              return buildLoadingSniper();
                            }
                            if (meetingProvider.dataOfMeetings?.meetings == null) {
                              meetingProvider.fetchUpComingMeetings();
                              return buildLoadingSniper();
                            }

                            return meetingProvider.dataOfMeetings!.meetings!.isEmpty
                                ? buildEmptyMessage(
                                AppLocalizations.of(context)!.no_data_to_show)
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(text: "Upcoming Meetings",  fontSize: 18, fontWeight: FontWeight.bold),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: meetingProvider.dataOfMeetings?.meetings?.length ?? 0,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (ctx, index) {
                                      final meeting = meetingProvider.dataOfMeetings!.meetings?[index];
                                      return ListTile(
                                        title: CustomText(text:meeting?.meetingTitle ?? '',overflow: TextOverflow.ellipsis),
                                        subtitle: CustomText(text:'Start: ${meeting?.meetingStart?.toLocal().toString().split('.')[0] ?? ''}'),
                                        trailing: Wrap(
                                          spacing: 10,
                                          children: [
                                            meeting?.isAttended == 1
                                                ?   Chip(label: CustomText(text: "Attending", color: Colors.green,)) // 💡 Show label instead of button
                                                : ElevatedButton(
                                              onPressed: () async {
                                                await meetingProvider.sendAttendanceStatus(oldMeeting: meeting, isAttending: true);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: CustomText(text: 'Marked as attending')),
                                                );
                                                // optional: refresh list
                                                await Provider.of<MeetingPageProvider>(context, listen: false)
                                                    .fetchUpComingMeetings();
                                              },
                                              child: CustomText(text:"Confirm Attendance", fontWeight: FontWeight.bold,),
                                            ),

                                            OutlinedButton(
                                              onPressed: () => _showReasonDialog(
                                                context,
                                                meeting!.meetingId!,
                                                    (reason) async {
                                                      await Provider.of<MeetingPageProvider>(context, listen: false)
                                                          .sendAttendanceStatus(
                                                        oldMeeting: meeting,
                                                        isAttending: false,
                                                        reason: reason,
                                                      );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: CustomText(text:'Reason submitted')),
                                                  );
                                                  await Provider.of<MeetingPageProvider>(context, listen: false).fetchUpComingMeetings();
                                                },
                                              ),
                                              child: CustomText(text: "Not Attend" , color: Colors.red,),
                                            ),
                                          ],
                                        ),

                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom-left scrollable member avatars (both directions)
                    Positioned(
                      bottom: 60,
                      left: 10,
                      child: SizedBox(
                        width: 450,
                        height: 250,
                        child: Stack(
                          children: [
                        if (provider.isVisibleQuickAccessInDashboard)
                            // The active page
                            Positioned.fill(
                              child: _buildPages()[provider.selectedPageIndex],
                            ),
                            SizedBox(height: 30,),
                            // Dot navigation
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_buildPages().length, (index) {
                                  return GestureDetector(
                                    onTap: () =>  provider.toggleSelectedPageIndexInDashboardVisibility(index),
                                    child: Container(
                                      margin:  EdgeInsets.symmetric(horizontal: 6),
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: provider.selectedPageIndex == index ? Colors.red : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if(!provider.menuPressed)
                    Positioned(
                      top: 10,
                      left: 20,
                      child: RadarChartWidget()
                  )


              ],
            );
          },
        ),
      ),
    );
  }

  void _showReasonDialog(BuildContext context, int meetingId, Function(String) onSubmit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: CustomText(text:'Reason for Not Attending'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your reason'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: CustomText(text:'Cancel')),
          ElevatedButton(
            onPressed: () {
              onSubmit(controller.text);
              Navigator.of(ctx).pop();
            },
            child: CustomText(text:'Submit'),
          ),
        ],
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


}

class RadarChartWidget extends StatelessWidget {
  final List<RadarData> sampleData = [
    RadarData('Profit', 30, 50),
    RadarData('Expenses', 80, 70),
    RadarData('Gross profit', 90, 40),
    RadarData('Risks', 95, 60),
    RadarData('Compliance', 40, 30),
    RadarData('Overhead', 85, 70),
    RadarData('ROCE', 50, 60),
    RadarData('ROA', 100, 75),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: CustomPaint(
        size: Size(350, 350),
        painter: RadarChartPainter(data: sampleData),
      ),
    );
  }
}


class RadarChartPainter extends CustomPainter {
  final List<RadarData> data;
  final double maxValue;
  final int layers;

  RadarChartPainter({required this.data, this.maxValue = 100, this.layers = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.5;
    final angleStep = 2 * pi / data.length;
    final Paint gridPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    final Paint budgetPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint actualPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw concentric grids
    for (int i = 1; i <= layers; i++) {
      final r = radius * (i / layers);
      final path = Path();
      for (int j = 0; j < data.length; j++) {
        final x = center.dx + r * cos(angleStep * j - pi / 2);
        final y = center.dy + r * sin(angleStep * j - pi / 2);
        if (j == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    for (int i = 0; i < data.length; i++) {
      final x = center.dx + radius * cos(angleStep * i - pi / 2);
      final y = center.dy + radius * sin(angleStep * i - pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw budget polygon
    final budgetPath = Path();
    for (int i = 0; i < data.length; i++) {
      final value = data[i].budget / maxValue;
      final x = center.dx + radius * value * cos(angleStep * i - pi / 2);
      final y = center.dy + radius * value * sin(angleStep * i - pi / 2);
      if (i == 0)
        budgetPath.moveTo(x, y);
      else
        budgetPath.lineTo(x, y);
    }
    budgetPath.close();
    canvas.drawPath(budgetPath, budgetPaint);

    // Draw actual polygon
    final actualPath = Path();
    for (int i = 0; i < data.length; i++) {
      final value = data[i].actual / maxValue;
      final x = center.dx + radius * value * cos(angleStep * i - pi / 2);
      final y = center.dy + radius * value * sin(angleStep * i - pi / 2);
      if (i == 0)
        actualPath.moveTo(x, y);
      else
        actualPath.lineTo(x, y);
    }
    actualPath.close();
    canvas.drawPath(actualPath, actualPaint);

    // Draw labels
    for (int i = 0; i < data.length; i++) {
      final label = data[i].label;
      final x = center.dx + (radius + 12) * cos(angleStep * i - pi / 2);
      final y = center.dy + (radius + 12) * sin(angleStep * i - pi / 2);
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: Colors.grey)),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(x - tp.width / 2, y - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class RadarData {
  final String label;
  final double budget;
  final double actual;

  RadarData(this.label, this.budget, this.actual);
}
