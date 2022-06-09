import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/Protection.dart';
import 'package:mdotorder/pages/maintain_detail.dart';
import 'package:mdotorder/pages/protection_detail.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../object/Maintain.dart';

class ProtectionInfo extends StatefulWidget {

  @override
  _protectioninfoState createState() => _protectioninfoState();
}

class _protectioninfoState extends State<ProtectionInfo> {

  TextEditingController _textController = TextEditingController();
  int checkPage=1;
  DateTime  datenow = DateTime.now();

  //Pagination purpose
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 15;

  List<Protection> protections = [];
  List<Maintain> maintains = [];
  String query = '';
  Timer _debounce;

  Future fetchChecking() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map data = await Domain.callApi(Domain.getprotection, {
      'read': '1',
      'query': query,
      'dealerid': getdealerid.toString(),
      'itemPerPage': itemPerPage.toString(),
      'page': currentPage.toString()
    });

    if (data['status'] == '1') {
      protections=[];
      List responseJson = data['protection'];

      protections.addAll(responseJson.map((e) => Protection.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  Future fetchCase() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");
    Map data = await Domain.callApi(Domain.getmaintain, {
      'read': '1',
      'query': query,
      'dealerid': getdealerid.toString(),
      'itemPerPage': itemPerPage.toString(),
      'page': currentPage.toString()
    });

    if (data['status'] == '1') {
      maintains=[];
      List responseJson = data['maintain'];
      maintains.addAll(responseJson.map((e) => Maintain.fromJson(e)));

    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    RefreshController _refreshController = RefreshController(initialRefresh: false);
    super.initState();
    fetchChecking();
    fetchCase();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  navigateToService(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProtectionDetail(
        idHolder: dataHolder.toString(),
      ),
    ));
  }

  navigateToMaintain(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MaintainDetail(
        idHolder: dataHolder.toString(),
      ),
    ));
  }

  Widget mainContent() {
    return checkPage==1? protections.length > 0
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
      child: customListView()
    )
        : Container(
      child: Center(child: Text("No Data")),
    ): maintains.length > 0
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
        onRefresh: _onRefreshCase,
        onLoading: _onLoadingCase,
        child: CaseCustome()
    )
        : Container(
      child: Center(child: Text("No Data")),
    );
  }

  Widget customListView() {
    fetchChecking();
      return ListView.builder(
        itemBuilder: (c, i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                navigateToService(context, protections[i].id);
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Column(children: <Widget>[
                  ListTile(
                    leading: Container(
                      child: Text((i+1).toString()),
                    ),
                    title: Text(
                      protections[i].name,
                      style: TextStyle(
                        color: datenow.isBefore(DateTime.parse(protections[i].expireddate))
                            ?Colors.black
                            :Colors.redAccent
                      ),
                    ),
                    subtitle: Text(protections[i].serialnumber.toString()),
                    trailing: IconButton(
                      icon: Icon(Icons.security_sharp),
                      onPressed: () {
                      },
                    ),
                  ),
                  Divider(),
                ]),
              ),
            ),
          ],
        ),
        itemCount: protections.length,
      );
    }

  Widget CaseCustome() {
    fetchCase();
    return ListView.builder(
      itemBuilder: (c, i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              navigateToMaintain(context, maintains[i].maintainid);
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(children: <Widget>[
                ListTile(
                  leading: Container(
                    child: Text((i+1).toString()),
                  ),
                  title: Text(
                    maintains[i].name,
                  ),
                  subtitle: Text(maintains[i].serialnumber),
                  trailing: Text(maintains[i].status==0 ? "Pending"
                      : maintains[i].status==1
                        ? "Processing" : "Completed",
                      style: TextStyle(
                        color: maintains[i].status==0 ? Colors.red
                            : maintains[i].status==1 ? Colors.grey : Colors.black,
                      )
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.search_sharp,
                  //   ),
                  //   onPressed: () {
                  //   },
                  // ),
                ),
                Divider(),
              ]),
            ),
          ),
        ],
      ),
      itemCount: maintains.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height/17*13,
                child: mainContent()
            ),
            Container(
              height: MediaQuery.of(context).size.height/18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      setState(() {
                        checkPage=1;
                      });
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/18,
                      width: MediaQuery.of(context).size.width/2,
                      decoration: BoxDecoration(
                        color: checkPage==1?Colors.redAccent:Colors.blueGrey[400],
                      ),
                      child: Center(
                        child: Text(
                          "Protect Info",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        checkPage=2;
                      });
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/18,
                      width: MediaQuery.of(context).size.width/2,
                      decoration: BoxDecoration(
                        color: checkPage==2?Colors.redAccent:Colors.blueGrey[400],
                      ),
                      child: Center(
                        child: Text(
                          "Case State",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        protections.clear();
        currentPage = 1;
        itemFinish = false;
        fetchChecking();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchChecking();
      });
    }
    _refreshController.loadComplete();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      protections.clear();
      currentPage = 1;
      itemFinish = false;

      this.query = query;
      fetchChecking();
      fetchCase();
    });
  }

  _onRefreshCase() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        maintains.clear();
        currentPage = 1;
        itemFinish = false;
        fetchCase();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoadingCase() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchCase();
      });
    }
    _refreshController.loadComplete();
  }
}
