import 'dart:async';
import 'dart:convert';
import 'package:mdotorder/object/category.dart';
import 'package:mdotorder/object/product.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mdotorder/pages/Cart.dart';
import 'package:mdotorder/pages/Productfilter.dart';
import 'package:mdotorder/object/Branditem.dart';
import 'package:mdotorder/pages/Product.dart';
import 'package:badges/badges.dart';

import 'package:mdotorder/database/Cartlist.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/Order.dart';

import 'package:mdotorder/domain/domain.dart';

class branddetail extends StatefulWidget {
  @override
  _branddetailState createState() => _branddetailState();
}

class _branddetailState extends State<branddetail> {
  Future<http.Response> _responseFuture;
  TextEditingController _textController = TextEditingController();
  List<Order> taskList = new List();

  String query = '';
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    refleshcart();
  }

  refleshcart(){
    taskList = [];
    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
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

  Future readBrand(query) async {
    return await Domain.callApi(Domain.getcategory, {
      'readbrand': '1',
      'query': query,
    });
    // print(data);
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        this.query = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search Here...',
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => productpage(
                      update: () {
                        setState(() {
                          refleshcart();
                        });
                      },
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          _shoppingCartBadge(),
        ],
      ),
      body: new FutureBuilder(
        future: readBrand(query),
        builder: (BuildContext context, object) {
          if (!object.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            Map data = object.data;
            if (data['status'] == '1') {
              return new MyExpansionTileList(data['getcategory']);
            } else if (data['status'] == '2') {
              return Center(child: Text("No Data"));
            }
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
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
      child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Cart()),
        );
      }),
    );
  }
}

class MyExpansionTileList extends StatelessWidget {
  final List<dynamic> elementList;

  MyExpansionTileList(this.elementList);

  List<Widget> _getChildren() {
    List<Widget> children = [];

    elementList.forEach((element) {
      children.add(new MyExpansionTile(
        id: element['category_id'],
        title: element['name'],
        picture: element["picture"],
        isExpand: false,
      ));
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: _getChildren(),
    );
  }
}

class MyExpansionTile extends StatefulWidget {
  int id;
  int position;
  String title, picture;
  bool isExpand;
  Function(int) closeOther;

  MyExpansionTile(
      {this.id, this.title, this.picture, this.isExpand, this.closeOther, this.position});

  @override
  State createState() => new MyExpansionTileState(this.id.toString());
}

class MyExpansionTileState extends State<MyExpansionTile> {
  final String idHolder;
  List<Category> categories = [];

  MyExpansionTileState(this.idHolder);

  Future fetchList(idHolder) async {
    return await Domain.callApi(Domain.getcategory, {
      'read': '1',
      'brandid': idHolder.toString(),
    });
  }

  PageStorageKey _key;
  Completer<http.Response> _responseCompleter = new Completer();

  @override
  Widget build(BuildContext context) {
    _key = new PageStorageKey('${widget.id}');
    print(widget.picture);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: new ExpansionTile(
        initiallyExpanded: widget.isExpand,
        key: _key,
        leading: widget.picture=='' ? Icon(Icons.dashboard) : Image.network(brandlink + widget.picture),
        title: new Text(widget.title),
        onExpansionChanged: (bool isExpanding) {
          if (!_responseCompleter.isCompleted) {
            widget.closeOther(widget.position);
          }
        },
        children: <Widget>[
          new FutureBuilder(
            future: fetchList(widget.id),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    categories = [];
                    List category = data['getcategory'];
                    categories.addAll(category
                        .map((jsonObject) => Category.fromJson(jsonObject))
                        .toList());
                    return customListView();
                  }
                } else {
                  Center(child: Text("Error"));
                }
                return Center(child: Text("No Data"));
              }
            },
          )
        ],
      ),
    );
  }

  double countHeight(int length) {
    return 70 * length.toDouble();
  }

  Widget customListView() {
    return Container(
      height: countHeight(categories.length),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        key: PageStorageKey('myScrollable'),
        itemBuilder: (c, i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ProductFilter(
                        brandid: idHolder,
                        categoryid: categories[i].id.toString(),
                        update: (){
                          setState(() {
                          });
                        },
                        //name:element['name']
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Column(children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        categories[i].picture == null
                            ? 'https://static.thenounproject.com/png/74838-200.png'
                            : categorylink + categories[i].picture,
                      ),
                      radius: 40,
                      backgroundColor: Colors.white,
                    ),
                    dense: true,
                    title: new Text(categories[i].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProductFilter(
                              brandid: idHolder,
                              categoryid: categories[i].id.toString(),
                              //name:element['name']
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                ]),
              ),
            ),
          ],
        ),
        itemCount: categories.length,
      ),
    );
  }
}
