import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:diligov_members/views/user/profile.dart';
import 'package:diligov_members/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../../models/user.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../providers/authentications/user_provider.dart';
import '../../utility/signature_perview.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/edit_form_text_field.dart';

class UserEditProfile extends StatefulWidget {
  final User? editUser;
  const UserEditProfile({super.key, required this.editUser});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  final editUserProfileFormGlobalKey = GlobalKey<FormState>();
  late SignatureController signController;
  Uint8List? signature;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  var userId;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _userType = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _biography = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = widget.editUser!;
    userId = user.userId!;
    _firstName.text = user.firstName!;
    _lastName.text = user.lastName ??'';
    _userType.text = user.userType ?? '';
    _mobile.text = user?.mobile ?? '';
    _email.text = user.email!;
    _biography.text = user?.biography ?? '';
    signController = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 1,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    signController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _userType.dispose();
    _mobile.dispose();
    _email.dispose();
    _biography.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String? _imageBase64;
    String? _imageName;
    Uint8List? uploadSignature;

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: Header(context),
        body: Form(
          key: editUserProfileFormGlobalKey,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                  child: Row(
                    children: [
                      imageProfile(),
                      SizedBox(width: 15.0,),
                      InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: ((builder) => bottomSheet()),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              'Change Picture',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: EditFormTextField(
                          // hintText: user.firstName.toString(),
                          valid: (val) {
                            if (val!.isEmpty)
                              return "First Name Can'\t be Empty";
                            else
                              return null;
                          },
                          myController: _firstName,
                          text: 'First Name',
                          color: Theme.of(context).iconTheme.color,
                          fontsize: 20,
                          Fontweight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 15.0,),
                      Expanded(
                          child: EditFormTextField(
                            // hintText: user.lastName,
                            valid: (val) {
                              if (val!.isEmpty)
                                return "Last Name Can'\t be Empty";
                              else
                                return null;
                            },
                            myController: _lastName,
                            text: 'Last Name',
                            color: Theme.of(context).iconTheme.color,
                            fontsize: 20,
                            Fontweight: FontWeight.bold,
                          )),
                      SizedBox(width: 15.0,),
                      Expanded(
                          child: EditFormTextField(
                            // hintText: user.userType,
                            myController: _userType,
                            valid: (String? val) {
                              if (val!.isEmpty)
                                return "Title Name Can'\t be Empty";
                              else
                                return null;
                            },
                            text: 'Title Name',
                            color: Theme.of(context).iconTheme.color,
                            fontsize: 20,
                            Fontweight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: EditFormTextField(
                            // hintText: user.userType,
                            myController: _mobile,
                            valid: (String? val) {
                              if (val!.isEmpty)
                                return "Mobile Number Can'\t be Empty";
                              else
                                return null;
                            },
                            text: 'Mobile Number',
                            color: Theme.of(context).iconTheme.color,
                            fontsize: 20,
                            Fontweight: FontWeight.bold,
                          )),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: EditFormTextField(
                            // hintText: user.email,
                            myController: _email,
                            valid: (String? val) {
                              if (val!.isEmpty)
                                return "Email ID Can'\t be Empty";
                              else
                                return null;
                            },
                            text: 'Email ID',
                            color: Theme.of(context).iconTheme.color,
                            fontsize: 20,
                            Fontweight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                            height: 150,
                            // width: 300.0,
                            child: Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    expands: true,
                                    controller: _biography,
                                    maxLines: null, //or null
                                    decoration:
                                    const InputDecoration.collapsed(
                                        hintText: "Enter your text here"),
                                  ),
                                ))),
                      ),

