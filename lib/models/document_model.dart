class DocumentData {
  List<Document>? documents;

  DocumentData.fromJson(Map<String, dynamic> json) {
    if (json['documents'] != null) {
      documents = <Document>[];
      json['documents'].forEach((v) {
        documents!.add(Document.fromJson(v));
      });
    }
  }
}


class Document{
  int? documentId;
  String? documentName;
  String? documentCategory;
  bool selected = false;

  Document(
      {this.documentId,
        this.documentName,
        this.documentCategory,
        this.selected = false,
      });
    // create new converter
  Document.fromJson(Map<String, dynamic> json) {
      documentId = json['id'];
      documentName = json['document_name'];
      documentCategory = json['document_category'];

    }


}