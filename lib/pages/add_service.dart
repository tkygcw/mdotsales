import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;

import '../domain/domain.dart';

//alright done
class AddService extends StatefulWidget {
  final String idHolder;

  AddService({this.idHolder});

  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final key = new GlobalKey<ScaffoldState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  //image part
  File _image;
  var imagePath;
  ImageProvider provider;

  final picker = ImagePicker();
  var compressedFileSource;

  @override
  Widget build(BuildContext context) {

    bool _dataValidation(){
      if(nameController.text.trim()==''){
        _showSnackBar("Issue can not be empty");
        return false;
      }else if(detailController.text.trim()==''){
        _showSnackBar("Detail can not be empty");
        return false;
      }
      return true;
    }

    return Scaffold(
      key: key,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30,),
          padding: compressedFileSource != null ? const EdgeInsets.only(left: 20,right: 20) : const EdgeInsets.only(left: 20,right: 20, bottom: 350),
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                "assets/addtask.jpg"
              )
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              compressedFileSource != null ? const SizedBox(height: 40,) : const SizedBox(height: 250,),
              Container(
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context,true);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                  )
                ),
              ),
              Column(
                children: [
                  new TextField(
                    maxLines: 1,
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFedf0f8),
                      hintText: "Issue",
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  new TextField(
                    maxLines: 3,
                    controller: detailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFedf0f8),
                      hintText: "Detail/Remark",
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Stack(fit: StackFit.passthrough, children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: compressedFileSource != null
                          ? Image.memory(
                        compressedFileSource,
                        width: double.infinity,
                      )
                          : Container(),
                    ),
                    Visibility(
                      visible: compressedFileSource != null,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(5),
                          height: 150,
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red[200],
                            ),
                            onPressed: clearImage,
                          )),
                    ),
                  ]),
                  SizedBox(height: 10,),
                ],
              ),
            ],
          ),
        ),
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
              InkWell(
                onTap: (){
                  _showSelectionDialog(context);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 20,
                      bottom: 20,
                      left: 20,
                      right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        20),
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  if(_dataValidation()){
                    addCase(nameController.text, detailController.text, widget.idHolder);
                  }
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: Center(
                    child: Text("Add",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueGrey,
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }

  void addCase(String issue, String detail, String protectionid) async {

    Map data = await Domain.callApi(Domain.getprotection, {
      'create': '1',
      'protectionid': protectionid,
      'reason': issue,
      'detail': detail,
      'type': "cus",
      'image': compressedFileSource != null
          ? base64Encode(compressedFileSource).toString()
          : '',
    });

    if(data["status"]=="1"){
      await Domain.callSpecialApi(Domain.sendtoleader, {
        "title": "Dealer Requestment",
        "body": "There is a new case. Please arrange a technician to fix it.",
        "protectionid": protectionid,
      });

      await Domain.callSpecialApi(Domain.sendtomaster, {
        "title": "Dealer Requestment",
        "body": "There is a new case. Please arrange a technician to fix it.",
        "protectionid": protectionid,
      });

      showalert();
      Navigator.pop(context,true);
    }else{
      _showSnackBar("Submit failed! Please try again.");
    }
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit Successfully."),
          content: Text("You have submit case successfully."),
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

  clearImage() {
    setState(() {
      compressedFileSource = null;
    });
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
                        getImage(false);
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
                        getImage(true);
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

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    imagePath = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // compressFileMethod();
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = (await ImageCropper().cropImage(
        sourcePath: imagePath.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )));
    if (croppedFile != null) {
      _image = croppedFile;
      compressFileMethod();
    }
  }

  void compressFileMethod() async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    compressedFileSource = await compressFile(file);
    setState(() {});
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<Uint8List> compressFile(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    return result;
  }

  countQuality(int quality) {
    if (quality <= 100)
      return 60;
    else if (quality > 100 && quality < 500)
      return 25;
    else
      return 20;
  }
}
