import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/object/dealer.dart';
import 'package:mdotorder/object/driver.dart';
import 'package:mdotorder/pages/home.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:mdotorder/domain/domain.dart';
import 'package:signature/signature.dart';

class ReturnProductPage extends StatefulWidget {
  @override
  _ReturnProductPageState createState() => _ReturnProductPageState();
}

class _ReturnProductPageState extends State<ReturnProductPage> {
  final key = new GlobalKey<ScaffoldState>();
  List<Driver> driver = [];
  List<Dealer> dealer = [];
  TextEditingController noteController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  //Signature Part
  final SignatureController _signcontroller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  //QR Code Part
  String qrCodeDriver = "Not Yet Scanned";
  bool checkqrCode = false;

  //image part
  File _image;
  var imagePath;
  ImageProvider provider;

  //final picker = ImagePicker();
  var compressedFileSource;

  Future fetchDealer() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");
    //print("session: " + getdealerid.toString());
    Map data = await Domain.callApi(Domain.getdealerinfo,
        {'reading': '1', 'dealerid': getdealerid.toString()});

    dealer = [];
    if (data['status'] == '1') {
      List responseJson = data['Driver'];

      dealer.addAll(responseJson.map((e) => Dealer.fromJson(e)));
    } else {
      _showSnackBar("Catch failed in driver info.");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchDealer();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: AppBar(
          backgroundColor: Colors.blueGrey[400], title: Text('Return Product')),
      body: mainContent(),
    );
  }

  Widget mainContent() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [imageWidget()],
        ),
      ),
    );
  }

  Widget imageWidget() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.all(15),
                child: Text("Document Code:",
                    style: TextStyle(color: Colors.black, fontSize: 24))),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Document Code",
              ),
            ),
            Container(
                padding: EdgeInsets.all(15),
                child: Text("Remark",
                    style: TextStyle(color: Colors.black, fontSize: 20))),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: noteController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Remark",
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey[800])),
              child: FlatButton(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text("Scan Driver QR Code :"),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "${qrCodeDriver}",
                              style: TextStyle(
                                  color: qrCodeDriver != ""
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_camera_outlined),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Text("Open Scanner"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  String cameraScanResult = await BarcodeScanner.scan();
                  catchDealer(cameraScanResult);
                },
              ),
            ),
            // Column(
            //   children: [
            //     Container(
            //       margin: const EdgeInsets.only(top: 15.0, left: 15.0),
            //       alignment: Alignment.centerLeft,
            //       child: Text("Sign here..."),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.all(15.0),
            //       decoration: BoxDecoration(
            //           border: Border.all(color: Colors.blueGrey[800])),
            //       child: Signature(
            //         //width: double.infinity,
            //         controller: _signcontroller,
            //         height: 200,
            //       ),
            //     ),
            //     Container(
            //       child: IconButton(
            //         icon: const Icon(Icons.refresh),
            //         color: Colors.blue,
            //         onPressed: () {
            //           setState(() => _signcontroller.clear());
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    padding: EdgeInsets.all(15.0),
                    color: Colors.blueGrey[800],
                    onPressed: () {
                      showalert();
                    },
                    child: Text(
                      "Submit the Result",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  clearImage() {
    setState(() {
      compressedFileSource = null;
    });
  }

  /*-------------------------------Submit Delivery Info---------------------------------------------------*/
  void addDelivery(driverid, checkscanner) async {
    final Uint8List setSignature = await _signcontroller.toPngBytes();
    //print("deliverycode: "+codeController.text+" remark: "+noteController.text);

      dynamic getdealer = await FlutterSession().get("dealerid");
      Map data = await Domain.callApi(Domain.getdelivery, {
        'adddelivery': '1',
        'deliverycode': codeController.text.toString(),
        'dealerid': getdealer.toString(),
        'driverid': checkscanner==true ? driverid : '0',
        'remark': noteController.text.toString(),
        'creater': dealer[0].name,
      });

      if (data['status'] == '1') {
        //completed submit
        _showSnackBar("Submit successfully.");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ));
      }
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit the delivery"),
          content: Text("Are you sure to return the product?"),
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
                addDelivery(qrCodeDriver, checkqrCode);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*-----------------------------------------driver info-------------------------------------------*/
  void catchDealer(driverid) async {
    driver = [];
    Map data = await Domain.callApi(Domain.getdriverinfo, {
      'reading': '1',
      'driverid': driverid,
    });

    if (data['status'] == '1') {
      List getdriver = data['Driver'];
      //print(getdriver);
      driver.addAll(getdriver
          .map((jsonObject) => Driver.fromJson(jsonObject))
          .toList());

      setState(() {
        checkqrCode = true;
        qrCodeDriver=driver[0].name;
      });
    }else{
      setState(() {
        qrCodeDriver="Driver not found";
      });
    }
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Take Photo From"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text('Gallery',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.orangeAccent,
                      icon: Icon(
                        Icons.perm_media,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        //getImage(false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blueAccent,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        //getImage(true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ));
        });
  }

  base64Data(String data) {
    switch (data.length % 4) {
      case 1:
        break;
      case 2:
        data = data + "==";
        break;
      case 3:
        data = data + "=";
        break;
    }
    return data;
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1500),
      content: new Text(message),
    ));
  }

