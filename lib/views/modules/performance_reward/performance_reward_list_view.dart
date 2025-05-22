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

    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";


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
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Static filter section (no scrolling)
              buildFullTopFilter(),

              // Consumer to load nominations
              Expanded(
                child: Consumer<PerformanceRewardProviderPage>(
                  builder: (BuildContext context, provider, widget) {
                    if (provider.performanceRewardData?.performanceRewards == null) {
                      provider.getListOfPerformanceRewards(provider.yearSelected);
                      return buildLoadingSniper();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Only Row scrolls
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 400,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                    color: Colour().buttonBackGroundRedColor,
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      showUploadDialog(context, 'performance', committeeId);
                                    },
                                    child: CustomText(
                                      text: 'Upload Bonus Scheme',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // This Row should be scrollable, not the whole page
                          provider.performanceRewardData!.performanceRewards!.isEmpty
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

          String fullUrl = '${AppUri.baseUntilPublicDirectoryMeetings}/${performance.originalBonusScheme}';
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
                // processPdfWorkflow
                ElevatedButton(
                    onPressed: () async {
                      provider.setLoading(true);
                      provider.processPdfWorkflow(
                        performance,
                          fullUrl, // Network PDF URL
                          1, // Number of new pages to add
                          "publish-performance-bonus_scheme_file",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(text: "please waiting to upload file ..." ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 20),
                        ),
                      );
                      provider.setLoading(false);
                    },
                    child: CustomIcon(icon: Icons.public_outlined, color: Colors.green,)
                ),
                SizedBox(width: 10,),
                // delete_forever_outlined
                ElevatedButton(
                    onPressed: () async { await dialogDeletePerformance(performance);},
                    child: CustomIcon(icon: Icons.delete_forever_outlined, color: Colors.red,)
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

  Future dialogDeletePerformance(PerformanceRewardModel performance) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.are_you_sure_to_delete} ${performance.bonusScheme!} ?",
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_delete,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: ()  {
                                removePerformance(performance);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void removePerformance(PerformanceRewardModel performance) async {
    final provider = Provider.of<PerformanceRewardProviderPage>(context, listen: false);
    provider.setLoading(true);
    await provider.removePerformance(performance);
    provider.setLoading(false);
    if (provider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: "remove done"),
          backgroundColor: Colors.greenAccent,
        ),
      );
      await Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: "remove failed",),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  /// **Dialog for Uploading PDF/Word Files**
  void showUploadDialog(BuildContext context, String bonusScheme, String committeeId) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<PerformanceRewardProviderPage>(
          builder: (context, uploadProvider, child) {
            String? uploadedFileName = uploadProvider.getUploadedFileName(bonusScheme);
            bool isFileMissing = uploadProvider.fileValidationErrors[bonusScheme] ?? false;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: AlertDialog(
                    title: CustomText(text: "Upload Document for $bonusScheme"),
                    content: SizedBox(
                      width: 500,
                      height: 300,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              icon: CustomIcon(icon: Icons.upload_file),
                              label: CustomText(text: "Upload Bonus Scheme"),
                              onPressed: () => uploadProvider.pickFile(bonusScheme),
                            ),
                            if (uploadedFileName != null) ...[
                              SizedBox(height: 10),
                              CustomText(text: "Uploaded: $uploadedFileName", color: Colors.green),
                            ],
                            if (isFileMissing) ...[
                              SizedBox(height: 10),
                              CustomText(text: "File is required!", fontWeight: FontWeight.bold),
                            ],
                            if (uploadProvider.loading) ...[
                              SizedBox(height: 10),
                              CircularProgressIndicator(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: uploadProvider.loading
                            ? null // Disable button during loading
                            : () => Navigator.pop(context),
                        child: CustomText(
                          text: "Close",
                          color: uploadProvider.loading ? Colors.grey : Colors.black,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: uploadProvider.loading
                            ? null // Disable button during loading
                            : () async {
                          setState(() {
                            uploadProvider.setLoading(true); // Start loading
                          });

                          User user = User();
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          user = User.fromJson(json.decode(prefs.getString("user")!));

                          bool isValid = uploadProvider.validateFile(bonusScheme);
                          final FormState form = _formKey.currentState!;
                          if (form.validate() && isValid) {
                            String? base64File = await uploadProvider.getFileAsBase64(bonusScheme);
                            Map<String, dynamic> data = {
                              "bonus_scheme_file": base64File,
                              'business_id': user.businessId.toString(),
                              "committee_id": committeeId,
                            };

                            await uploadProvider.insertNewPerformanceRewardData(data);

                            if (uploadProvider.isBack) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomText(text: "Bonus scheme added successfully"),
                                  backgroundColor: Colors.greenAccent,
                                ),
                              );
                              uploadProvider.clearUploadedFile(bonusScheme); // Clear file after success
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomText(text: "Bonus scheme added failed"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomText(text: "No bonus scheme file uploaded!", color: Colors.red),
                              ),
                            );
                          }

                          setState(() {
                            uploadProvider.setLoading(false); // Stop loading
                          });
                        },
                        child: uploadProvider.loading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : CustomText(text: "Save"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
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
