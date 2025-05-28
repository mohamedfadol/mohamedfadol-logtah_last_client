import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../models/member.dart';
import '../../../models/member_criteria.dart';
import '../../../models/user.dart';
import '../../../providers/evaluation_page_provider.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class MemberEvaluationDetails extends StatefulWidget {
  final Member member;
  MemberEvaluationDetails({Key? key, required this.member}) : super(key: key);

  @override
  State<MemberEvaluationDetails> createState() =>
      _MemberEvaluationDetailsState();
}

class _MemberEvaluationDetailsState extends State<MemberEvaluationDetails> {
  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  bool isLoading = false;
  bool isShow = false;
  bool isSelectedRow = true;
  // Initial Selected Value
  String yearSelected = '2023';
  bool isPressed = false;
  String msg = 'index';
  // List of items in our dropdown menu
  var yeasList = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
    '2032'
  ];

  @override
  void initState() {
    widget.member.memberId;
    super.initState();
    // TODO: implement initState
  }

  double? total = 0;
  List<int> degrees = [];
  List<MemberCriteria> criteriaDegreeList = [];

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
      appBar: AppBar(
        leading: const CloseButton(),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Consumer<EvaluationPageProvider>(
            builder: (BuildContext context, provider, widget) {
          if (provider.dataOfCategories?.categories == null) {
            provider.getListOfEvaluationsCategoriesWithQuestions();
            return buildLoadingSniper();
          }

          // Build category-question mapping once
          if (provider.getCategoryQuestions().isEmpty) {
            final Map<int, List<int>> categoryQuestionsMap = {};
            for (final category in provider.dataOfCategories!.categories!) {
              categoryQuestionsMap[category.categoryId!] = category.questions!
                  .map((question) => question.questionId!)
                  .toList();
            }
            provider.setCategoryQuestions(categoryQuestionsMap);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildFullTopFilter(),
              buildFullNameOfMember(),
              provider.dataOfCategories!.categories!.isEmpty
                  ? buildEmptyMessage(
                      AppLocalizations.of(context)!.no_data_to_show)
                  : Form(
                      key: _formKey,
                      child: Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 25.0, horizontal: 30.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: 1,
                                    itemBuilder: (BuildContext cont, int i) {
                                      return SingleChildScrollView(
                                        child: MemberEvaluationWidget(memberId: this.widget.member.memberId!),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 330,
                                  child: buildRightSideDetails(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          );
        }),
      ),
    );
  }


  Widget buildRightSideDetails() {

    return Consumer<EvaluationPageProvider>(
        builder: (BuildContext context, provider, widget){
          final overallAverage = provider.calculateOverallAverage(this.widget.member.memberId!);
          return Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'OverAll',
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(
                    width: 30.0,
                  ),
                  buildDegreeContainer(Colors.white, Colors.black, '${overallAverage.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(
                thickness: 3,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: CircleAvatar(
                    backgroundColor: overallAverage < 3 ? Colors.red : Colors.green,
                    radius: 100,
                    child: Container(
                        width: 190.0,
                        height: 190.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                            child: CustomText(
                              text: '${overallAverage.toStringAsFixed(2)} %',
                              color: overallAverage < 3 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0,
                            )))),
              ),
              const SizedBox(
                height: 40.0,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                color: Colors.red,
                child: TextButton(
                    onPressed:() {
                      onSubmit(context);
                    },
                    child: CustomText(
                      text: 'Save & Continue',
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              )
            ],
          );
        }
    );
  }


  void onSubmit(BuildContext context) {
    final provider = Provider.of<EvaluationPageProvider>(context, listen: false);
    final isValid = provider.validateMemberAnswers(this.widget.member.memberId!);

    if (isValid) {
      provider.submitMemberAnswers(this.widget.member.memberId!).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Answers submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit answers."),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please answer all questions before submitting."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Widget buildFullTopFilter() => Padding(
        padding:
            const EdgeInsets.only(top: 3.0, left: 10.0, right: 8.0, bottom: 8.0),
        child: Consumer<EvaluationPageProvider>(
            builder: (BuildContext context, provider, child) {
            return Row(
              children: [

                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 15.0),
                    color: Colour().buttonBackGroundMainColor,
                    child: CustomText(
                        text: 'Evaluations Details',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5.0,
                ),


                Container(
                  width: 200,
                  padding:
                  const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(
                        text: AppLocalizations.of(context)!.select_year,
                        color: Colour().mainWhiteTextColor),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      // await provider.getListOfMinutes(provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                )
              ],
            );
          }
        ),
      );

  Widget buildFullNameOfMember() => Row(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 10.0, top: 10.0),
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey,
              child: CustomText(
                text: "${widget!.member!.fullName!}" ,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ],
      );

  Widget buildDegreeContainer(Color? textColor, Color? bgContainerColor, String text) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
          // width: 60,
          decoration: BoxDecoration(
            color: bgContainerColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
              child: CustomText(
            text: text,
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.bold,
          )));
}

