import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:mdotorder/database/Cartlist.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/product.dart';
import 'package:mdotorder/object/Order.dart';
import 'package:mdotorder/object/product_color.dart';
import 'package:mdotorder/pages/Product_detail.dart';
import 'package:mdotorder/pages/Cart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:badges/badges.dart';
import 'package:group_radio_button/group_radio_button.dart';

class ProductFilter extends StatefulWidget {
  final String brandid, categoryid;
  final Function() update;

  ProductFilter({this.brandid, this.categoryid, this.update});

  @override
  _ProductFilterState createState() => _ProductFilterState();
}

class _ProductFilterState extends State<ProductFilter> {
  String barcode = "";

  String _verticalGroupValue;
  List<String> _status = [];

  TextEditingController _textController = TextEditingController();
  List<Product> products = [];
  List<Order> taskList = new List();
  List<ProductColor> productColor = [];

  //Pagination purpose
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 15;

  String query = '';
  Timer _debounce;

  Future fetchProduct() async {
    dynamic getdealerlevel = await FlutterSession().get("dealerlevel");
    Map data = await Domain.callApi(Domain.getproduct, {
      'filter_product': '1',
      'query': query,
      'brand_id': widget.brandid,
      'category_id': widget.categoryid,
      'level': getdealerlevel.toString(),
      'itemPerPage': itemPerPage.toString(),
      'page': currentPage.toString(),
    });

    //print(data);

    if (data['status'] == '1') {
      List responseJson = data['product2'];

      products.addAll(responseJson.map((e) => Product.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  Future fetchColor(int getid) async {
    dynamic getdealerlevel = await FlutterSession().get("dealerlevel");
    Map data = await Domain.callApi(Domain.getproduct, {
      'read_single_product': '1',
      'product_id': getid.toString(),
      'level': getdealerlevel.toString(),
    });

    if (data['status'] == '1') {
      productColor = [];
      _status = [];
      List colors = data['product_color'];
      productColor.addAll(colors
          .map((jsonObject) => ProductColor.fromJson(jsonObject))
          .toList());

      if (_verticalGroupValue == null) {
        _verticalGroupValue = productColor[0].name;
      }

      for (int i = 0; i < productColor.length; i++)
        _status.add(productColor[i].name);
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    fetchProduct();
    refleshcart();
  }

  refleshcart() {
    taskList = [];
    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          //_itemCount = element["quantity"];
          taskList.add(Order(
              id: element['id'],
              itemcode: element['itemcode'],
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

  navigateToNextActivity(BuildContext context, int dataHolder) {
    //print("show this: "+dataHolder.toString());
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProductDetail(
        idHolder: dataHolder.toString(),
        update: () {
          setState(() {
            refleshcart();
            widget.update();
          });
        },
      ),
    ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search Here...',
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          _shoppingCartBadge(),
        ],
      ),
      body: mainContent(),
    );
  }

  Widget _shoppingCartBadge() {
    return Badge(
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      // position: BadgePosition.topEnd(top: 0, end: 3),
      // badgeContent: Text(
      //   taskList.length.toString(),
      //   style: TextStyle(color: Colors.white),
      // ),
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

  Widget mainContent() {
    return products.length > 0
        ? SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = CircularProgressIndicator();
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text("No more Data");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: customListView(),
          )
        : Container(
            child: Center(child: Text("No Data")),
          );
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        products.clear();
        currentPage = 1;
        itemFinish = false;
        fetchProduct();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchProduct();
      });
    }
    _refreshController.loadComplete();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      products.clear();
      currentPage = 1;
      itemFinish = false;

      this.query = query;
      fetchProduct();
    });
  }

  Widget customListView() {
    return ListView.builder(
      itemBuilder: (c, i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              navigateToNextActivity(context, products[i].id);
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 80,
                    child: Image.network(
                      '${products[i].picture}' == null
                          ? ''
                          : imglink + '${products[i].picture}',
                    ),
                  ),
                  title: Text(products[i].name),
                  subtitle: Text("RM " + products[i].price.toString()),
                  // trailing: IconButton(
                  //   icon: Icon(Icons.add_circle),
                  //   onPressed: () {
                  //     setState(() {
                  //       addItem(
                  //         products[i].id,
                  //         products[i].name,
                  //         products[i].price,
                  //         products[i].getcolor
                  //       );
                  //       widget.update();
                  //     });
                  //   },
                  // ),
                  //trailing: Icon(Icons.keyboard_arrow_right),
                ),
                Divider(),
              ]),
            ),
          ),
        ],
      ),
      itemCount: products.length,
    );
  }

  Future barcodeScanning() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'No camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
        print(barcode);
      }
    } on FormatException {
      setState(() => this.barcode = 'Nothing captured.');
      print(barcode);
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
      print(barcode);
    }
  }

  void addItem(int productid, String name, double price, int getcolor) async {
    int getid = productid;
    String task = name;
    double setPrice = price;
    int havecolor = getcolor;

    if (havecolor == 1) {
      fetchColor(getid);

      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Color"),
            content: RadioGroup<String>.builder(
              groupValue: _verticalGroupValue,
              onChanged: (value) => setState(() {
                _verticalGroupValue = value;
              }),
              items: _status,
              itemBuilder: (item) => RadioButtonBuilder(
                item,
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  checkcart(getid, task, setPrice, _verticalGroupValue);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void checkcart(int productid, String name, double price, String color) async {
    int getid = productid;
    String task = name;
    double setPrice = price;
    String setcolor = color;

    setState(() {
      if (taskList.length == 0) {
        addcart(getid, task, setPrice, setcolor);
      } else {
        int checked = 0;
        DatabaseHelper.instance.query(getid).then((value) {
          value.forEach((element) {
            if (setcolor == element['color']) {
              checked = 1;
              updatecart(getid, setcolor);
            }
          });

          if (checked == 0) {
            addcart(getid, task, setPrice, setcolor);
          }
        });
      }
    });
  }

  void updatecart(getid, color) async {
    DatabaseHelper.instance.querycolor(getid, color).then((value) {
      value.forEach((element) {
        int newquantity = element["quantity"] + 1;
        final getresult =
            DatabaseHelper.instance.update(getid, newquantity, color);
      });
    }).catchError((error) {
      print(error);
    }).catchError((error) {
      print(error);
    });
  }

  void addcart(getid, task, setPrice, setcolor) async {
    var newquantity = 1;
    var saveid = DatabaseHelper.instance.insert(Order(
        itemcode: getid,
        name: task,
        price: setPrice,
        quantity: newquantity,
        color: setcolor));
    taskList.insert(
        0,
        Order(
            itemcode: getid,
            name: task,
            price: setPrice,
            quantity: newquantity,
            color: setcolor));
  }
}
