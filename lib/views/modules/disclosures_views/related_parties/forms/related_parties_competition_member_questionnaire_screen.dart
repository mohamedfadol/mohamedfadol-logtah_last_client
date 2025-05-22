import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../colors.dart';
import '../../../../../models/competition_model.dart';
import '../../../../../providers/competition_provider_page.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/custom_message.dart';
import '../../../../../widgets/custome_text.dart';
import '../../../../../widgets/loading_sniper.dart';
import '../views/competitions_questions_with_related_parties_list_views.dart';
class RelatedPartiesCompetitionMemberQuestionnaireScreen extends StatefulWidget {
  final String committeeId;
  const RelatedPartiesCompetitionMemberQuestionnaireScreen({super.key, required this.committeeId});
  static const routeName = '/RelatedPartiesCompetitionQuestionnaireScreen';
  @override
  State<RelatedPartiesCompetitionMemberQuestionnaireScreen> createState() => _RelatedPartiesCompetitionMemberQuestionnaireScreenState();
}

class _RelatedPartiesCompetitionMemberQuestionnaireScreenState extends State<RelatedPartiesCompetitionMemberQuestionnaireScreen> {
  final formKey = GlobalKey<FormState>();

  late CompetitionProviderPage provider; // Store provider reference

  @override
  void initState() {
    super.initState();
    // Initialize with empty controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<CompetitionProviderPage>(context, listen: false);
      provider.getListOfCompetitionsQuestionnaireForRelatedParties(provider.yearSelected, widget.committeeId);
      provider.initializeResponseRelatedPartiesControllers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get a reference to the provider
    provider = Provider.of<CompetitionProviderPage>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }


  Widget buildFullTopFilter() {
    return Consumer<CompetitionProviderPage>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 15.0, right: 15.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: "Competition Questionnaire For Related Parties",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
                ),
                const SizedBox(width: 5.0),

                Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, CompetitionsQuestionsWithRelatedPartiesListViews.routeName, arguments: {'committeeId': widget.committeeId});
                      },
                      child: CustomText(
                        text: 'Back',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),

              ],
            ),
          );
        }
    );
  }

  Widget buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  Widget buildLoadingSniper() {
    return const LoadingSniper();
  }

  void _submitForm(BuildContext context) async
  {
    final provider = Provider.of<CompetitionProviderPage>(context, listen: false);

    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate responses using provider method
    if (!provider.validateResponses()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect all answers
    List<Map<String, dynamic>> responses = [];

    provider.textResponses.forEach((questionId, controller) {
      if (controller.text.isNotEmpty || provider.checkboxResponses[questionId] == true) {
        responses.add({
          'question_id': questionId,
          'text_response': controller.text,
          "type": 'competition_with_related_parties',
          'checkbox_selected': provider.checkboxResponses[questionId] ?? false,
        });
      }
    });

    // Prepare data for backend
    Map<String, dynamic> data = {
      "responses": responses,
      "member_id": 83
    };

    // Call provider method to submit responses
    bool success = await provider.submitCompetitionResponses(data);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responses submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear all text fields and reset checkboxes
      provider.clearResponses();

      // Navigate back if needed
      if (provider.isBack) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RelatedPartiesCompetitionMemberQuestionnaireScreen(committeeId: widget.committeeId)));

          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to submit responses'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(),
              // Competition Questionnaire Form
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Consumer<CompetitionProviderPage>(
                      builder: (context, provider, child) {
                        if (provider.competitionsRelatedPartiesData?.competitions == null) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (provider.competitionsRelatedPartiesData!.competitions!.isEmpty) {
                          return Center(
                            child: CustomText(
                              text: "No questions available",
                              fontSize: 16.0,
                            ),
                          );
                        }

                        // Initialize controllers if needed
                        if (provider.textResponses.isEmpty) {
                          for (int i = 0; i < provider.competitionsRelatedPartiesData!.competitions!.length; i++) {
                            final competition = provider.competitionsRelatedPartiesData!.competitions![i];
                            final questionId = competition.competitionId ?? i;

                            // Create controllers if they don't exist
                            provider.textResponses[questionId] = TextEditingController();
                            provider.checkboxResponses[questionId] = false;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Questions and Answers
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: provider.competitionsRelatedPartiesData!.competitions!.length,
                              itemBuilder: (context, index) {
                                CompetitionRelatedPartiesModel question = provider.competitionsRelatedPartiesData!.competitions![index];
                                final questionId = question.competitionId ?? index;

                                // Make sure this question has controllers
                                if (!provider.textResponses.containsKey(questionId)) {
                                  provider.textResponses[questionId] = TextEditingController();
                                  provider.checkboxResponses[questionId] = false;
                                }

                                return QuestionAnswerItem(
                                  questionEn: question.competitionEnName ?? '',
                                  questionAr: question.competitionArName ?? '',
                                  textController: provider.textResponses[questionId]!,
                                  isChecked: provider.checkboxResponses[questionId] ?? false,
                                  onCheckedChanged: (value) {
                                    provider.updateCheckboxResponse(questionId, value ?? false);
                                  },
                                );
                              },
                            ),

                            SizedBox(height: 30),

                            // Submit Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colour().buttonBackGroundRedColor,
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                ),
                                onPressed: provider.isSubmitting
                                    ? null
                                    : () => _submitForm(context),
                                child: provider.isSubmitting
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : CustomText(
                                  text: "Send",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Question Answer item widget
class QuestionAnswerItem extends StatelessWidget {
  final String questionEn;
  final String questionAr;
  final TextEditingController textController;
  final bool isChecked;
  final Function(bool?) onCheckedChanged;

  const QuestionAnswerItem({
    Key? key,
    required this.questionEn,
    required this.questionAr,
    required this.textController,
    required this.isChecked,
    required this.onCheckedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English Question
          CustomText(
            text: questionEn,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),

          // Arabic Question
          if (questionAr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomText(
                  text: questionAr,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),

          SizedBox(height: 16),

          // Text Answer Field
          TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Your Answer",
              border: OutlineInputBorder(),
              hintText: "Enter your response",
            ),
            maxLines: 3,
          ),

          SizedBox(height: 12),

          // Checkbox for yes/no or agreement
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: onCheckedChanged,
              ),
              Flexible(
                child: CustomText(
                  text: "I confirm this information is correct",
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

