class Category {
  int id;
  String name,picture;

  Category({
    this.id,
    this.name,
    this.picture
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'],
      name: json['name'],
      picture: json['picture']
    );
  }
}