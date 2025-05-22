import 'package:diligov_members/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images_assets.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../widgets/custome_text_form_field.dart';

import 'package:another_flushbar/flushbar.dart';
import '../../widgets/assets_widgets/asset_general.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/drowpdown_list_languages_widget.dart';
import '../../widgets/menu_button.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class PasswordScreen extends StatelessWidget with InputValidationMixin{
   PasswordScreen({Key? key}) : super(key: key);
  static const routeName = '/PasswordScreen';


  final formGlobalKey = GlobalKey<FormState>();
   // final TextEditingController _email = TextEditingController();
   final TextEditingController _email = TextEditingController(text: 'mohamedtapo@gmail.com');

   @override
   Widget build(BuildContext context) {

     SystemChrome.setPreferredOrientations([
       DeviceOrientation.landscapeLeft,
       DeviceOrientation.landscapeRight,
     ]);

     final authProvider = Provider.of<AuthProvider>(context);
     return WillPopScope(
       onWillPop: () async {
         // Reset to default orientation when leaving the screen
         SystemChrome.setPreferredOrientations(DeviceOrientation.values);
         return true;
       },
       child: Scaffold(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
         body: SafeArea(
           child: Consumer<AuthProvider>(
             builder: (context, provider, child){
               return Form(
                 key: formGlobalKey,
                 child: Center(
                   child: ListView(
                     children: [
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             const DropdownListLanguagesWidget(),
                             AssetGeneral(image: ImagesAssets.onOffButton,height: 40,width: 40,),
                           ],
                         ),
                       ),
                       Container(
                         height: 300,
                         alignment: Alignment.center, // This is needed
                         child: Image.asset(
                           ImagesAssets.loginLogo,
                           fit: BoxFit.contain,
                           width: 300,
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 150.0),
                         child: CustomTextFormField(
                           valid: (val){if (isEmailValid(val!) && val.isNotEmpty ) {return null;} else {return 'Enter a valid email address';}},
                           myController: _email,
                           hintText: "Enter Your E-mail",
                           prefixIcon: Icons.email,
                           borderRadius: 20,
                           lableText: "E-mail",
                         ),
                       ),

                       const SizedBox(height:25),
                       Container(
                         margin: const EdgeInsets.symmetric(horizontal: 500),
                         padding: const EdgeInsets.symmetric(horizontal: 50),
                         child: Material(
                           color: Colors.red,
                           elevation: 10,
                           borderRadius: BorderRadius.circular(30),
                           child: TextButton(
                             style: TextButton.styleFrom(
                               padding: const EdgeInsets.symmetric(vertical: 10),
                               textStyle: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                             ),
                             onPressed: () {
                               if (formGlobalKey.currentState!.validate()) {
                                 formGlobalKey.currentState!.save();
                                 _resetPass(context, authProvider);
                               } else {
                                 Flushbar(
                                   title: AppLocalizations.of(context)!.invalid_information_login,
                                   message: AppLocalizations.of(context)!.please_insert_correct_details,
                                   duration: const Duration(seconds: 10),
                                 ).show(context);
                               }
                             },
                             child: authProvider.loading ? const CircularProgressIndicator(color: Colors.white,) : MenuButton(text: AppLocalizations.of(context)!.send_email,fontSize: 20.0,fontWeight: FontWeight.bold,),
                           ),
                         ),
                       ),
                       // LanguageWidget(),
                       // DropdownListLanguagesWidget(),
                       const SizedBox(height:25),
                       Center(
                         // margin: const EdgeInsets.symmetric(horizontal: 570),
                         child: InkWell(
                           onTap: (){
                             Navigator.of(context).pushReplacement(
                               MaterialPageRoute(
                                 builder: (context) => LoginScreen(),
                               ),
                             );
                           },
                           child: CustomText(text: AppLocalizations.of(context)!.login,fontSize: 15,fontWeight: FontWeight.bold),
                         ),
                       ),
                     ],
                   ),
                 ),
               );
             },
           ),
         ),
       ),
     );
   }

   void _resetPass(BuildContext context, AuthProvider authProvider) {
     final Future<Map<String, dynamic>> response = authProvider.resetPassword(_email.text.toString());
     response.then((response) async {
       if (response['status']) {
         Navigator.pushReplacementNamed(context, '/loginPage');
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
             content: CustomText(text: response['message'].toString()),
               duration: Duration(seconds: 3),
               backgroundColor: Colors.green,
           ),
         );

       } else {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
             content: Text(response['message'].toString()),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
           ),
         );
       }
     });
   }

}



mixin InputValidationMixin {
  bool isPasswordValid(String val) => val.length >= 6; // Allow passwords of 6 or more characters

  bool isEmailValid(String val) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(val);
  }
}
