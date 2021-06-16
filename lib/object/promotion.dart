class Promotion {
  int id, productid;
  String link, remark, name, date, checklinktype, youtubelink;

  Promotion({
    this.id,
    this.link,
    this.productid,
    this.remark,
    this.name,
    this.date,
    this.checklinktype,
    this.youtubelink
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      link: json['link'],
      productid: json['productid'],
      remark: json["remark"],
      name: json["name"],
      date: json["created_at"],
      checklinktype: json["check_link_type"],
      youtubelink: json["youtube_link"]
    );
  }
}
