class ProductImage {
  int id, setDefault;
  String productLocate;

  ProductImage({
    this.id,
    this.productLocate,
    this.setDefault
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['product_id'],
      productLocate: json['product_locate'],
      setDefault: json['set_default'],
    );
  }
}
