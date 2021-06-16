class ProductColor {
  String name;
  double price;

  ProductColor({
    this.name,
    this.price
  });

  static double checkDouble(num value) {
    try {
      return value is double ? value : value.toDouble();
    } catch ($e) {
      return 0.00;
    }
  }

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    print(json);
    return ProductColor(
      name: json['name'],
      price: checkDouble(json['price']),
    );
  }
}
