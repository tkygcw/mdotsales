import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:mdotorder/pages/Personalprofile.dart';
import 'package:mdotorder/pages/Login.dart';
import 'package:mdotorder/pages/Product_detail.dart';
import 'package:mdotorder/object/promotion.dart';
import 'package:mdotorder/object/Menu.dart';

import 'package:mdotorder/domain/domain.dart';
import 'package:url_launcher/url_launcher.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List<Promotion> promotionImage = [];
  DateTime currentBackPressTime;


  Future fetchPromotion() async {
    return await Domain.callApi(Domain.getpromotion, {
      'read': '1',
    });
  }

  void _select(Choice choice) async {
    if (choice.title == 'Profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalProfile()),
      );
    } else if (choice.title == 'Logout') {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      getlog();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Login()),
      );
    }
    //_selectedChoice = choice;
  }

  navigateToNextActivity(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProductDetail(
        idHolder: dataHolder.toString(),
      ),
    ));
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
              child: Text('Welcome'),
            ),
            Expanded(
              flex: 1,
              child: PopupMenuButton<Choice>(
                  onSelected: _select,
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Row(children: [
                          IconButton(
                            icon: Icon(choice.icon),
                            color: Colors.white,
                          ),
                          Text(choice.title),
                        ]),
                      );
                    }).toList();
                  }),
            ),
          ],
        ),
      ),
      body: DoubleBackToCloseApp(
        child: FutureBuilder(
            future: fetchPromotion(),
            builder: (context, object) {
              if (object.hasData) {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;

                  if (data['status'] == '1') {
                    /*
                  * for promotion purpose
                  * */
                    promotionImage = [];
                    List promotions = data['Promotion'];
                    promotionImage.addAll(promotions
                        .map((jsonObject) => Promotion.fromJson(jsonObject))
                        .toList());

                    return mainContent();
                  } else {
                    Center(child: CircularProgressIndicator());
                  }
                }
              }
              return Center(child: CircularProgressIndicator());
            }),
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
      ),
    );
  }

  Widget mainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        promotionList(),
      ],
    );
  }

  Widget promotionList() {
    return promotionImage.length > 0 ?  Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (c, i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton(
              onPressed:(){
                if( promotionImage[i].checklinktype == "product"){
                  navigateToNextActivity(context, promotionImage[i].productid);
                }else{
                  _launchYoutubeVideo(promotionImage[i].youtubelink);
                }
              },
              child: Card(
                  elevation: 3,
                  color: Colors.white,
                  child: Column(
                    children: [
                      new Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(promotionlink + promotionImage[i].link)),
                      new Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(promotionImage[i].name,
                                style: Theme.of(context).textTheme.title),
                            // Text(promotionImage[i].remark),
                            ExpandableText(
                              "${promotionImage[i].remark}",
                              maxLines: 1,
                              linkColor: Colors.pink,
                              expandText: 'Show more',
                              collapseText: 'Show less',
                            ),
                          ],
                        ),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  )),
            ),
          ],
        ),
        itemCount: promotionImage.length,
      ),
    ) : Center(
    child: Text("No Promotion"),
    );
  }

  List<int> countLength() {
    List<int> length = [];
    for (int i = 0; i < promotionImage.length; i++) {
      length.add(i);
    }
    return length;
  }

  Widget newProduct() {
    return Row(
      children: <Widget>[
        Container(child: Text("product1")),
        Container(child: Text("product2")),
        Container(child: Text("product3")),
      ],
    );
  }

  Widget notificationSide() {
    return Row(
      children: <Widget>[
        Container(child: Text("notice 1")),
        Container(child: Text("notice 2")),
        Container(child: Text("notice 3")),
      ],
    );
  }

  void getlog() async {
    dynamic dealerid = FlutterSession().get("dealerid");
    //print("testing: "+_deviceData.toString());
    return await Domain.callApi(Domain.getdealerinfo,
        {'create': '1', 'action': "Logout", 'dealerid': dealerid.toString()});
  }

  Future<void> _launchYoutubeVideo(String _youtubeUrl) async {
    if (_youtubeUrl != null && _youtubeUrl.isNotEmpty) {
      if (await canLaunch(_youtubeUrl)) {
        final bool _nativeAppLaunchSucceeded = await launch(
          _youtubeUrl,
          forceSafariVC: false,
          universalLinksOnly: true,
        );
        if (!_nativeAppLaunchSucceeded) {
          await launch(_youtubeUrl, forceSafariVC: true);
        }
      }
    }
  }
}