                      Expanded(
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              CustomText(
                                text: 'Your Signature',
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Signature(
                                controller: signController,
                                backgroundColor: Colors.red,
                                height: 100,
                                width: 300,
                              ),
                              buildButton(context),
                              // signature != null ? Image.memory(signature!) : Text('no signed')
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (editUserProfileFormGlobalKey.currentState!
                                      .validate()) {
                                    editUserProfileFormGlobalKey.currentState!
                                        .save();
                                    // use the email provided here
                                    if (_imageFile != null) {
                                      final imageBase64 = base64.encode(File(_imageFile!.path).readAsBytesSync());
                                      String imageName = _imageFile!.path.split("/").last;
                                      setState(() {
                                        _imageBase64 = imageBase64;
                                        _imageName = imageName;
                                      });
                                    }

                                    if(signature != null){
                                      final  uploadSignature =  base64.encode(signature!);
                                      setState(() {
                                      final  uploadSignature =  base64.encode(signature!);
                                      });
                                    }
                                    Map<String, dynamic> data = {
                                      'id': userId.toString(),
                                      'first_name': _firstName.text.toString(),
                                      'last_name': _lastName.text.toString(),
                                      'email': _email.text.toString(),
                                      'user_type': _userType.text.toString(),
                                      'contact_number': _mobile.text.toString(),
                                      "biography": _biography.text.toString(),
                                      'profile_image': _imageName ?? null,
                                      'imageSelf': _imageBase64 ?? null,
                                      "uploadSignature": uploadSignature ?? null
                                    };
                                    final Future<Map<String, dynamic>>
                                    response = authProvider.updateProfile(data);
                                    response.then((response) {
                                      if (response['status']) {
                                        User user = response['user'];
                                        Provider.of<UserProfilePageProvider>(context,
                                            listen: false)
                                            .setUser(user);
                                        Navigator.pushReplacementNamed(
                                            context, ProfileUser.routeName);
                                      } else {
                                        Flushbar(
                                          title: "Update Profile Failed",
                                          message:
                                          response['message'].toString(),
                                          duration: Duration(seconds: 6),
                                          backgroundColor: Colors.redAccent,
                                          titleColor: Colors.white,
                                          messageColor: Colors.white,
                                        ).show(context);
                                      }
                                    });
                                  } else {
                                    Flushbar(
                                      title: "Invalid Information's",
                                      message: "please insert correct details",
                                      duration: const Duration(seconds: 10),
                                    ).show(context);
                                  }
                                },
                                child: authProvider.loading
                                    ? CircularProgressIndicator(
                                  color: Colors.green,
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                        BorderRadius.circular(20.0),
                                      ),
                                      child: const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/profileUser');
                                      },
                                      child: Container(
                                        margin:
                                        EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                          BorderRadius.circular(20.0),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget bottomSheet() {
    return Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Text('Choose an Photo', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              icon: Icon(
                Icons.camera,
                size: 24.0,
              ),
              label: Text('Camera'), // <-- Text
            ),
            SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              icon: Icon(
                Icons.image,
                size: 24.0,
              ),
              label: Text('Gallery'), // <-- Text
            ),
          ])
        ]));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.brown.shade800,
            radius: 70.0,
            backgroundImage: _imageFile == null
                ? AssetImage("assets/images/profile.jpg") as ImageProvider
                : FileImage(File(_imageFile!.path)),
          ),
          Positioned(
              child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => bottomSheet()),
                    );
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.teal,
                  )))
        ],
      ),
    );
  }

  Future<XFile?> takePhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });
  }

  Widget buildButton(BuildContext context) => Container(
        color: Colors.black,
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buildSave(context), buildClear()],
        ),
      );

  buildSave(BuildContext context) => IconButton(
      onPressed: () async {
        if (signController.isNotEmpty) {
          signature = await exportSignature();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignaturePerview(signature: signature!),
          ));
        }
      },
      icon: const Icon(
        Icons.save,
        color: Colors.green,
      ));

  buildClear() => IconButton(
      onPressed: () {
        signController.clear();
      },
      icon: const Icon(
        Icons.clear,
        color: Colors.green,
      ));

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: signController.points,
    );
    signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }
}

