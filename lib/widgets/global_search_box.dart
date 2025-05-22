import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/global_search_provider.dart';
import '../views/searching_views/full_screen_search_views.dart';
import 'custome_text.dart';

class GlobalSearchBox extends StatelessWidget {
  const GlobalSearchBox({Key? key}) : super(key: key);

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          text: message,
          fontSize: 16,
          color: color,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalSearchProvider = Provider.of<GlobalSearchProvider>(context);

    Future<void> performSearch() async {
      globalSearchProvider.setPress(true);
      FocusScope.of(context).unfocus();
      try {
        if (globalSearchProvider.controller.text.isNotEmpty) {

          await globalSearchProvider.extractTextsWithinAllFilesDocuments(
              globalSearchProvider.controller.text);

          if (globalSearchProvider.searchResults?.isNotEmpty ?? false) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullScreenSearchViews(
                  searchResults: globalSearchProvider.searchResults!,
                ),
              ),
            );
          } else {
            _showSnackBar(context, 'No results found', Colors.white);
          }
        }
      } catch (e) {
        _showSnackBar(context, 'An error occurred: $e', Colors.white);
      } finally {
        globalSearchProvider.setLoading(false);
      }
    }

    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: globalSearchProvider.controller,
        decoration: InputDecoration(
          hintText: "Looking For Some Words!!",
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: IconButton(
            icon: globalSearchProvider.icon,
            onPressed: () {
              if (globalSearchProvider.controller.text.isNotEmpty) {
                FocusScope.of(context).unfocus();
                globalSearchProvider.clearText();
              }
            },
          ),
          suffixIcon: globalSearchProvider.isPress  ? Container(
            color: Colors.black.withOpacity(0.5), // Dim background
            child: buildCircularProgress(),
          ) : IconButton(
            icon: CustomIcon(icon: Icons.search, size: 40, color: globalSearchProvider.isWrite && globalSearchProvider.controller.text.isNotEmpty ? Colors.green : Colors.white,),
            onPressed: () {
              performSearch(); // Trigger search on button press
            },
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onFieldSubmitted: (value) async {
          await performSearch(); // Trigger search on "Enter" key press
        },
      ),
    );
  }
}

class buildCircularProgress extends StatelessWidget {
  const buildCircularProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),

        ),
        child: CircularProgressIndicator( color: Colors.green,)
    );
  }
}
