class Brand {
  String name,picture;

  Brand({
    this.name,
    this.picture
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
        name: json['name'],
        picture: json['picture']
    );
  }
}