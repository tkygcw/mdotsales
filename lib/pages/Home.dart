import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdotorder/pages/DownloadFile.dart';
import 'package:mdotorder/pages/Mainpage.dart';
import 'package:mdotorder/pages/Branddetail.dart';
import 'package:mdotorder/pages/Statusinfo.dart';
import 'package:mdotorder/pages/protectioninfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBottomNavigationBar(),
    );
  }
}


class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    IndexPage(),
    branddetail(),
    DownloadFile(),
    // statusinfo(),
    ProtectionInfo(),
  ];

  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],

      body:_children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[500],

        onTap: onTappedBar,
        currentIndex: _currentIndex,

        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.add_shopping_cart),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.cloud_download_outlined),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.auto_awesome_mosaic),
            label: 'Product Info',
          ),
          // BottomNavigationBarItem(
          //   icon: new Icon(Icons.auto_awesome_mosaic),
          //   title: new Text('Status'),
          // ),
        ],
      ),
    );
  }
}