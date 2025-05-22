import 'package:flutter/material.dart';
import '../../colors.dart';
import '../../core/domains/app_uri.dart';
import '../../models/searchable.dart';
import '../../utility/preview_pdf_file_for_searchable_text.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custome_text.dart';

class FullScreenSearchViews extends StatefulWidget {
  static const routeName = '/FullScreenSearchViews';
  final List<SearchableModel>? searchResults;

  const FullScreenSearchViews({Key? key, required this.searchResults}) : super(key: key);

  @override
  State<FullScreenSearchViews> createState() => _FullScreenSearchViewsState();
}

class _FullScreenSearchViewsState extends State<FullScreenSearchViews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: widget.searchResults == null
            ? Center(
          child: CircularProgressIndicator(), // Show loading indicator if data is null
        )
            : widget.searchResults!.isEmpty
            ? Center(
          child: CustomText(
            text: "No results found",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey,
          ),
        )
            : _buildDataTable(),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 530,
        decoration: BoxDecoration(
          border: Border.all(color: Colour().darkHeadingColumnDataTables),
          borderRadius: BorderRadius.circular(20),
        ),
        headingRowHeight: 60,
        dividerThickness: 0.3,
        headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colour().darkHeadingColumnDataTables,
        ),
        columns:  <DataColumn>[
          DataColumn(
            label: CustomText(
              text: 'File',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          DataColumn(
            label: CustomText(
              text: 'Occurrences',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          DataColumn(
            label: CustomText(
              text: 'Action',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
        rows: widget.searchResults!.map((searchable) {
          String updatedPath = searchable.replaceLocalPathWithUrl(searchable.fileDir!);
          String segment = searchable.findSegmentAfterPrefix(
            searchable.fileDir!,
            "/home/diligov/public_html/public/meetings/",
          );
          var fileSearched = segment.replaceAll('_', ' ');

          return DataRow(
            cells: <DataCell>[
              DataCell(
                Row(
                  children: [
                      CustomIcon(icon: Icons.file_open, color: Colors.grey),
                    const SizedBox(width: 10),
                    CustomText(
                      text: fileSearched,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[100],
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: CustomText(
                    text: '${searchable.textCount} ${searchable.textString}',
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15.0,
                  ),
                ),
              ),
              DataCell(
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PreviewPdfFileForSearchableText(
                          file: updatedPath,
                          fileName: segment,
                          searchText: searchable.textString!,
                        ),
                      ),
                    );
                  },
                  child:   CustomText(text: 'View'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
