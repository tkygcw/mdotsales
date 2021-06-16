import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/status.dart';

class StatusHistory extends StatefulWidget {
  final String deliveryid;

  StatusHistory({this.deliveryid});

  @override
  _StatusHistoryState createState() => _StatusHistoryState();
}

class _StatusHistoryState extends State<StatusHistory> {
  final key = new GlobalKey<ScaffoldState>();
  List<Status> statusinfo = [];
  TextEditingController _editRemark;

  Future showDeliveryinfo(String deliveryid) async {
    return await Domain.callApi(Domain.getdelivery, {
      'checkrecord': '1',
      'deliveryid': deliveryid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Delivery Detail"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
        child: FutureBuilder(
            future: showDeliveryinfo(widget.deliveryid),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  statusinfo = [];

                  if (data['status'] == '1') {
                    List getdelivery = data['getdelivery'];

                    statusinfo.addAll(getdelivery
                        .map((jsonObject) => Status.fromJson(jsonObject))
                        .toList());

                    if(statusinfo[0].status == 0){
                      _editRemark =
                          TextEditingController(text: statusinfo[0].remark);
                    }else{
                      _editRemark =
                          TextEditingController(text: statusinfo[0].note);
                    }

                    return customProfile();
                  }
                }
              }
              return Center(child: Text("No Data"));
            }),
      ),
    );
  }

  Widget customProfile() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Visibility(
            visible: statusinfo[0].picture != "",
            child: Container(
              child: Image.memory(
                  base64.decode(statusinfo[0].picture.toString())),
            ),
          ),
          Visibility(
            visible: statusinfo[0].signature != "",
            child: Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Image.memory(
                  base64.decode(statusinfo[0].signature.toString())),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              statusinfo[0].deliverycode + " (${statusinfo[0].name})",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "Match: ${statusinfo[0].identify == 1 ? "Yes" : "No"}",
              style: TextStyle(
                  color:
                  statusinfo[0].identify == 1 ? Colors.green : Colors.red,
                  fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: TextField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _editRemark,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                // labelText: "Remark",
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(15.0),
                  color: Colors.blueGrey[800],
                  onPressed: () {
                    updateRemark(_editRemark);
                  },
                  child: Text(
                    "Update Remark",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          )
        ]);
  }

  void updateRemark(newremark) async {
    Map data;
    if(statusinfo[0].status == 0){
      data = await Domain.callApi(Domain.getstatus, {
        'updateremark': '1',
        'deliveryid': widget.deliveryid.toString(),
        'remark': newremark.text.toString(),
      });
    }else {
      data = await Domain.callApi(Domain.getstatus, {
        'updatenote': '1',
        'deliveryid': widget.deliveryid.toString(),
        'note': newremark.text.toString(),
      });
    }

    if(data["status"]=="1"){
      return _showSnackBar("Update Successfully");
    }else{
      return _showSnackBar("Somethings wrong. Please try again.");
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }
}
