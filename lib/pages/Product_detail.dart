import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:share/share.dart';
import 'package:mdotorder/database/Cartlist.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/System.dart';
import 'package:mdotorder/object/product.dart';
import 'package:mdotorder/object/product_image.dart';
import 'package:mdotorder/object/product_color.dart';
import 'package:mdotorder/object/Order.dart';
import 'package:mdotorder/pages/Cart.dart';
import 'package:mdotorder/pages/ViewImage.dart';
import 'package:badges/badges.dart';

class ProductDetail extends StatefulWidget {
  final String idHolder;
  final Function() update;

  ProductDetail({this.idHolder, this.update});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final key = new GlobalKey<ScaffoldState>();
  int _itemCount = 1;

  List<Product> product = [];
  List<Product> dealerpricedata = [];
  List<System> systems = [];
  List<ProductImage> productImage = [];
  List<ProductColor> productColor = [];
  List<Order> taskList = new List();
  List<Order> allCart = new List();

  TextEditingController _editOwnPrice;
  bool isdealerprice;
  double shareprice;

  //product color item
  int selectvalue;
  double colorprice;
  String colorname;
  double totalprice;

  Future fetchProduct() async {
    checkdealerprice();
    dynamic getdealerlevel = await FlutterSession().get("dealerlevel");
    return await Domain.callApi(Domain.getproduct, {
      'read_single_product': '1',
      'product_id': widget.idHolder,
      'level': getdealerlevel.toString(),
    });
  }

  Future fetchSystem() async {
    Map systemdata = await Domain.callApi(Domain.getsystem, {'read': '1'});

    systems = [];
    if (systemdata['status'] == '1') {
      List responseJsonsystem = systemdata['system'];
      systems.addAll(responseJsonsystem.map((e) => System.fromJson(e)));
    }
    setState(() {});
  }

  Future checkdealerprice() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map data = await Domain.callApi(Domain.getproduct, {
      'read_dealer_product_price': '1',
      'product_id': widget.idHolder,
      'dealer_id': getdealerid.toString(),
    });

    dealerpricedata = [];
    if (data['status'] == '1') {
      isdealerprice = true;
      List responseJsondealerprice = data['product2'];
      dealerpricedata
          .addAll(responseJsondealerprice.map((e) => Product.fromJson(e)));
    } else {
      isdealerprice = false;
    }

