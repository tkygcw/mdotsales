import 'dart:async';
import 'dart:convert';
import 'package:mdotorder/object/Software.dart';
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
import 'package:mdotorder/pages/SearchDriver.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadFile extends StatefulWidget {
  @override
  _DownloadFileState createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  Future<http.Response> _responseFuture;
  TextEditingController _textController = TextEditingController();

  String query = '';
  Timer _debounce;

  Future readCategory(query) async {
    return await Domain.callApi(Domain.getcategory, {
      'showcategory': '1',
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
                    builder: (context) => SearchDriver(),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
      body: new FutureBuilder(
        future: readCategory(query),
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
  List<Software> softwares = [];
  Future<void> _launched;

  MyExpansionTileState(this.idHolder);

  Future fetchList(idHolder) async {
    return await Domain.callApi(Domain.getcategory, {
      'readsoftware': '1',
      'categoryid': idHolder.toString(),
    });
  }

  PageStorageKey _key;
  Completer<http.Response> _responseCompleter = new Completer();

  @override
  Widget build(BuildContext context) {
    _key = new PageStorageKey('${widget.id}');
    return Padding(
      padding: const EdgeInsets.all(3),
      child: new ExpansionTile(
        initiallyExpanded: widget.isExpand,
        key: _key,
        leading: widget.picture=='' ? Icon(Icons.dashboard) :
        CircleAvatar(
          backgroundImage: NetworkImage(categorylink + widget.picture),
          radius: 20,
          backgroundColor: Colors.white,
        ),
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
                    softwares = [];
                    List software = data['getsoftware'];
                    softwares.addAll(software
                        .map((jsonObject) => Software.fromJson(jsonObject))
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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  double countHeight(int length) {
    return 90 * length.toDouble();
  }

  Widget customListView() {
    // print("software length: "+softwares.length.toString());
    return Container(
      height: countHeight(softwares.length),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        key: PageStorageKey('myScrollable'),
        itemBuilder: (c, i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return softwares[i].locate_at !="" ? AlertDialog(
                      title: Text(softwares[i].name),
                      content: Text(softwares[i].locate_at),
                      actions: [
                        FlatButton(
                          child: Text("Download"),
                          onPressed: () =>
                              setState(() {
                                _launched = _launchInBrowser(
                                    softwarelink + softwares[i].locate_at);
                              }),
                        ),
                        FlatButton(
                          child: Text("Copy Link"),
                          onPressed: () {
                            Share.share(softwarelink + softwares[i].locate_at);
                          },
                        ),
                        FlatButton(
                          child: Text("Back"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ) : AlertDialog(
                      title: Text(softwares[i].name),
                      content: Text("This software has no any drivers."),
                      actions: [
                        FlatButton(
                          child: Text("Back"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Column(children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://static.thenounproject.com/png/74838-200.png',
                      ),
                      radius: 5,
                      backgroundColor: Colors.white,
                    ),
                    title: Text(softwares[i].name),
                    trailing: softwares[i].link != "" ? IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.share("Link: " + softwares[i].link);
                      },
                    ) : Text(""),
                    //trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  Divider(),
                ]),
              ),
            ),
          ],
        ),
        itemCount: softwares.length,
      ),
    );
  }
}