class MemberEvaluationWidget extends StatefulWidget {
  final int memberId;

  MemberEvaluationWidget({required this.memberId});

  @override
  _MemberEvaluationWidgetState createState() => _MemberEvaluationWidgetState();
}

class _MemberEvaluationWidgetState extends State<MemberEvaluationWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<EvaluationPageProvider>(
        builder: (BuildContext context, provider, widget) {
          final categories = provider.dataOfCategories?.categories ?? [];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView.separated(
                shrinkWrap: true, // Ensures it doesn't take infinite height
                physics: NeverScrollableScrollPhysics(), // Prevents ListView from scrolling independently
                itemCount: categories.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryId = category.categoryId!;
                  final isExpanded = provider.isCategoryExpanded(categoryId);
                  final categoryAverage = provider.calculateCategoryAverage(this.widget.memberId, categoryId);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isExpanded ? Colors.blue[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: CustomText(
                            text: '${category.categoryName}',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isExpanded ? SizedBox.shrink() : CustomText(
                                text: 'Category Result: ${categoryAverage.toStringAsFixed(2)}',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: categoryAverage < 3 ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: 10,),
                              CustomIcon(icon: isExpanded ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                          onTap: () {
                            provider.toggleCategoryExpanded(categoryId);
                          },
                          tileColor: provider.isSelected ? Colors.red : null,
                          selectedColor: Colors.grey,
                          selected: true,
                          hoverColor: Colors.grey[200],
                        ),
                      ),
                      // Show questions and average only if expanded
                      if (isExpanded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...category.questions!.map((question) {
                              return QuestionEvaluationWidget(
                                memberId: this.widget.memberId,
                                questionId: question.questionId!,
                                questionText: question.question!,
                              );
                            }).toList(),
                            SizedBox(height: 5),
                            CustomText(
                              text: 'Category Result: ${categoryAverage.toStringAsFixed(2)}',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: categoryAverage < 3 ? Colors.red : Colors.green,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          );

        });
  }
}


class QuestionEvaluationWidget extends StatelessWidget {
  final int memberId;
  final int questionId;
  final String questionText;

  QuestionEvaluationWidget(
      {required this.memberId,
      required this.questionId,
      required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Consumer<EvaluationPageProvider>(
        builder: (context, provider, widget) {
      final currentScore = provider.getScore(memberId, questionId);
      final unansweredQuestions = provider.getUnansweredQuestions(memberId);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text:'$questionText',color: unansweredQuestions.contains(questionId) ? Colors.red : Colors.black,),
          Row(
            children: List.generate(5, (index) {
              final score = index + 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(text:'$score',color: unansweredQuestions.contains(questionId) ? Colors.red : Colors.black,),
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: currentScore >= score ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () =>
                        provider.updateScore(memberId, questionId, score),
                  ),
                ],
              );
            }),
          ),
        ],
      );
    });
  }
}
