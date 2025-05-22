class AnnualAuditDetailsData{
  List<AnnualAuditDetailsModel>? details;
  AnnualAuditDetailsData.fromJson(Map<String, dynamic> json) {
    if (json['details'] != null) {
      details = <AnnualAuditDetailsModel>[];
      json['details'].forEach((v) {
        details!.add(AnnualAuditDetailsModel.fromJson(v));
      });
    }
  }
}


class AnnualAuditDetailsModel{

  int? detailId;
  String? detailEnglishName;
  String? detailArabicName;

  AnnualAuditDetailsModel({
    this.detailId,
    this.detailEnglishName,
    this.detailArabicName,
  });

  AnnualAuditDetailsModel.fromJson(Map<String, dynamic> json) {
    detailId= json['id'];
    detailEnglishName= json['detail_en'];
    detailArabicName= json['detail_ar'];

  }
}