import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../providers/localizations_provider.dart';
class DropdownListLanguagesWidget extends StatelessWidget {
  const DropdownListLanguagesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerLanguage = Provider.of<LocalizationsProvider>(context);
    final locale = providerLanguage.locale;
    return Container(
      padding: EdgeInsets.only(left: 9, right: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
          ]
      ),
      child: DropdownButtonHideUnderline(
          child: DropdownButton(
            padding: EdgeInsets.all(0),
            // alignment: AlignmentDirectional.centerStart,
            hint: Image.asset('images/iconsFroLightMode/language_button.png',height: 30,width: 30),
            value: locale,
            icon: SizedBox(width: 0, height: 0),
            iconSize: 0.0,
            items: L10n.all.map((locale){
              final flag = L10n.getFlag(locale.languageCode);
              return DropdownMenuItem(
                  child: Center(
                    child: CustomText(text:flag,fontSize: 30.0),
                  ),
                value: locale,
                onTap: (){
                  final localeLanguage = Provider.of<LocalizationsProvider>(context,listen: false);
                  localeLanguage.setLocale(locale);
                },
              );
            }
            ).toList(),
            onChanged: (_){

            },
          )
      ),
    );
  }
}
