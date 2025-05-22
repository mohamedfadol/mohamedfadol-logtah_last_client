import 'package:diligov_members/models/question_model.dart';
import 'package:diligov_members/models/user.dart';

import 'business_model.dart';

class Categories {
  List<Category>? categories;
  Categories.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Category>[];
      json['categories'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
  }
}

class Category{
  int? categoryId;
  String? categoryName;
  int? businessId;
  int? createdBy;
  List<QuestionModel>? questions;
  // User? user;
  Business? business;


  Category(
      {this.categoryId,
        this.categoryName,
        this.createdBy,
        this.businessId,
        this.questions,
        // this.user,
        this.business,
      });

  // create new converter
  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['id'];
    categoryName = json['category_name'];
    createdBy = json['created_by'];
    businessId = json['business_id'];
    // user = User?.fromJson(json['user']);
    if (json['questions'] != null) {
      questions = <QuestionModel>[];
      json['questions'].forEach((v) {
        questions!.add(QuestionModel.fromJson(v));
      });
    }
    business = Business?.fromJson(json['business']);

  }


}