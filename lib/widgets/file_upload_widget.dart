import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diligov_members/providers/file_upload_page_provider.dart';
import 'package:diligov_members/widgets/custom_icon.dart';

import 'custome_text.dart';

class FileUploadWidget extends StatelessWidget {
  final List<String> allowedExtensions;
  final String labelName;
  final Function(String fileName, String fileContent)
  onFilePicked;
  final FileUploadPageProvider provider;

  FileUploadWidget({
    required this.allowedExtensions,
    required this.onFilePicked,
    required this.labelName,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FileUploadPageProvider>.value(
      value: provider,
      child: Consumer<FileUploadPageProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.isLoading) ...[
                CircularProgressIndicator(),
                SizedBox(height: 7),
              ],
              if (provider.errorMessage != null) ...[
                CustomText(text: provider.errorMessage!, color: Colors.red),
                SizedBox(height: 7),
              ],
              // if(provider.pickedFiles!.length >= 0 )
              // IconButton(
              //     onPressed: () => provider.clearAllFiles(),
              //     icon: CustomIcon(icon: Icons.clear_all,color: Colors.red,)
              // ),
              Container(
                width: 400,
                height: 50,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: Colors.grey[400], border: Border.all(width: 0.1)),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.pickedFiles?.length ?? 0,
                  itemBuilder: (context, index) {
                    final file = provider.pickedFiles![index];
                    return Container(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Chip(
                        label: CustomText(text: file.name),
                        onDeleted: () {
                          provider.clearFiles(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20)),
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () async {
                  await provider.pickFiles(allowedExtensions);
                  if (provider.pickedFiles != null &&
                      provider.fileBase64.isNotEmpty) {
                    String fileName = provider.pickedFile!.name;
                    onFilePicked(fileName, provider.oneFileBase64!);
                  }
                },
                child: CustomText(
                    text: labelName,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          );
        },
      ),
    );
  }
}
