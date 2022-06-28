import 'package:flutter/material.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatefulWidget {
  final String id;

  ViewImage({this.id});

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
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
          child: PhotoView(
            imageProvider: NetworkImage(
                imglink + widget.id,
            ),
          ),
        ),
      ),
    );
  }
}
