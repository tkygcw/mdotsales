import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/object/status.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'Return_Product.dart';
import 'Status_detail.dart';

class statusinfo extends StatefulWidget {
  @override
  _statusinfoState createState() => _statusinfoState();
}

class _statusinfoState extends State<statusinfo> {
  TextEditingController _textController = TextEditingController();

  //Pagination purpose
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 15;

  //QR Code Part
  String qrData = "https://github.com/ChinmayMunje";

  List<Status> statusinfo = [];
  String query = '';
  Timer _debounce;

  Future fetchOrder() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map data = await Domain.callApi(Domain.getstatus, {
      'read': '1',
      'query': query,
      'dealerid': getdealerid.toString(),
      'itemPerPage': itemPerPage.toString(),
      'page': currentPage.toString()
    });

    if (data['status'] == '1') {
      List responseJson = data['getstatus'];

      statusinfo.addAll(responseJson.map((e) => Status.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchOrder();
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
            // Expanded(
            //   flex: 1,
            //   child: IconButton(
            //     icon: Icon(Icons.qr_code),
            //     color: Colors.white,
            //     onPressed: () {
            //       showalert();
            //     },
            //   ),
            // ),
          ],
        ),
      ),
      body: mainContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[400],
        onPressed: () {
          navigateToAddDelivery(context);
        },
        tooltip: 'Increment',
        child: Icon(
          Icons.add,
        ),
      ), //
    );
  }

  Widget mainContent() {
    return statusinfo.length > 0
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
        statusinfo.clear();
        currentPage = 1;
        itemFinish = false;
        fetchOrder();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchOrder();
      });
    }
    _refreshController.loadComplete();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      statusinfo.clear();
      currentPage = 1;
      itemFinish = false;

      this.query = query;
      fetchOrder();
    });
  }

  Widget customListView() {
    return ListView.builder(
      itemBuilder: (c, i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              navigateToNextActivity(context, statusinfo[i].id);
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 40,
                    child: Text("${i + 1}"),
                  ),
                  title: Text(
                      "${statusinfo[i].type} " + statusinfo[i].deliverycode),
                  subtitle: statusinfo[i].status == 0
                      ? Text(
                          "Pending",
                          style: TextStyle(color: Colors.grey),
                        )
                      : statusinfo[i].status == 1
                          ? Text(
                              "Pick Up",
                              style: TextStyle(color: Colors.yellow),
                            )
                          : statusinfo[i].status == 2
                              ? Text(
                                  "Return Back",
                                  style: TextStyle(color: Colors.greenAccent),
                                )
                              : Text(
                                  "Completed",
                                  style: TextStyle(color: Colors.green),
                                ),
                  trailing: IconButton(
                    icon: Icon(Icons.keyboard_arrow_right),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                  //trailing: Icon(Icons.keyboard_arrow_right),
                ),
                Divider(),
              ]),
            ),
          ),
        ],
      ),
      itemCount: statusinfo.length,
    );
  }

  void showalert() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");
    qrData = getdealerid.toString();

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Center(
            child: AlertDialog(
              title: Text("Scan here:"),
              content:
                  //Text(qrData),
                  Container(
                width: 300.0,
                height: 300.0,
                child: QrImage(
                  data: qrData,
                ),
              ),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  navigateToNextActivity(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StatusHistory(
        deliveryid: dataHolder.toString(),
      ),
    ));
  }

  navigateToAddDelivery(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReturnProductPage(),
    ));
  }
}
