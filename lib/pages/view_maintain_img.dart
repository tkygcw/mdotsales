import 'dart:convert';

import 'package:flutter/material.dart';

class ViewMaintainImg extends StatefulWidget {
  final String fileName;

  ViewMaintainImg({this.fileName});

  @override
  _ViewMaintainImgState createState() => _ViewMaintainImgState();
}

class _ViewMaintainImgState extends State<ViewMaintainImg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

          ],
        ),
      ),

      body: GestureDetector(
        onTap: (){
          Navigator.pop(context,true);
        },
        child: Container(
          child: Image.memory(
              base64.decode(widget.fileName.toString()),
              fit: BoxFit.cover
          ),
        ),
      ),
    );
  }
}
