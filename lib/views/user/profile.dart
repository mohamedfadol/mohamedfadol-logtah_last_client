
import 'package:diligov_members/views/user/edit_profile.dart';
import 'package:diligov_members/views/user/user_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/authentications/user_provider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custome_text.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ProfileUser extends StatelessWidget {
  const ProfileUser({Key? key}) : super(key: key);
  static const routeName = '/profileUser';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          surfaceTintColor: Colors.grey,
          child: Consumer<UserProfilePageProvider>(
            builder: (context, provider, child) {
              if (provider.user! == null) {
                provider.getUserProfile();
                return Center(
                  child: SpinKitThreeBounce(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: index.isEven ? Colors.red : Colors.green,
                        ),
                      );
                    },
                  ),
                );
              }
              return provider.user!.email!.isEmpty
                  ? buildEmptyContainerNotes()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20.0, top: 35.0),
                              child: CircleAvatar(
                                  backgroundColor: Colors.brown.shade800,
                                  radius: 50,
                                  child: Image.network('https://diligov.com/public/profile_images/${provider.user.profileImage}')
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 40.0),
                              child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserEditProfile(editUser: provider.user!,))) ,
                                  icon: CustomIcon(icon:Icons.edit,color: Colors.green,size:25),
                                  label: CustomText(text: 'edit profile',color: Colors.black,fontSize: 18.0,)
                              ),
                            ),



                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'User Name'),
                                subtitle: CustomText(
                                  text: '${provider.user?.userName.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'First Name'),
                                subtitle: CustomText(
                                  text: '${provider.user?.firstName.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'Last Name'),
                                subtitle: CustomText(
                                  text: '${provider.user?.lastName.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'Title Name'),
                                subtitle: CustomText(
                                  text:
                                      '${provider.user?.userType.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'E-mail Address'),
                                subtitle: CustomText(
                                  text: '${provider.user?.email.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: CustomText(text: 'Phone Number'),
                                subtitle: CustomText(
                                  text: '${provider.user?.mobile.toString()}',
                                  color: Colors.grey,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: CustomText(text: 'Biography'),
                            ),
                            subtitle: Container(
                              width: 300,
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              color: Colors.grey[200],
                              child: CustomText(
                                text:
                                provider.user?.biography.toString() ?? '',
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      )),
    );
  }

  Widget buildEmptyContainerNotes() {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CustomText(
            text: 'no data to show',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ));
  }
}
