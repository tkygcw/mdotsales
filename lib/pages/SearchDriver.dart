import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/Software.dart';
import 'package:mdotorder/object/category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchDriver extends StatefulWidget {
  @override
  _SearchDriverState createState() => _SearchDriverState();
}

class _SearchDriverState extends State<SearchDriver> {
  Future<http.Response> _responseFuture;
  Future<void> _launched;
  List<Software> softwares = [];

  String query = '';
  Timer _debounce;
  TextEditingController _textController = TextEditingController();

  //Pagination purpose
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 25;

  Future readCategory() async {
    Map data = await Domain.callApi(Domain.getcategory, {
      'readcategory': '1',
      'query': query,
      'itemPerPage': itemPerPage.toString(),
      'page': currentPage.toString()
    });

    if (data['status'] == '1') {
      List responseJson = data['getcategory'];

      softwares.addAll(responseJson.map((e) => Software.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
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

  @override
  void initState() {
    super.initState();
    readCategory();
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
      ),
      body: mainContent(),
    );
  }

  Widget mainContent() {
    return softwares.length > 0
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
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget customListView() {
    return ListView.builder(
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
                  leading: Container(
                    width: 80,
                    child: Text(
                      '${(i+1).toString()}',
                    ),
                  ),
                  title: Text(softwares[i].name),
                  // subtitle: Text(softwares[i].categoryname),
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
    );
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        softwares.clear();
        currentPage = 1;
        itemFinish = false;
        readCategory();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        readCategory();
      });
    }
    _refreshController.loadComplete();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      softwares.clear();
      currentPage = 1;
      itemFinish = false;

      this.query = query;
      readCategory();
    });
  }
}
