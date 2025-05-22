import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diligov_members/providers/document_page_provider.dart';
class ChildDocumentChildDialog extends StatelessWidget {
  final int i;
  final int j;

  const ChildDocumentChildDialog({
    Key? key,
    required this.i,
    required this.j,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<DocumentPageProvider>(context, listen: false)
          .getListOfDocuments(), // Fetch documents only once
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final provider = Provider.of<DocumentPageProvider>(context);

        // Check if document data is available
        if (provider.documentData?.documents == null ||
            provider.documentData!.documents!.isEmpty) {
          return const Center(child: Text('No data to show'));
        }

        // Ensure selectedChildDocumentId list has enough elements
        while (provider.selectedChildDocumentId.length <= i) {
          provider.selectedChildDocumentId.add(null);
        }
        while (provider.selectedChildDocumentId.length <= j) {
          provider.selectedChildDocumentId.add(null);
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
              provider.selectedChildDocumentId[j] != null
                  ? CustomText(
                text:
                'Selected Document: ${provider.getSelectedChildDocumentName(i, j)}',
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
                    selected: document.documentId ==
                        provider.selectedChildDocumentId[j],
                    onSelectChanged: (bool? selected) {
                      if (selected != null) {
                        provider.selectDocumentChild(i, j, document.documentId!);
                        print("Document ID List Prepared in children: ${provider.selectedChildDocumentId}");
                      }
                    },
                    cells: [
                      DataCell(Text(document.documentName ?? '')),
                      DataCell(Text(document.documentCategory ?? '')),
                      DataCell(
                        Radio<int>(
                          value: document.documentId!,
                          groupValue: provider.selectedChildDocumentId[j],
                          onChanged: (int? value) {
                            provider.selectDocumentChild(i, j, value!);
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
