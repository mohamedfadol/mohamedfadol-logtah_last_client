import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../colors.dart';
import '../../../models/performance_reward_model.dart';
import '../../../providers/performance_reward_provider_page.dart';
import '../../../utility/utils.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class PerformanceMembersSigningOrderView extends StatefulWidget {
  final PerformanceRewardModel performance;
  const PerformanceMembersSigningOrderView({super.key, required this.performance});
  static const routeName = '/PerformanceMembersSigningOrderView';
  @override
  State<PerformanceMembersSigningOrderView> createState() => _PerformanceMembersSigningOrderViewState();
}

class _PerformanceMembersSigningOrderViewState extends State<PerformanceMembersSigningOrderView>   with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setLandscapeMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Set to landscapeLeft when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

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
                        text: "Members Signing Orders",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )),

              ],
            ),
          );
        }
    );
  }




  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
          ]);
        }
      },
      child: Scaffold(
        appBar: Header(context),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Static filter section (no scrolling)
              buildFullTopFilter(),
              CustomText(text: 'Recipients',fontWeight: FontWeight.bold,fontSize: 25),
              SizedBox(height: 20),
              // Consumer to load nominations
              Expanded(
                child: Consumer<PerformanceRewardProviderPage>(
                  builder: (BuildContext context, provider, widget) {
                    if (provider.performanceReward.members == null) {
                      provider.getMemberPerformanceForSigningOrder(this.widget.performance);
                      return buildLoadingSniper();
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // This Row should be scrollable, not the whole page
                        provider.performanceReward!.members!.isEmpty
                            ? buildEmptyMessage(
                            AppLocalizations.of(context)!.no_data_to_show)
                            : SizedBox(
                              height: double.infinity,
                              width: MediaQuery.of(context).size.width - 40,
                              child: ListView.separated(
                                itemCount: provider.performanceReward!.members!.length,
                                separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
                                itemBuilder: (context, index) {
                                  final recipient = provider.performanceReward!.members?[index];

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: ListTile(
                                      leading: CustomIcon(icon: Icons.check, ),
                                      title: CustomText(text:
                                        recipient?.memberFirstName ?? '', fontWeight: FontWeight.bold
                                      ),
                                      subtitle:  CustomText(text:recipient?.memberEmail ?? ''),
                                      trailing: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomText(text:
                                            'Signed',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          CustomText(text: "on ${Utils.convertStringToDateFunction(this.widget.performance.createdAt!)}"),
                                            Text('Signed in location',
                                              style: const TextStyle(color: Colors.blue),
                                            ),
                                        ],
                                      ),
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
            ],
          ),
        ),
      ),
    );
  }

}
