import 'package:diligov_members/providers/member_page_provider.dart';
import 'package:diligov_members/views/modules/evaluation_views/evaluation_home.dart';
import 'package:diligov_members/views/modules/evaluation_views/member_evaluation_details.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../models/member.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../../../models/user.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class EvaluationListViews extends StatefulWidget {
  const EvaluationListViews({Key? key}) : super(key: key);
  static const routeName = '/EvaluationListViews';

  @override
  State<EvaluationListViews> createState() => _EvaluationListViewsState();
}

class _EvaluationListViewsState extends State<EvaluationListViews> {


  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  @override
  Widget build(BuildContext context) {

    // Retrieve the arguments passed from navigation
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract committeeId safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

  print("committeeId  $committeeId");
    return Scaffold(
      appBar: Header(context),
      body: Column(
        children: [
          buildFullTopFilter(),
          Expanded(
            child: Consumer<MemberPageProvider>(
              builder: (context, provider, _) {
                if (provider.dataOfMembers?.members == null) {
                  provider.getListOfMembers();
                  return buildLoadingSniper();
                }
                return provider.dataOfMembers!.members!.isEmpty
                    ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                    : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    crossAxisCount: 5,
                  ),
                  itemCount: provider.dataOfMembers!.members!.length,
                  itemBuilder: (BuildContext ctx, i) {
                    final Member member = provider.dataOfMembers!.members![i];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MemberEvaluationDetails(member: member),
                        ),
                      ),
                      child: Container(
                        color: Colors.grey[300],
                        height: 50,
                        width: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 100,
                              child: Container(
                                width: 190.0,
                                height: 190.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: member.memberProfileImage == null
                                        ? const AssetImage("assets/images/profile.jpg")
                                        : NetworkImage('https://diligov.com/public/profile_images/${member.businessId}/${member.memberProfileImage}') as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            CustomText(
                              text: '${member.memberFirstName}',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );

  }

  Widget  buildFullTopFilter() => Padding(
    padding: const EdgeInsets.only(top: 3.0,left: 0.0,right: 8.0,bottom: 8.0),
    child: Row(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
            color: Colors.red,
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, EvaluationListViews.routeName);
              },
              child: CustomText(text:'Members View Result',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            )
        ),
        const SizedBox(width: 5.0,),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
            color: Colors.red,
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, EvaluationListViews.routeName);
              },
              child: CustomText(text:'Boards View Result',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
            )
        ),
        // const SizedBox(width: 5.0,),
        // Container(
        //     padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 15.0),
        //     color: Colors.red,
        //     child: TextButton(
        //       onPressed: (){
        //         Navigator.pushReplacementNamed(context, EvaluationHome.routeName);
        //       },
        //       child: CustomText(text:'Evaluation Home',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
        //     )
        // ),
      ],
    ),
  );


}
