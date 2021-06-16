import 'package:mdotorder/pages/Editprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/dealer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PersonalProfile extends StatefulWidget {
  @override
  _PersonalProfileState createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  String name, showlevel;
  List<Dealer> dealer = [];

  //QR Code Part
  String qrData="https://github.com/ChinmayMunje";

  Future fetchDealer() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");
    //print("session: " + getdealerid.toString());
    return await Domain.callApi(Domain.getdealerinfo,
        {'reading': '1', 'dealerid': getdealerid.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Personal Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
        child: FutureBuilder(
            future: fetchDealer(),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    dealer = [];
                    List getdealer = data['Dealer'];

                    dealer.addAll(getdealer
                        .map((jsonObject) => Dealer.fromJson(jsonObject))
                        .toList());

                    if (dealer[0].levelid.toString() == '1') {
                      showlevel = "Gold";
                    } else if (dealer[0].levelid.toString() == '2') {
                      showlevel = "Silver";
                    } else if (dealer[0].levelid.toString() == '3') {
                      showlevel = "Copper";
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
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(dealer[0].picture = null ??
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Gnome-stock_person.svg/1024px-Gnome-stock_person.svg.png'),
              radius: 40,
              backgroundColor: Colors.grey,
            ),
          ),
          Divider(
            height: 60,
            color: Colors.grey[800],
          ),
          Row(
            children: [
              Text(
                'USER NAME: ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
              Text(
                dealer[0].name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'COMPANY NAME: ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
              Text(
                dealer[0].companyname,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'CURRENT VIP:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$showlevel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'PERSON IN CHARGE: ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
              Text(
                dealer[0].personname,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey[800])
            ),
            child: FlatButton(
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Colors.blueGrey[800],
                  ),
                  SizedBox(width: 10),
                  Text(
                    "QR Code",
                    style: TextStyle(
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                showalert(dealer[0].id);
                //String codeSanner = await BarcodeScanner.scan(); //barcode scnne
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Icon(
                Icons.email,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                dealer[0].email,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                dealer[0].phone,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.add_location_alt,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                dealer[0].address +
                    ",\n" +
                    dealer[0].postcode +
                    ", " +
                    dealer[0].city +
                    ",\n" +
                    dealer[0].state +
                    ",\n" +
                    dealer[0].country,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.blueGrey[800],
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditProfile(dealerid: dealer[0].id.toString())),
                      );
                    },
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              /*Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.blueGrey[800],
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Login()),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ]);
  }

  void showalert(dealerid) async {
    qrData = dealerid.toString();

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
}
