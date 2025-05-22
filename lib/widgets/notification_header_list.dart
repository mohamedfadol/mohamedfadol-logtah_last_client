import 'package:diligov_members/models/notification_model.dart';
import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../providers/notification_page_provider.dart';
import '../views/notification_views/NotificationPage.dart';

class NotificationHeaderList extends StatelessWidget {
    NotificationHeaderList({super.key});
  final GlobalKey _iconKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: const [
              BoxShadow(color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
            ]),
        child: IconButton(
          key: _iconKey,
          icon: Stack(
            children: <Widget>[
              CustomIcon(icon: Icons.notifications_active_outlined,size: 40,color: Theme.of(context).iconTheme.color,),
              Positioned(
                right: 0,
                bottom: 19,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 12,
                  ),
                  child: Consumer<NotificationPageProvider>(
                    builder: (context, provider, child) {
                      if (provider?.notificationCount == 0) {
                        provider!.notificationCount!;
                        return CustomText(text: '0', color: Colors.white,fontSize: 12,textAlign: TextAlign.center,);
                      }
                      return provider!.notificationCount! > 0  ? CustomText(text: provider.notificationCount.toString(),color: Colors.white,fontSize: 12,textAlign: TextAlign.center,)
                          : CustomText(text: '0',fontSize: 12,textAlign: TextAlign.center,);
                    },
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => showNotificationsMenu(context),
        )

    );
  }

    void showNotificationsMenu(BuildContext context) {
      try {
        final RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);

        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return PositionedDialog(
              position: offset,
            );
          },
        );
      } catch (e) {
        debugPrint('Error showing notifications menu: $e');
      }
    }

}


class PositionedDialog extends StatelessWidget {
  final Offset position;

  PositionedDialog({required this.position});

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return Stack(
      children: [
        Positioned(
          top: position.dy + 50, // Positioning the dialog just below the header
          left: isRTL ? 0 : position.dx - 320, // Left align for Arabic, keep normal for LTR
          right: isRTL ? position.dx : null, // Adjust for RTL by using `right`
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            child: Container(
              width: 500,
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: NotificationTabsMenu(),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationTabsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Dialog(
        insetPadding: EdgeInsets.only(left: 1, right: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, // Background for the whole TabBar
              ),
              child: Consumer<NotificationPageProvider>(
                builder: (context, provider, _) {
                  final selectedTabIndex = provider.selectedTabIndex;
                  final backgroundColors = [
                    Colors.blue[100], // Background for tab 0
                    Colors.green[100], // Background for tab 1
                    Colors.red[100], // Background for tab 2
                  ];

                  return TabBar(
                      // padding: EdgeInsets.all(0),
                    onTap: (index) {
                      final types = ['normal', 'pending', 'news'];
                      provider.setSelectedTabIndex(index);
                      provider.fetchNotificationsByType(types[index]);
                    },
                    indicator: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    labelPadding: EdgeInsets.zero,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    tabs:  [
                      _buildTab("Notifications", provider.selectedTabIndex == 0),
                      _buildTab("News", provider.selectedTabIndex == 1),
                      _buildTab("Pending", provider.selectedTabIndex == 2),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NotificationList(notificationType: "normal"),
                  NotificationList(notificationType: "pending"),
                  NotificationList(notificationType: "news"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      color: isSelected ? Colors.red : Colors.grey, // Tab background color
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          if (isSelected)
            Positioned.fill(
              child: Container(
              ),
            ),
          CustomText(text:
            title,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }

}


class NotificationList extends StatelessWidget {
  final String notificationType;
  NotificationList({required this.notificationType});

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor;


    return Consumer<NotificationPageProvider>(
      builder: (context, provider, _) {
        List<NotificationModel> notifications = [];
        if (notificationType == "normal") {
          notifications = provider.normalNotifications;
        } else if (notificationType == "pending") {
          notifications = provider.pendingNotifications;
        } else if (notificationType == "news") {
          notifications = provider.newsNotifications;
        }
        if (notifications.isEmpty) {
          return Center(
            child: SpinKitThreeBounce(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: index.isEven ? Colors.red : Colors.green,
                  ),
                );
              },
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Container(
              margin: EdgeInsets.only(bottom: 1.5,top: 1.5),
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: containerColor,
                border: Border(
                  left: BorderSide(
                    color: Colors.black,
                    width: 0.5,
                  ),
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0) ),
              ),
              child: ListTile(
                title: CustomText(text:notification.notificationTitle!,fontWeight: FontWeight.w600, fontSize: 15.0,overflow: TextOverflow.clip,
                  maxLines: 1,
                  softWrap: false,),
                subtitle:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIcon(icon: Icons.lock_clock,color: Theme.of(context).iconTheme.color,),
                    SizedBox(width: 5.0,),
                    CustomText(text: notification.notificationTime!,overflow: TextOverflow.ellipsis,),
                  ],
                ),
                onTap: () {
                  // Handle tap on notification
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(notification: notification),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
