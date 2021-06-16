import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/object/dealer.dart';
import 'package:mdotorder/pages/Home.dart';

import 'package:mdotorder/domain/domain.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<Dealer> dealers = [];
  var session = FlutterSession();

  @override
  void initState() {
    super.initState();
  }

  redirect() async {
    try {
      var getdealerid = await FlutterSession().get("dealerid");
      if (getdealerid != null) {
        openHomePage();
      } else {
        showloginpage();
      }
    } catch ($e) {
      print($e);
    }
  }

  @override
  Widget build(BuildContext context) {
    redirect();
    return showloginpage();
  }


  void checkLogin(name, pswd) async {
    int checking=0;
    Map data = await Domain.callApi(
        Domain.getdealerinfo, {'read': '1', 'name': name, 'pswd': pswd});

    if (data["status"] == '1') {
      checking=1;
      dealers = [];
      List dealer = data['Dealer'];

      dealers.addAll(
          dealer.map((jsonObject) => Dealer.fromJson(jsonObject)).toList());

      if (dealers[0].verified.toString() == '1') {
        await session.set("dealerid", dealers[0].id);
        await session.set("dealerlevel", dealers[0].levelid);

        openHomePage();
      } else {
        checking=2;
        _showSnackBar("You haven't verified your account yet.");
      }
    }

    if(checking==0){
      _showSnackBar("Wrong User or Password. Please try again.");
    }
  }

  openHomePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ));
    });
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Wrong User or Password."),
          content: Text("Please try again."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget showloginpage() {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text('MDOT'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'MDOT',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                  color: Colors.blueGrey[400],
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    checkLogin(nameController.text, passwordController.text);
                  },
                )),
          ],
        ),
      ),
    );
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }

  void saveLog(dealerid) async {
    //print("testing: "+_deviceData.toString());
    //return Map data = await Domain.callApi(Domain.getdealerinfo,{'create': '1', 'action': "Login", 'dealerid': dealerid});
  }
}
