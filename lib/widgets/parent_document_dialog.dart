import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_page_provider.dart';

class ParentDocumentDialog extends StatelessWidget {
  final int index;
  final DocumentPageProvider provider; // You can pass in any provider you use

  const ParentDocumentDialog({
    Key? key,
    required this.index,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<DocumentPageProvider>(context, listen: false)
          .getListOfDocuments(), // Fetch the documents
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final provider = Provider.of<DocumentPageProvider>(context);

        // Check if the document data is available
        if (provider.documentData?.documents == null ||
            provider.documentData!.documents!.isEmpty) {
          return const Center(child: Text('No data to show'));
        }

        // Ensure selectedDocumentId list has enough elements
        if (index >= provider.selectedDocumentId!.length) {
          provider.selectedDocumentId!.addAll(
            List.filled(index - provider.selectedDocumentId!.length + 1, null),
          );
        }

        // Build the dialog content
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
                CustomText(
                text: 'Document Type',
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 5),
              provider.selectedDocumentId?[index] != null
                  ? CustomText(
                text:
                'Selected Document: ${provider.getSelectedDocumentName(index)}',
                color: Colors.red,
                fontSize: 20,
              )
                  : Container(),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Document Name')),
                  DataColumn(label: Text('Document Category')),
                  DataColumn(label: Text('Select')),
                ],
                rows: provider.documentData!.documents!
                    .map(
                      (document) => DataRow(
                    selected:
                    document.documentId == provider.selectedDocumentId?[index],
                    onSelectChanged: (bool? selected) {
                      if (selected != null) {
                        provider.selectDocument(index, document.documentId!);
                        print("Document ID List Prepared in Parent: ${provider.selectedDocumentId}");
                      }
                    },
                    cells: [
                      DataCell(Text(document.documentName ?? '')),
                      DataCell(Text(document.documentCategory ?? '')),
                      DataCell(
                        Radio<int>(
                          value: document.documentId!,
                          groupValue: provider.selectedDocumentId![index],
                          onChanged: (int? value) {
                            provider.selectDocument(index, value);
                          },
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: CustomText(text: 'Selected Category'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: CustomText(text: 'Close'),
            ),
          ],
        );
      },
    );
  }
}