/*
  * compress purpose
  * */
// Future getImage(isCamera) async {
//   imagePath = await picker.getImage(
//       source: isCamera ? ImageSource.camera : ImageSource.gallery);
//   // compressFileMethod();
//   _cropImage();
// }
//
// Future<Null> _cropImage() async {
//   File croppedFile = (await ImageCropper.cropImage(
//       sourcePath: imagePath.path,
//       aspectRatioPresets: Platform.isAndroid
//           ? [
//         CropAspectRatioPreset.square,
//         CropAspectRatioPreset.ratio3x2,
//         CropAspectRatioPreset.original,
//         CropAspectRatioPreset.ratio4x3,
//         CropAspectRatioPreset.ratio16x9
//       ]
//           : [
//         CropAspectRatioPreset.original,
//         CropAspectRatioPreset.square,
//         CropAspectRatioPreset.ratio3x2,
//         CropAspectRatioPreset.ratio4x3,
//         CropAspectRatioPreset.ratio5x3,
//         CropAspectRatioPreset.ratio5x4,
//         CropAspectRatioPreset.ratio7x5,
//         CropAspectRatioPreset.ratio16x9
//       ],
//       androidUiSettings: AndroidUiSettings(
//           toolbarTitle: 'Cropper',
//           toolbarColor: Colors.deepPurple,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false),
//       iosUiSettings: IOSUiSettings(
//         title: 'Cropper',
//       )));
//   if (croppedFile != null) {
//     _image = croppedFile;
//     compressFileMethod();
//   }
// }
//
// void compressFileMethod() async {
//   await Future.delayed(Duration(milliseconds: 300));
//
//   Uint8List bytes = _image.readAsBytesSync();
//   final ByteData data = ByteData.view(bytes.buffer);
//
//   final dir = await path_provider.getTemporaryDirectory();
//
//   File file = createFile("${dir.absolute.path}/test.png");
//   file.writeAsBytesSync(data.buffer.asUint8List());
//   compressedFileSource = await compressFile(file);
//   setState(() {});
// }
//
// File createFile(String path) {
//   final file = File(path);
//   if (!file.existsSync()) {
//     file.createSync(recursive: true);
//   }
//   return file;
// }
//
// Future<Uint8List> compressFile(File file) async {
//   final result = await FlutterImageCompress.compressWithFile(
//     file.absolute.path,
//     quality: countQuality(file.lengthSync()),
//   );
//   return result;
// }
//
// countQuality(int quality) {
//   if (quality <= 100)
//     return 60;
//   else if (quality > 100 && quality < 500)
//     return 25;
//   else
//     return 20;
// }
}
