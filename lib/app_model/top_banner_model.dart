class TopBannerModel {
  String title;
  String imgLink;
  String? toGoLink;
  String status;

  TopBannerModel(
      {required this.title,
      required this.imgLink,
      this.toGoLink,
      required this.status});

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "imgLink": imgLink,
      "toGoLink": toGoLink,
      "status": status,
    };
  }

  factory TopBannerModel.fromJson(Map<dynamic, dynamic> json) {
    return TopBannerModel(
        title: json['title'],
        imgLink: json['imgLink'],
        toGoLink: json['toGoLink'],
        status: json['status']);
  }
}
