class NominationsData{

  List<NominationModel>? nominations;
  NominationsData.fromJson(Map<String, dynamic> json) {
    if (json['nominations'] != null) {
      nominations = <NominationModel>[];
      json['nominations'].forEach((v) {
        nominations!.add(NominationModel.fromJson(v));
      });
    }
  }
}

class NominationModel {
  int? nominateId;
  String? nominateName;
  String? nominateCv;
  NominationModel(
      {this.nominateId,
        this.nominateName,
        this.nominateCv,
      });
  // create new converter
  NominationModel.fromJson(Map<String, dynamic> json) {
    nominateId = json['id'];
    nominateName = json['nominate_name'];
    nominateCv = json['cv_file']?.trim();
  }

}