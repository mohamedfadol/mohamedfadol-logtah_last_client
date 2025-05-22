
import 'dart:convert';

UserModel  userFromJson(String user) => UserModel.formJsonToObject(json.decode(user));
class UserModel {
  User user;
  String token;
  bool resetPasswordRequest;

  UserModel({ required this.user,required this.token, required this.resetPasswordRequest});


  factory UserModel.formJsonToObject(Map<String, dynamic> json) =>
      UserModel(
            user: User.fromJson(json['user']),
            token: json['token'],
            resetPasswordRequest: json['reset_password_request']
      );

  Map<String,dynamic> toJson() => {
    "user": user.toJson(),
    "token": token,
    "reset_password_request": resetPasswordRequest
  };

}
// to create constructor of UserModel use below code
// user = UserModel(String user, String token);

class User{
 final int? userId;
 final String? name;
 final String? userName;
 final String? profileImage;
 final String? email;
 final String? firstName;
 final String? lastName;
 final String? userType;
 final String? mobile;
 final String? biography;
 final int? businessId;
 final bool? resetPasswordRequest;

  User({this.userId, this.name,this.userName, this.email,this.firstName, this.lastName, this.userType ,this.mobile,this.biography,this.profileImage,this.businessId, this.resetPasswordRequest});

  // create new converter
  factory User.fromJson(Map<String, dynamic> json) =>
      User(
        userId: json['id'],
        name: json['member_first_name'],
        userName: json['member_first_name'],
        email: json['member_email'],
        firstName: json['member_first_name'],
        lastName: json['member_middel_name'],
        userType: json['member_type'],
        mobile: json['member_mobile'],
        biography: json['member_biography'],
        profileImage: json['member_profile_image'],
        businessId: json['business_id'],
          resetPasswordRequest: json['reset_password_request']
      );

  Map<String,dynamic> toJson() => {
    "id": userId,
    "member_first_name": name,
    "member_first_name": userName,
    "member_email": email,
    "member_first_name": firstName,
    "member_last_name": lastName,
    "member_type": userType,
    "member_mobile": mobile,
    "member_biography": biography,
    "member_profile_image": profileImage,
    "business_id": businessId,
    "reset_password_request": resetPasswordRequest
  };

}