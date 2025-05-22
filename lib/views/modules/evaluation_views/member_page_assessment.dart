import 'dart:convert';
import 'package:diligov_members/views/modules/evaluation_views/evaluation_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../../colors.dart';
import '../../../models/user.dart';
import '../../../providers/committee_provider_page.dart';
import '../../../providers/evaluation_page_provider.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/loading_sniper.dart';

class MemberPageAssessment extends StatefulWidget {
  const MemberPageAssessment({Key? key}) : super(key: key);
  static const routeName = '/MemberPeerAssessment';

  @override
  State<MemberPageAssessment> createState() => _MemberPageAssessmentState();
}

class _MemberPageAssessmentState extends State<MemberPageAssessment> {
  final _formKey = GlobalKey<FormState>();
  User user = User();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final provider = Provider.of<EvaluationPageProvider>(context, listen: false);

    // Build the _categoryQuestions map
    if (provider.dataOfCategories != null && provider.dataOfCategories!.categories != null) {
      final Map<int, List<int>> categoryQuestionsMap = {};

      for (final category in provider.dataOfCategories!.categories!) {
        categoryQuestionsMap[category.categoryId!] = category.questions!
            .map((question) => question.questionId!)
            .toList();
      }

      provider.setCategoryQuestions(categoryQuestionsMap);
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  Widget CombinedCollectionBoardCommitteeDataDropDownList() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<CommitteeProviderPage>(
        builder: (context, committeeProvider, child) {
          if (committeeProvider.committeesData ?.committees == null) {
            committeeProvider.getListOfCommitteesData();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              committeeProvider.committeesData!
                  .committees!.isEmpty
                  ? buildEmptyMessage(
                  AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,
                  items: committeeProvider.committeesData
                      ?.committees
                      ?.map((committee) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value:'${committee.id}',
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 0.1, color: Colors.black),
                        ),
                        child: Center(child: CustomText(text: committee.committeeName.toString())),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    var selectedCommittee = committeeProvider.committeesData!.committees!
                        .firstWhere((committee) => committee.id.toString() == selectedItem);
                    committeeProvider.setCombinedCollectionBoardCommittee(
                      selectedItem,
                      selectedCommittee.committeeName.toString(),
                    );
                  },
                  hint: CustomText(
                    text: committeeProvider.selectedCombined != null
                        ? committeeProvider.selectedCombined!
                        : 'Select an item please',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (committeeProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: CustomText(text:
                    committeeProvider.dropdownError!,
                     color: Colors.red, fontSize: 12,
                  ),
                ),
            ],
          );
        },
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
          child: Consumer<EvaluationPageProvider>(
              builder: (BuildContext context, provider, widget) {
            return Form(
              key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    // Sticky Header
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: _StickyHeaderDelegate(
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          margin: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Set the border color here
                              width: 0.3, // Set the border width to 0.5
                            ),
                            borderRadius:
                            BorderRadius.circular(3), // Optional: to round the corners
                          ),
                          child: buildHeaderButtons(),
                        ), headerHeight: 70.0,
                      ),
                    ),
                    // Scrollable Content
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          const SizedBox(height: 10),
                          for (int i = 0;i < provider.categoryControllers.length;i++)
                            Column(
                              children: [
                                SizedBox(height: 20.0),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(width: 0.1),
                                      left: BorderSide(width: 0.1),
                                      bottom: BorderSide(width: 0.1),
                                    ),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                          padding:
                                          const EdgeInsets.only(right: 5.0),
                                          color: Colors.white10,
                                          child: Text('${i + 1}')),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        flex: 9,
                                        child: SizedBox(
                                          height: 100,
                                          child: buildCustomTextFormField(
                                            controller:
                                            provider.categoryControllers[i],
                                            hint: 'Enter Category',
                                            validatorMessage:
                                            'please enter criteria Category',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: InkWell(
                                            child: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                              size: 50,
                                            ),
                                            onTap: () {
                                              print("remove fff $i");
                                              provider.removeParentForm(i);
                                            },
                                          )),
                                      Expanded(
                                        child: InkWell(
                                          child: const Icon(
                                            Icons.add_circle_outline_outlined,
                                            color: Colors.green,
                                            size: 50,
                                          ),
                                          onTap: () {
                                            print("add fff $i");
                                            provider.addChildItem(i);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                buildReOrderListChildrenRowFieldsForFormParent(
                                    i, provider),
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            );
          }),
        ),
      ),
    );
  }

  Widget buildReOrderListChildrenRowFieldsForFormParent(int i, EvaluationPageProvider provider) {
    // bool hasItems = provider.categoryItems.isNotEmpty && provider.categoryItems.isNotEmpty;
    bool hasItems = provider.categoryItems.isNotEmpty && provider.categoryItems[i].isNotEmpty;
    int childCount = hasItems ? provider.categoryItems[i].length : 0;

    // Calculate height based on the number of children
    double calculatedHeight = childCount * 120.0; // Assuming each child takes 100px

    int? newIndex = i;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey[200],
        height: hasItems ? calculatedHeight : 0.0,
        width: MediaQuery.of(context).size.width,
        child: hasItems
            ? ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  provider.reorderChildItems(i, oldIndex, newIndex);
                },
                children: [
                  for (int j = 0; j < provider.categoryItems[i].length; j++)
                    ListTile(
                      key: ValueKey(provider.categoryItems[i][j]),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            color: Colors.white10,
                            child: CustomText(
                              text: '${newIndex + 1}.${j}',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: SizedBox(
                              height: 100,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: buildCustomTextFormField(
                                      controller: provider.questionControllers[i][j],
                                      hint: 'Question Text',
                                      validatorMessage:
                                          'Please enter Question Text',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildRemoveChildrenButton(i, j, provider),
                        ],
                      ),
                      trailing: ReorderableDragStartListener(
                        index: j,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                ],
              )
            : SizedBox.shrink(), // If there are no items, return an empty widget
      ),
    );
  }

  buildRemoveChildrenButton(int i, int j, EvaluationPageProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 30.0,
              ),
              onTap: () {
                provider.removeChildItem(i, j);
              },
            ),
          ],
        ),
      );

  Widget buildHeaderButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, EvaluationHome.routeName);
                },
                child: CustomText(
                  text: 'Back',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          CombinedCollectionBoardCommitteeDataDropDownList(),
          Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
              child: buildAddButton()),
          buildEditingActions()
        ],
      );

  Widget buildEditingActions() => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shadowColor: Colors.transparent,
        ),
        onPressed: saveForm,
        icon: const Icon(Icons.done),
        label: const Text('Save'),
      );

  Future saveForm() async {

    final provider = Provider.of<EvaluationPageProvider>(context, listen: false);
    final committeeProvider = Provider.of<CommitteeProviderPage>(context, listen: false);
    List<Map<String, dynamic>> formData = provider.collectFormData();
    print(formData);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final isValid = _formKey.currentState!.validate();
    if (isValid ) {

      // Validate the dropdown selection
      committeeProvider.validateDropdown();
      if (committeeProvider.dropdownError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: committeeProvider.dropdownError!),
            backgroundColor: Colors.redAccent,
          ),
        );
        return; // Stop the form submission if there's an error
      }else{
        Map<String, dynamic> data = {
          "listOfCategoryQuestion": formData,
          "created_by": user.userId,
          "business_id": user.businessId,
          "committee_id": committeeProvider.committeeId
        };
        final provider = Provider.of<EvaluationPageProvider>(context, listen: false);
        Future.delayed(Duration(seconds: 4), () {
          provider.insertNewCategoryWithQuestion(data);
        });
        if (provider.isBack == true) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: 'Create Category has been Successfully'),
              backgroundColor: Colors.greenAccent,
            ),
          );

          Future.delayed(Duration(seconds: 10), () {
            Navigator.pushReplacementNamed(context, EvaluationHome.routeName);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: 'Create Category has been failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }

    }
  }

  Widget buildAddButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              final EvaluationPageProvider provider =
                  Provider.of<EvaluationPageProvider>(context, listen: false);
              provider.addParentForm();
            },
            child: const Icon(
              Icons.add,
              size: 35,
              color: Colors.white,
            ),
          ),
        ],
      );
}

Widget buildCustomTextFormField({
  required TextEditingController controller,
  required String hint,
  required String validatorMessage,
  IconData? icon,
}) {
  return TextFormField(
    maxLines: null,
    expands: true,
    controller: controller,
    validator: (val) => val != null && val.isEmpty ? validatorMessage : null,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      prefixIcon: icon != null ? Icon(icon) : null,
    ),
  );
}

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double headerHeight;

  _StickyHeaderDelegate({required this.child, required this.headerHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => headerHeight; // Dynamic height
  @override
  double get minExtent => headerHeight; // Should match maxExtent
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Return true if the header might change
  }
}

