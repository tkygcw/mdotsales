class Software {
  int id;
  String locate_at, link, name;

  Software({
    this.id,
    this.locate_at,
    this.link,
    this.name,
  });

  factory Software.fromJson(Map<String, dynamic> json) {
    return Software(
        id: json['software_id'],
        name: json['name'],
        locate_at: json['locate_at'],
        link: json["link"],
    );
  }
}