    if (isdealerprice == true) {
      shareprice = dealerpricedata[0].price;
      _editOwnPrice = TextEditingController(
          text: dealerpricedata[0].price.toString());
    } else {
      shareprice = product[0].price;
      _editOwnPrice =
          TextEditingController(text: product[0].price.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSystem();
    refleshcart();
    DatabaseHelper.instance.query(widget.idHolder).then((value) {
      setState(() {
        value.forEach((element) {
          taskList.add(Order(
              id: element['id'],
              name: element["name"],
              price: element["price"],
              quantity: element["quantity"],
              color: element["color"]));
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  refleshcart() {
    allCart = [];
    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          allCart.add(Order(
              id: element['id'],
              name: element["name"],
              price: element["price"],
              quantity: element["quantity"],
              color: element["color"]));
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  Widget _shoppingCartBadge() {
    return Badge(
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      position: BadgePosition.topEnd(top: 0, end: 3),
      badgeContent: Text(
        allCart.length.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Cart(
                update: () {
                  setState(() {
                    refleshcart();
                    widget.update();
                  });
                },
              ),
            ));
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text('View Product'),
            ),
            FutureBuilder(
              future: fetchProduct(),
              builder: (context, object) {
                if (object.hasData) {
                  if (object.connectionState == ConnectionState.done) {
                    Map data = object.data;
                    if (data['status'] == '1') {
                      List products = data['product2'];
                      product.addAll(products
                          .map((jsonObject) => Product.fromJson(jsonObject))
                          .toList());

                      return Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.share),
                          color: Colors.white,
                          onPressed: () {
                            Share.share(
                                "Links: " +
                                    websitefilelink +
                                    "shareproduct.php?productid=" +
                                    widget.idHolder +
                                    "\n\n"
                                        "Item No: " +
                                    product[0].itemnumber +
                                    "\n" +
                                    "Product: " +
                                    product[0].name +
                                    "\n" +
                                    product[0].description +
                                    "\n\n"
                                        "Price: " +
                                    shareprice.toString() +
                                    "\n",
                                subject: "Sharing Product");
                          },
                        ),
                      );
                    }
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
        actions: <Widget>[
          _shoppingCartBadge(),
        ],
      ),
      body: FutureBuilder(
        future: fetchProduct(),
        builder: (context, object) {
          if (object.hasData) {
            if (object.connectionState == ConnectionState.done) {
              Map data = object.data;

              if (data['status'] == '1') {
                /*
                * for product description purpose
                * */
                List products = data['product2'];
                product.addAll(products
                    .map((jsonObject) => Product.fromJson(jsonObject))
                    .toList());

                /*
                * for product slider purpose
                * */
                if (data['product_banner'] != false) {
                  List sliders = data['product_banner'];
                  productImage.addAll(sliders
                      .map((jsonObject) => ProductImage.fromJson(jsonObject))
                      .toList());
                }

                colorname = "nocolor";

                /*
                * for product color purpose
                * */
                // if (data['product_color'] != false) {
                //   productColor = [];
                //   List colors = data['product_color'];
                //   productColor.addAll(colors
                //       .map((jsonObject) => ProductColor.fromJson(jsonObject))
                //       .toList());
                // } else {
                //   selectvalue = null;
                //   colorprice = null;
                //   colorname = null;
                // }

                return mainContent();
              } else {
                Center(child: Text("No Data"));
              }
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          productSlider(),
          productDetail(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.blueGrey[800],
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _itemCount != 1
                            ? new IconButton(
                                icon: new Icon(Icons.remove_circle),
                                color: Colors.white,
                                onPressed: () => setState(() => _itemCount--),
                              )
                            : new IconButton(
                                icon: new Icon(Icons.remove_circle),
                                color: Colors.grey[400],
                              ),
                        new Text(_itemCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            )),
                        new IconButton(
                            icon: new Icon(Icons.add_circle),
                            color: Colors.white,
                            onPressed: () => setState(() => _itemCount++))
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.blueGrey[800],
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: colorname == null
                        ? FlatButton(
                            child: Text(
                              'Choose Color',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )
                        : product[0].price != 0
                            ? FlatButton(
                                onPressed: () {
                                  if (colorprice != null) {
                                    totalprice = product[0].price + colorprice;
                                  } else {
                                    totalprice = product[0].price;
                                  }

                                  _addToDb(product[0].id, product[0].name,
                                      totalprice, _itemCount, colorname);
                                  widget.update();
                                },
                                child: const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : FlatButton(
                                child: const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget productDetail() {
    return Column(
      children: [
        Divider(
          color: Colors.black,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              product[0].itemnumber,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 400,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                product[0].name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              product[0].barcode ?? "",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: colorprice != null
                                ? isdealerprice == true
                                    ? Text(
                                        "RM " +
                                            (product[0].price + colorprice)
                                                .toString() +
                                            " --- Your Price: (RM ${shareprice.toString()})",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ))
                                    : Text(
                                        "RM " +
                                            (product[0].price + colorprice)
                                                .toString(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ))
                                : isdealerprice == true
                                    ? Text(
                                        "RM " +
                                            product[0].price.toString() +
                                            " --- Your Price: (RM ${shareprice.toString()})",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ))
                                    : Text("RM " + product[0].price.toString(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        )),
                          ),
                          Container(
                            height: 30,
                            width: 120,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            color: Colors.blueGrey[800],
                            child: FlatButton(
                              onPressed: () {
                                setpricealert();
                              },
                              child: const Text(
                                'Set Own Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: productColor.length > 0,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 200, 10),
                        child: ProductColorlist())),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: Text(
                        product[0].packageprice != 0
                            ? "${systems[0].packagename}: RM " +
                                product[0].packageprice.toString()
                            : "",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ))),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: Text("${product[0].status}",
                        style:
                            TextStyle(fontSize: 16, color: Colors.red[300]))),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: Text(product[0].description,
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[800]))),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget productSlider() {
    return productImage.length > 0
        ? Column(children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: [
                CarouselSlider(
                  items: countLength()
                      .map((i) => Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ViewImage(
                                          id: productImage[i].productLocate,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  child: new Image.network(
                                    (imglink + productImage[i].productLocate),
                                    width: MediaQuery.of(context).size.width,
                                    height: 220,
                                  ),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                  options: CarouselOptions(
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                  ),
                ),
              ],
            )
          ])
        : Container(
            height: 220,
            child: Image.asset('assets/noimg.jpg'),
          );
  }

  Widget ProductColorlist() {
    return Container(
      child: DropdownButton<int>(
          value: selectvalue,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          hint: Text("Select color..."),
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (int newValue) {
            setState(() {
              selectvalue = newValue;
              colorname = productColor[selectvalue].name;
              colorprice = productColor[selectvalue].price;
            });
          },
          items: [
            for (int i = 0; i < productColor.length; i++)
              productColor.length == 0
                  ? DropdownMenuItem(
                      value: null,
                      child: Text("No Color"),
                    )
                  : DropdownMenuItem(
                      value: i,
                      child: Text(productColor[i].name),
                    ),
          ]),
    );
  }

  List<int> countLength() {
    List<int> length = [];
    for (int i = 0; i < productImage.length; i++) {
      length.add(i);
    }
    return length;
  }

  void _addToDb(int productid, String name, double price, int quantity,
      String color) async {
    int getid = productid;
    String task = name;
    double setPrice = price;
    var setquantity = quantity;
    String setcolor = color;

    setState(() {
      if (taskList.length == 0) {
        var saveid = DatabaseHelper.instance.insert(Order(
            itemcode: getid,
            name: task,
            price: setPrice,
            quantity: setquantity,
            color: setcolor));
        taskList.insert(
            0,
            Order(
                itemcode: getid,
                name: task,
                price: setPrice,
                quantity: setquantity,
                color: setcolor));
        allCart.insert(
            0,
            Order(
                itemcode: getid,
                name: task,
                price: setPrice,
                quantity: setquantity,
                color: setcolor));
        _itemCount = 1;
      } else {
        int checked = 0;
        DatabaseHelper.instance.query(getid).then((value) {
          value.forEach((element) {
            if (setcolor == element['color']) {
              checked = 1;
              DatabaseHelper.instance
                  .querycolor(getid, element['color'])
                  .then((value) {
                value.forEach((element) {
                  var newquantity = setquantity + element['quantity'];
                  final getresult = DatabaseHelper.instance
                      .update(getid, newquantity, setcolor);
                  _itemCount = 1;
                });
              });
            }
          });

          if (checked == 0) {
            var saveid = DatabaseHelper.instance.insert(Order(
                itemcode: getid,
                name: task,
                price: setPrice,
                quantity: setquantity,
                color: setcolor));
            taskList.insert(
                0,
                Order(
                    itemcode: getid,
                    name: task,
                    price: setPrice,
                    quantity: setquantity,
                    color: setcolor));
            allCart.insert(
                0,
                Order(
                    itemcode: getid,
                    name: task,
                    price: setPrice,
                    quantity: setquantity,
                    color: setcolor));
            _itemCount = 1;
          }
        });
      }
    });
  }

  void setpricealert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Set this to your sharing price?"),
          content: TextField(
            controller: _editOwnPrice,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: [
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                addOwnProduct(_editOwnPrice.text.toString());
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addOwnProduct(getprice) async{
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map data = await Domain.callApi(Domain.getproduct, {
      'addtodealerprice': '1',
      'dealerid': getdealerid.toString(),
      'productid': widget.idHolder,
      'setprice': getprice,
    });

    if(data["status"]=='1'){
      _showSnackBar("Set the price successfully!");
      setState(() {});
    }else{
      _showSnackBar("Something error!");
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }
}
