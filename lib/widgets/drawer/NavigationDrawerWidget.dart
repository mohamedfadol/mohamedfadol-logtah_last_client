import 'package:diligov_members/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors.dart';
import '../../models/data/drawer_items.dart';
import '../../models/drawer_item.dart';
import '../../providers/navigator_provider.dart';
import '../../utility/shared_preference.dart';
import '../assets_widgets/login_image.dart';
import '../custom_icon.dart';
import '../custome_text.dart';
class NavigationDrawerWidget extends StatelessWidget {
 final padding = EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context) {
    final safeArea = EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    final provider = Provider.of<NavigatorProvider>(context);
    final isCollapsed = provider.isCollapsed;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor;
    return Container(
      width: isCollapsed ? MediaQuery.of(context).size.width * 0.06 : null,
      child: Drawer(
        child: Container(
          color: containerColor,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10).add(safeArea),
                    color: containerColor,
                    width: double.infinity,
                    child: buildHeader(context,isCollapsed)
                ),
              ),
              const SizedBox(height: 5,),
              buildList(items: itemsFirst, isCollapsed: isCollapsed),
              // Spacer(),
              buildList(
                  indexOffset: itemsFirst.length,
                  items: itemsLast,
                  isCollapsed: isCollapsed
              ),
              buildCollapseIcon(context,isCollapsed),
              const SizedBox(height: 6,)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool isCollapsed) => isCollapsed ? LoginImage(height: 100,) :  LoginImage(height: 170,);

 Widget buildCollapseIcon(BuildContext context, bool isCollapsed) {
   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
   final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor;
    const double size = 52;
    final icon = isCollapsed ?  Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final alignment = isCollapsed ? Alignment.center : Alignment.centerRight;
    final margin = isCollapsed ? null : EdgeInsets.only(right: 16);
    final width = isCollapsed ? double.infinity :  size;
    return Container(
      color: containerColor,
      alignment: alignment,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: SizedBox(
            height: size,
            width: width,
            child: CustomIcon(icon: icon, color: Theme.of(context).iconTheme.color,),
          ),
          onTap: (){
            final provider = Provider.of<NavigatorProvider>(context,listen: false);
            provider.togglisCollapsed();
          },
        ),
      ),
    );
  }

 Widget buildList({
  required bool isCollapsed,
  required List<DrawerItem> items,
   int indexOffset = 0,
   
}) => ListView.separated(scrollDirection: Axis.vertical,
      padding: isCollapsed ? EdgeInsets.zero : padding ,
      shrinkWrap: true,
      primary: false,
      itemCount: items.length,
      separatorBuilder: (context, index)  => SizedBox(height: 5,),
      itemBuilder: (context,index){
      final item = items[index];
      return buildMenuItem(
          isCollapsed: isCollapsed,
          text: item.title,
          icon: item.icon,
          size: 30,
          onClick: () => selectItem(context, indexOffset + index),
          context: context,
      );
     },
 );

 void selectItem (BuildContext context,int index){
   Navigator.of(context).pop();
   switch(index){
     case 0:
       Navigator.pushReplacementNamed(context, '/dashboardHome');
     break;
     case 1:
       Navigator.pushReplacementNamed(context, '/loginPage');
       break;
     case 2:
       Navigator.pushReplacementNamed(context, '/notes');
       break;
     case 3:
       Navigator.pushReplacementNamed(context, '/loginPage');
       break;
     case 4:
       Navigator.pushReplacementNamed(context, '/loginPage');
       break;
     case 5:
       Navigator.pushReplacementNamed(context, '/loginPage');
       break;
     case 6:
       UserPreferences().removeUser().then((_) {
         Navigator.pushReplacementNamed(context, '/loginPage');
       });
       break;
   }
 }


 Widget buildMenuItem({
    required bool isCollapsed,
    required String text,
    required IconData icon,
   required double size,
    VoidCallback?  onClick,
   required BuildContext context
}){
 
    final leading = CustomIcon(icon: icon,color: Theme.of(context).iconTheme.color,size: size,);
     return Container(
       decoration: BoxDecoration(
         border: Border(bottom: BorderSide(color: Colors.black12,width: 2,)),
       ),
       child: Material(
         color: Colour().buildMenuItemColor,
         child: isCollapsed ?  ListTile(
           leading: leading,
           onTap: onClick,
         ) : ListTile(
           leading: leading,
           title: CustomText(text: text,fontSize: 18,fontWeight: FontWeight.bold,),
           onTap: onClick,
         ),
       ),
     );
 }
}
