import 'package:diligov_members/views/auth/password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../colors.dart';
import '../../models/user.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../providers/authentications/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/actions_icon_bar_widget.dart';
import '../../widgets/custome_password_form_field.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/custome_text_form_field.dart';
import '../../widgets/drowpdown_list_languages_widget.dart';
import '../../widgets/menu_button.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class LoginScreen extends StatelessWidget with InputValidationMixin{
  final player = AudioPlayer();
  LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/loginPage';
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController(text: 'mohamedtapo@gmail.com');
  final TextEditingController _password = TextEditingController(text: '123456789');


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    String iconPath = themeProvider.getIconPath;  // Get the dynamic icon path
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ?  Colour().lightContainerColor : Colour().darkContainerColor ;

    return  WillPopScope(
      onWillPop: () async {
        // Reset to default orientation when leaving the screen
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        return true;
      },
      child: Scaffold(
          body: Consumer<AuthProvider>(
            builder: (context, provider, child){
              return Center(
                child: Form(
                  key: formGlobalKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const DropdownListLanguagesWidget(),
                            ActionsIconBarWidget(
                              onPressed: () {
                                bool value = themeProvider.isDarkMode ? false : true;
                                final provider = Provider.of<ThemeProvider>(context, listen: false);
                                provider.toggleTheme(value);
                              },
                              buttonIcon: Icons.brightness_medium,
                              buttonIconColor: Theme.of(context).iconTheme.color,
                              buttonIconSize: 30,
                              boxShadowColor: Colors.grey,
                              boxShadowBlurRadius: 2.0,
                              boxShadowSpreadRadius: 0.4,
                              containerBorderRadius: 30.0,
                              containerBackgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 300,
                        alignment: Alignment.center, // This is needed
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double imageSize = constraints.maxWidth * 0.2; // 20% of the parent's width
                            return Image.asset(
                              iconPath,
                              width: imageSize,
                              height: imageSize,
                            );
                          },
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 150.0),
                        child: CustomPasswordFormField(
                            valid: (val){
                              if (val == null ) {return 'Enter a valid password';} else {return null;}
                            },
                            obscureText: provider.isObscured,
                            myController: _password,
                            hintText: "Enter Your Password",
                            prefixIcon: Icons.keyboard_alt_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                provider.isObscured ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: provider.toggleVisibility,
                            ),
                            borderRadius: 20,
                          labelText: "Password",
                          toggleVisibility: provider.toggleVisibility,
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
                                _login(context, authProvider);
                              } else {
                                Flushbar(
                                  title: AppLocalizations.of(context)!.invalid_information_login,
                                  message: AppLocalizations.of(context)!.please_insert_correct_details,
                                  duration: const Duration(seconds: 10),
                                ).show(context);
                              }
                            },
                            child: authProvider.loading ? const CircularProgressIndicator(color: Colors.white,) : MenuButton(text: AppLocalizations.of(context)!.login,fontSize: 20.0,fontWeight: FontWeight.bold, color: containerColor),
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
                                builder: (context) => PasswordScreen(),
                              ),
                            );
                          },
                          child: CustomText(text: AppLocalizations.of(context)!.forget_password,fontSize: 15,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ),
    );
  }

  void _login(BuildContext context, AuthProvider authProvider) {
    final Future<Map<String, dynamic>> response = authProvider.login(_email.text.toString(), _password.text.toString());
    response.then((response) async {
      if (response['status']) {
        UserModel user = response['user'];
        Provider.of<UserProfilePageProvider>(context, listen: false).setUser(user.user);
        if(user.user.resetPasswordRequest! == true){
          print(' snapshot.data!.resetPasswordRequest! ${user.user.resetPasswordRequest!}');

          Navigator.pushReplacementNamed(context, '/resetPasswordScreen');
        }else{
          Navigator.pushReplacementNamed(context, '/dashboardHome');
          player.play(AssetSource('audio/play_login.mp3'));
        }
      } else {
        Flushbar(
          title: AppLocalizations.of(context)!.login_failed,
          message: response['message'].toString(),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.redAccent,
          titleColor: Colors.white,
          messageColor: Colors.white,
        ).show(context);
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



