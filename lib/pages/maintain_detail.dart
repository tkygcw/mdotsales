import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/object/Maintain.dart';
import 'package:mdotorder/object/maintain_img.dart';
import 'package:mdotorder/pages/view_maintain_img.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/domain.dart';

class MaintainDetail extends StatefulWidget {
  final String idHolder;

  MaintainDetail({this.idHolder});

  @override
  _MaintainDetailState createState() => _MaintainDetailState();
}

class _MaintainDetailState extends State<MaintainDetail> {
  final key = new GlobalKey<ScaffoldState>();

  List<Maintain> maintains = [];
  List<MaintainImage> maintainImage = [];
  DateTime  datenow = DateTime.now();
  String showstatus="Pending";

  int countCusImg;
  int countTecImg;

  Future fetchChecking() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");

    Map response = await Domain.callApi(Domain.getmaintain, {
      'readdetail': '1',
      'dealerid': getdealerid.toString(),
      'maintainid': widget.idHolder.toString(),
    });

    maintains = [];
    if (response['status'] == '1') {
      List responseJsonProtection = response['maintaindetail'];
      maintains.addAll(responseJsonProtection.map((e) => Maintain.fromJson(e)));
    }

    maintainImage = [];
    if (response['status'] == '1') {
      List responseJsonProtection = response['maintain_img'];
      maintainImage.addAll(responseJsonProtection.map((e) => MaintainImage.fromJson(e)));
    }

    countCusImg=0;
    countTecImg=0;
    for(int i=0; i<maintainImage.length; i++){
      if(maintainImage[i].type=="cus"){
        countCusImg++;
      }else{
        countTecImg++;
      }
    }

    switch(maintains[0].status) {
      case 0:
        showstatus="Pending";
        break;
      case 1:
        showstatus="Processing";
        break;
      case 2:
        showstatus="Completed";
        break;
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
    return maintains.length>0 ?
      Scaffold(
      key: key,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: maintains[0].image=='' ? 30 : 90,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Icon(Icons.clear)
                    )
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )
                ),
                child: Center(
                  child: Text(
                    widget.idHolder+". "+maintains[0].name,
                    style: const TextStyle(
                        fontSize: 24
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imglink + maintains[0].picture,
                width: double.maxFinite,
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  child: Text(
                    "Created Date: "+maintains[0].created_at,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black
                    ),
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 30),
                ),
                const SizedBox(height: 30,),
                Container(
                  child: Text(
                    "S/N: "+maintains[0].serialnumber,
                    style: const TextStyle(
                        fontSize: 18
                    ),
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20),
                ),
                const SizedBox(height: 30,),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Technician: ",
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      maintains[0].technicianname!=null
                        ? Text(maintains[0].technicianname)
                        : Text("No technicians yet"),
                    ],
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20),
                ),
                const SizedBox(height: 30,),
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
                          padding: const EdgeInsets.all(5),
                          child: const Text(
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
                              padding: const EdgeInsets.all(5),
                              child: const Text(
                                "Name: ",
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                maintains[0].customername,
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
                              padding: const EdgeInsets.all(5),
                              child: const Text(
                                "Address: ",
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  maintains[0].address+", "+maintains[0].postcode+", "+maintains[0].city+", "+maintains[0].state+", "+maintains[0].country,
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
                              padding: const EdgeInsets.all(5),
                              child: const Text(
                                "Phone: ",
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                launch(('tel://${maintains[0].phone}'));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  maintains[0].phone,
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
                              padding: const EdgeInsets.all(5),
                              child: const Text(
                                "Email: ",
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                maintains[0].email,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20),
                ),
                const SizedBox(height: 50,),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "Reason: "+maintains[0].reason,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "Detail: "+maintains[0].detail,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: countCusImg>0,
                    child: customerSlider()
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  child: const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text(
                    "Technician Part",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Visibility(
                    visible: countTecImg>0,
                    child: technicianSlider()
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              "Remark: ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                maintains[0].remark,
                                style: const TextStyle(
                                    fontSize: 18
                                ),
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 25,),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Status: ",
                              style: TextStyle(
                                fontSize: 16
                              ),
                            ),
                            Text(
                              "-  "+showstatus,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(
                            left: 20, right: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: showstatus!="Completed" ? Container(
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
                showalert();
              },
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                child: Text("Cancel Case",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ) : Container(
        height: 10,
        padding: EdgeInsets.only(
          top: 30,
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
      )
    ) : Container();
  }

  Widget customerSlider() {
    return maintainImage.isNotEmpty
        ? Container(
      height: 200,
      width: double.maxFinite,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
          itemCount: maintainImage.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index){
            return maintainImage[index].type=="cus" ?
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ViewMaintainImg(
                              fileName: maintainImage[index].filename,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      child: Image.memory(
                          base64.decode(maintainImage[index].filename.toString()),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                ],
              ),
            ) : Container();
          }),
    )
        : Container(
      width: 200,
      height: 200,
      child: Image.asset('assets/noimg.jpg',),
    );
  }

  Widget technicianSlider() {
    return maintainImage.isNotEmpty
        ? Container(
      height: 200,
      width: double.maxFinite,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
          itemCount: maintainImage.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index){
            return maintainImage[index].type=="tec" ?
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ViewMaintainImg(
                              fileName: maintainImage[index].filename,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      child: Image.memory(
                          base64.decode(maintainImage[index].filename.toString()),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                ],
              ),
            ) : Container();
          }),
    )
        : Container(
      width: 200,
      height: 200,
      child: Image.asset('assets/noimg.jpg',),
    );
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cancel Report"),
          content: Text("Are you sure want to cancel this case?"),
          actions: [
            FlatButton(
              child: Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                cancelCase();
                Navigator.pop(context,true);
              },
            ),
          ],
        );
      },
    );
  }

  void cancelCase() async {
    Map data = await Domain.callApi(Domain.getmaintain, {
      'update': '1',
      'maintainid': widget.idHolder,
    });

    if(data["status"]=="1"){
      Navigator.of(context).pop();
    }else{
      _showSnackBar("Submit failed! Please try again.");
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }
}
