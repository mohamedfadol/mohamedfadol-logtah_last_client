import 'package:diligov_members/colors.dart';
import 'package:diligov_members/views/auth/password_screen.dart';
import 'package:diligov_members/views/dashboard/dashboard_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../providers/authentications/auth_provider.dart';
import '../../widgets/custome_password_form_field.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/menu_button.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ResetPasswordScreen extends StatefulWidget with InputValidationMixin {
  ResetPasswordScreen({super.key});
  static const routeName = '/resetPasswordScreen';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _passwordConfirmation = TextEditingController();

  String? oldPasswordError;
  String? newPasswordError;
  String? confirmationPasswordError;

  @override
  void initState() {
    super.initState();

    _newPassword.addListener(_validatePasswords);
    _passwordConfirmation.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      oldPasswordError = null;
      newPasswordError = null;
      confirmationPasswordError = null;

      if (_newPassword.text == _oldPassword.text) {
        newPasswordError = 'New password cannot be the same as the old password';
      }

      if (_newPassword.text != _passwordConfirmation.text) {
        confirmationPasswordError = 'New password and confirmation do not match';
      }
    });
  }

  @override
  void dispose() {
    _newPassword.removeListener(_validatePasswords);
    _passwordConfirmation.removeListener(_validatePasswords);
    _oldPassword.dispose();
    _newPassword.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 800 ? 150.0 : 150.0;
            double verticalPadding = constraints.maxHeight > 600 ? 30.0 : 10.0;

            return Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Center(
                  child: Form(
                    key: formGlobalKey,
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                      children: [
                        CustomText(text: 'Reset Password', fontSize: 24, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
                        const SizedBox(height: 20),

                        // Old Password Field
                        CustomPasswordFormField(
                          valid: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter a valid oldest password';
                            } else {
                              return null;
                            }
                          },
                          obscureText: provider.isOldPasswordObscured,
                          myController: _oldPassword,
                          hintText: "Enter Your Oldest Password",
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              provider.isOldPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: provider.toggleOldPasswordVisibility,
                          ),
                          borderRadius: 20,
                          labelText: "Oldest Password",
                          toggleVisibility: () => provider.isOldPasswordObscured,
                          errorText: oldPasswordError,
                        ),
                        const SizedBox(height: 20),

                        // New Password Field
                        CustomPasswordFormField(
                          valid: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter a valid new password';
                            } else {
                              return null;
                            }
                          },
                          obscureText: provider.isNewPasswordObscured,
                          myController: _newPassword,
                          hintText: "Enter Your New Password",
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              provider.isNewPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: provider.toggleNewPasswordVisibility,
                          ),
                          borderRadius: 20,
                          labelText: "New Password",
                          toggleVisibility: () => provider.toggleNewPasswordVisibility,
                          errorText: newPasswordError,
                        ),
                        const SizedBox(height: 20),

                        // Confirmation Password Field
                        CustomPasswordFormField(
                          valid: (val) {
                            if (val == null || val.isEmpty || val != _newPassword.text) {
                              return 'Passwords do not match';
                            } else {
                              return null;
                            }
                          },
                          obscureText: provider.isConfirmPasswordObscured,
                          myController: _passwordConfirmation,
                          hintText: "Enter Your Confirmation Password",
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              provider.isConfirmPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: provider.toggleConfirmPasswordVisibility,
                          ),
                          borderRadius: 20,
                          labelText: "Confirmation Password",
                          toggleVisibility: () => provider.toggleConfirmPasswordVisibility,
                          errorText: confirmationPasswordError,
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                          child: Material(
                            color: Colour().buttonBackGroundRedColor,
                            elevation: 10,
                            borderRadius: BorderRadius.circular(30),
                            child: TextButton(
                              onPressed: () {
                                if (formGlobalKey.currentState!.validate()) {
                                  formGlobalKey.currentState!.save();
                                  _changePassword(context, authProvider);
                                } else {
                                  Flushbar(
                                    title: AppLocalizations.of(context)!.invalid_information_login,
                                    message: AppLocalizations.of(context)!.please_insert_correct_details,
                                    duration: const Duration(seconds: 10),
                                  ).show(context);
                                }
                              },
                              child: authProvider.loading
                                  ? const CircularProgressIndicator(color: Colors.white,)
                                  : MenuButton(
                                text: 'Change Password',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _changePassword(BuildContext context, AuthProvider authProvider) async {
    // Assuming a method like `changePassword` exists in your AuthProvider
    final tokenCode = await FirebaseMessaging.instance.getToken();

    Map<String, dynamic> data  = {
      'old_password':  _oldPassword.text.toString(),
      'password': _newPassword.text.toString(),
      'password_confirmation':  _passwordConfirmation.text.toString(),
      'token': tokenCode!
    };

    await authProvider.changePassword(data);
    if (authProvider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: 'Update Password Has Been Updated'),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DashboardHomeScreen(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: 'Update Password Has Been Updated Failed'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
