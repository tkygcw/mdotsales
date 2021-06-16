import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/database/Cartlist.dart';
import 'package:mdotorder/object/Order.dart';
import 'package:mdotorder/pages/Product_detail.dart';
import 'package:mdotorder/pages/Home.dart';
import 'package:mdotorder/domain/domain.dart';

class Cart extends StatefulWidget {
  Cart({Key key, this.name, this.update}) : super(key: key);

  final String name;
  final Function() update;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController _textFieldController = TextEditingController();
  List<Order> taskList = new List();
  String finalquantity;
  double total = 0;
  double subtotal;

  //double finalresult;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          taskList.add(Order(
              id: element['id'],
              name: element["name"],
              itemcode: element["itemcode"],
              price: element["price"],
              quantity: element["quantity"],
              color: element["color"]));
          subtotal = (element["price"] * element["quantity"]);
          total = total + subtotal;
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  navigateToNextActivity(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProductDetail(
        idHolder: dataHolder.toString(),
      ),
    ));
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
              child: Text('View Cart'),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: taskList.isEmpty
                    ? Container()
                    : ListView.separated(
                        separatorBuilder: (ctx, index) => Divider(
                            //color: Colors.black,
                            ),
                        itemCount: taskList.length,
                        itemBuilder: (ctx, int index) {
                          if (index == taskList.length) return null;
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.all(5),
                            child: Slidable(
                              actions: <Widget>[
                                IconSlideAction(
                                    icon: Icons.more,
                                    caption: 'View More',
                                    color: Colors.blueGrey[400],
                                    onTap: () {
                                      navigateToNextActivity(
                                          context, taskList[index].itemcode);
                                    }),
                              ],
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                    icon: Icons.delete,
                                    color: Colors.blueGrey[800],
                                    caption: 'Delete',
                                    onTap: () {
                                      _deleteTask(taskList[index].id,
                                          taskList[index].price);
                                      widget.update();
                                    })
                              ],
                              child: ListTile(
                                leading: Icon(Icons.keyboard_arrow_left),
                                title: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                      taskList[index].color == "nocolor"
                                          ? taskList[index].name
                                          : taskList[index].name +
                                              "(" +
                                              taskList[index].color +
                                              ")",
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                ),
                                subtitle: GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          "RM " +
                                              taskList[index].price.toString(),
                                          style: TextStyle(
                                            color: Colors.deepOrange,
                                            fontSize: 14,
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          taskList[index].quantity != 1
                                              ? new IconButton(
                                                  icon: new Icon(
                                                      Icons.remove_circle),
                                                  color: Colors.blueGrey[800],
                                                  onPressed: () {
                                                    updateTask(
                                                        taskList[index]
                                                            .itemcode,
                                                        taskList[index].price,
                                                        taskList[index]
                                                            .quantity,
                                                        taskList[index].color,
                                                        "reduce");
                                                    taskList[index].quantity--;
                                                  })
                                              : new IconButton(
                                                  icon: new Icon(
                                                      Icons.remove_circle),
                                                  color: Colors.grey[400],
                                                ),
                                          new Text(
                                              taskList[index]
                                                  .quantity
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.blueGrey[800],
                                                fontSize: 20,
                                              )),
                                          new IconButton(
                                              icon: new Icon(Icons.add_circle),
                                              color: Colors.blueGrey[800],
                                              onPressed: () {
                                                updateTask(
                                                    taskList[index].itemcode,
                                                    taskList[index].price,
                                                    taskList[index].quantity,
                                                    taskList[index].color,
                                                    "add");
                                                taskList[index].quantity++;
                                              }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actionPane: SlidableDrawerActionPane(),
                            ),
                          );
                        }),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Total: RM ' + total.toString(),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.blueGrey[800],
                      child: taskList.length == 0
                          ? FlatButton(
                              child: const Text(
                                'No Item Yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : FlatButton(
                              onPressed: () {
                                checkout();
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(int id, double price) async {
    await DatabaseHelper.instance.delete(id);
    double setPrice = price;
    setState(() {
      total = total - setPrice;
      taskList.removeWhere((element) => element.id == id);
    });
  }

  void updateTask(int productid, double price, int quantity, String color,
      String adjust) async {
    int getid = productid;
    String action = adjust;
    double setPrice = price;
    String setcolor = color;
    var setquantity = quantity;

    setState(() {
      if (action == 'reduce') {
        var newquantity = setquantity - 1;
        final getresult =
            DatabaseHelper.instance.update(getid, newquantity, color);
        total = total - setPrice;
      } else if (action == 'add') {
        var newquantity = setquantity + 1;
        final getresult =
            DatabaseHelper.instance.update(getid, newquantity, color);
        total = total + setPrice;
      }
    });
  }

  void checkout() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Complete order?"),
          content: Text("Do you want to check out all product?"),
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
                saveOrder(getdealerid);
                Navigator.of(context).pop();
                showalert();
              },
            ),
          ],
        );
      },
    );
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Your order is completed."),
          content: Text("Please wait admin approve it. Thank you."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                DatabaseHelper.instance.clearTable();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ));
                });
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveOrder(getdealerid) async {
    Map data = await Domain.callApi(Domain.insertorder,
        {'create': '1', 'dealerid': getdealerid.toString()});

    int neworderid = data['last_id'];

    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          Domain.callApi(Domain.insertorder, {
            'generate': '1',
            'orderid': neworderid.toString(),
            'item_number': element['itemcode'].toString(),
            'price': element['price'].toString(),
            'quantity': element['quantity'].toString(),
            'color': element['color']
          });
        });
      });
    }).catchError((error) {
      print(error);
    });
  }
}
