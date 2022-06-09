import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/pages/add_service.dart';
import 'package:mdotorder/pages/maintain_detail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/domain.dart';
import '../object/Protection.dart';

class ProtectionDetail extends StatefulWidget {
  final String idHolder;

  ProtectionDetail({this.idHolder});

  @override
  _ProtectionDetailState createState() => _ProtectionDetailState();
}

class _ProtectionDetailState extends State<ProtectionDetail> {
  List<Protection> protection = [];
  DateTime  datenow = DateTime.now();

  Future fetchChecking() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map response = await Domain.callApi(Domain.getprotection, {
      'readdetail': '1',
      'dealerid': getdealerid.toString(),
      'protectionid': widget.idHolder.toString(),
    });

    protection = [];
    if (response['status'] == '1') {
      List responseJsonProtection = response['protectiondetail'];
      protection.addAll(responseJsonProtection.map((e) => Protection.fromJson(e)));
    }
    setState(() {});
  }

  @override
  void initState() {
    fetchChecking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchChecking();
    return protection.length>0 ?
      Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 90,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(Icons.clear)
                    )
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(10),
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )
                ),
                child: Center(
                  child: Text(
                    protection[0].name,
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imglink+'${protection[0].picture}',
                width: double.maxFinite,
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.black,
            //   ),
            // ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  child: Text(
                    "Duration: "+protection[0].startingdate+" - "+protection[0].expireddate,
                    style: TextStyle(
                      fontSize: 18,
                      color: datenow.isBefore(DateTime.parse(protection[0].expireddate))
                          ?Colors.black
                          :Colors.redAccent
                    ),
                  ),
                  margin: EdgeInsets.only(
                      left: 20, right: 20, top: 30),
                ),
                SizedBox(height: 30,),
                Container(
                  child: Text(
                    "S/N: "+protection[0].serialnumber,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                  margin: EdgeInsets.only(
                      left: 20, right: 20),
                ),
                SizedBox(height: 30,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "Customer Detail: ",
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width:100,
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Name: ",
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                protection[0].customername,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width:100,
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Name: ",
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                protection[0].customername,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width:100,
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Address: ",
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  protection[0].address+", "+protection[0].postcode+", "+protection[0].city+", "+protection[0].state+", "+protection[0].country,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width:80,
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Phone: ",
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                launch(('tel://${protection[0].phone}'));
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  protection[0].phone,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width:100,
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Email: ",
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                protection[0].email,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(
                      left: 20, right: 20),
                ),
              ],
            ),
          )
        ],
      ),
        bottomNavigationBar: Container(
          height: 150,
          padding: EdgeInsets.only(top: 30,
              bottom: 30,
              left: 30,
              right: 30),
          decoration: BoxDecoration(
              color: const Color(0xFFf7f6f4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Container()),
              // Container(
              //   padding: EdgeInsets.only(top: 20,
              //       bottom: 20,
              //       left: 20,
              //       right: 20),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(
              //         20),
              //     color: Colors.white,
              //   ),
              //   child: Icon(
              //     Icons.favorite,
              //     color: Colors.blueGrey,
              //   ),
              // ),
              GestureDetector(
                onTap: (){
                  protection[0].havcase==0
                      ? navigateToAddService(context, protection[0].id)
                   : navigateToCase(context, protection[0].maintainid);
                },
                child: datenow.isBefore(DateTime.parse(protection[0].expireddate)) ?
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  child: Text(
                    protection[0].havcase==0 ? "Add Case" : "View Case",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: protection[0].havcase==0 ? Colors.blueGrey : Colors.redAccent,
                  ),
                ): Container(),
              ),
            ],
          ),
        )
    )
        :Container();
  }

  navigateToAddService(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddService(
        idHolder: dataHolder.toString(),
      ),
    ));
  }

  navigateToCase(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MaintainDetail(
        idHolder: dataHolder.toString(),
      ),
    ));
  }
}
