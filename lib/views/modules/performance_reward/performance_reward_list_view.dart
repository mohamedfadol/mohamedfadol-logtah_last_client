import 'dart:convert';
import 'package:diligov_members/providers/performance_reward_provider_page.dart';
import 'package:diligov_members/views/modules/performance_reward/performance_members_signing_order_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../../colors.dart';
import '../../../core/domains/app_uri.dart';
import '../../../models/data/years_data.dart';
import '../../../models/performance_reward_model.dart';
import '../../../models/user.dart';
import '../../../utility/custome_pdf_viewr.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';

class PerformanceRewardListView extends StatefulWidget {
  const PerformanceRewardListView({super.key});
  static const routeName = '/PerformanceRewardListView';

  @override
  State<PerformanceRewardListView> createState() => _PerformanceRewardListViewState();
}

class _PerformanceRewardListViewState extends State<PerformanceRewardListView>  with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setLandscapeMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetOrientation();
    super.dispose();
  }

  // Force landscapeLeft mode specifically
  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // Enforce only landscapeLeft
    ]);
  }

  // Reset to default orientation
  void _resetOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  // Ensure landscapeLeft when app resumes or after navigation
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setLandscapeMode();
    }
  }

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _resetOrientation(); // Reset when leaving the screen
        }
      },
      child: Scaffold(
        appBar: Header(context),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Static filter section (no scrolling)
              buildFullTopFilter(),

              // Consumer to load nominations
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                child: Consumer<PerformanceRewardProviderPage>(
                  builder: (BuildContext context, provider, widget) {
                    if (provider.performanceRewardData?.performanceRewards == null) {
                      provider.getListOfPerformanceRewards(provider.yearSelected);
                      return buildLoadingSniper();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Only Row scrolls
                      child: provider.performanceRewardData!.performanceRewards!.isEmpty
                          ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: provider.loading ? Center(child: CircularProgressIndicator(),) : buildPerformanceList(provider.performanceRewardData!.performanceRewards!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  /// **Builds nomination cards in a two-column format**
  Widget buildPerformanceList(List<PerformanceRewardModel> performances) {
    List<Widget> rows = [];
    for (int i = 0; i < performances.length; i ++) {
      rows.add(buildPerformanceCard(performances[i].bonusScheme!, performances[i]));
      rows.add(SizedBox(height: 20));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: rows,
    );
  }

  /// **Creates a card for a nomination**
  Widget buildPerformanceCard(String bonusScheme,PerformanceRewardModel performance) {
    return  Consumer<PerformanceRewardProviderPage>(
        builder: (BuildContext context, provider, widget) {
          return provider.loading ? Center(child: CircularProgressIndicator()) :Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                )
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  if(performance.published == true)
                  // Signing Order
                  ElevatedButton(
                      onPressed: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PerformanceMembersSigningOrderView(performance: performance)));
                      },
                      child: CustomText(text: "Signing Order")
                  ),
                SizedBox(width: 10,),

                if(performance.published == true)
                  // Custom Pdf View
                  ElevatedButton(
                      onPressed: () async{
                        provider.setLoading(true);
                        final  String  fullUrl = '${AppUri.baseUntilPublicDirectoryMeetings}/${performance.bonusScheme}';
                        print("full url $fullUrl");
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CustomPdfView(path: fullUrl)));
                        provider.setLoading(false);
                      },
                      child: CustomIcon(icon: Icons.open_in_new)
                  ),

                  SizedBox(width: 10,),

                  CustomText(
                    text: bonusScheme,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                  ),
              ],
            ),
          );
        }
    );

  }


  Widget buildFullTopFilter() {
    return Consumer<PerformanceRewardProviderPage>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: "Performance & Rewards ",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )),
                const SizedBox(
                  width: 5.0,
                ),

                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                      vertical: 7.0, horizontal: 15.0),
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
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getListOfPerformanceRewards(
                          provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


}
