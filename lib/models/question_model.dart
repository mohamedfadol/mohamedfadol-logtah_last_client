class QuestionModel {
  int? questionId;
  String? question;

  QuestionModel({this.questionId,  this.question,});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    questionId = json['id'];
    question = json['question'];

  }


}