import 'package:pdf/widgets.dart' as pw;

class CustomMultiPage extends pw.MultiPage {
  CustomMultiPage({
    required pw.BuildListCallback build,
    pw.PageTheme? pageTheme,
    pw.BuildCallback? header,
    pw.BuildCallback? footer,
    pw.ThemeData? theme,
    pw.MainAxisAlignment mainAxisAlignment = pw.MainAxisAlignment.start,
    pw.CrossAxisAlignment crossAxisAlignment = pw.CrossAxisAlignment.start,
    pw.EdgeInsetsGeometry? margin,
    int maxPages = 5000,
  }) : super(
    build: build,
    pageTheme: pageTheme,
    header: header,
    footer: footer,
    theme: theme,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    margin: margin,
    maxPages: maxPages,
  );

  @override
  void generate(pw.Document document, {bool insert = true, int? index}) {
    // Custom logic to generate pages with large widgets handled dynamically.
    super.generate(document, insert: insert, index: index);
  }

  @override
  void postProcess(pw.Document document) {
    // Custom post-processing after all pages have been generated.
    super.postProcess(document);
  }
}
