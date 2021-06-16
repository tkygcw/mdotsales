class Order {
  int id, quantity, itemcode;
  String name, color;
  double price;

  Order({this.id, this.name, this.itemcode, this.price, this.quantity, this.color});

  Map<String, dynamic> toMap() {
    return {'id': id, 'itemcode': itemcode, 'name': name, 'price':price, 'quantity':quantity, 'color':color};
  }
}