import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:mdotorder/object/dealer.dart';

class EditProfile extends StatefulWidget {
  final String dealerid;

  EditProfile({this.dealerid});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  List<Dealer> dealer = [];
  TextEditingController _editName;
  TextEditingController _editCompanyName;
  TextEditingController _editoldpswd;
  TextEditingController _editnewpswd;
  TextEditingController _editrepeatpswd;
  TextEditingController _editpersonname;
  TextEditingController _editemail;
  TextEditingController _editphone;
  TextEditingController _editaddress;
  TextEditingController _editpostcode;
  TextEditingController _editcity;
  TextEditingController _editstate;
  TextEditingController _editcountry;
  bool checkingvalue = true;

  Future fetchDealer() async {
    dynamic getdealerid = await FlutterSession().get("dealerid");
    return await Domain.callApi(Domain.getdealerinfo,
        {'reading': '1', 'dealerid': getdealerid.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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

                    _editName = TextEditingController(text: dealer[0].name);
                    _editCompanyName = TextEditingController(text: dealer[0].companyname);
                    _editoldpswd = TextEditingController();
                    _editnewpswd = TextEditingController();
                    _editrepeatpswd = TextEditingController();
                    _editpersonname =
                        TextEditingController(text: dealer[0].personname);
                    _editemail = TextEditingController(text: dealer[0].email);
                    _editphone = TextEditingController(
                        text: dealer[0].phone.substring(3));
                    _editaddress =
                        TextEditingController(text: dealer[0].address);
                    _editpostcode =
                        TextEditingController(text: dealer[0].postcode);
                    _editcity = TextEditingController(text: dealer[0].city);
                    _editstate = TextEditingController(text: dealer[0].state);
                    _editcountry =
                        TextEditingController(text: dealer[0].country);

                    return CustomeView();
                  }
                }
              }
              return Center(child: Text("No Data"));
            }),
      ),
    );
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "User: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _editName,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            //labelText: dealer[0].name,
            //hintText: dealer[0].name,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Company: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _editCompanyName,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            //labelText: dealer[0].name,
            //hintText: dealer[0].name,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Person Name: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _editpersonname,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            //hintText: dealer[0].personname,
          ),
        ),
      ],
    );
  }

  Column buildDisplayContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Phone: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("+60"),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: _editphone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              //hintText: dealer[0].phone.substring(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Email: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _editemail,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        //hintText: dealer[0].email,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column buildDisplayPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Old Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editoldpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Enter old password",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "New Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editnewpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Enter new password",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Repeat Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editrepeatpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Repeat new password",
          ),
        ),
      ],
    );
  }

  Column buildDisplayAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Address: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _editaddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            //hintText: dealer[0].address,
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Postcode: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: _editpostcode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          //hintText: dealer[0].postcode,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "City: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: _editcity,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          //hintText: dealer[0].city,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "State: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: _editstate,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          //hintText: dealer[0].state,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Country: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: _editcountry,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          //hintText: dealer[0].country,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget CustomeView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              buildDisplayNameField(),
              buildDisplayContactField(),
              buildDisplayPasswordField(),
              buildDisplayAddressField(),
            ],
          ),
        ),
        RaisedButton(
          color: Colors.blueGrey[400],
          onPressed: () {
            updateProfile();
          },
          child: Text(
            "Update Profile",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,),
          ),
        )
        //Text(widget.dealerid),
      ],
    );
  }

  void updateProfile() async {

    _editnewpswd.text != _editrepeatpswd.text
        ? checkingvalue = false
        : checkingvalue = true;

    if (checkingvalue == true) {
      dynamic getdealerid = await FlutterSession().get("dealerid");
      if (_editnewpswd.text.isEmpty && _editoldpswd.text.isEmpty && _editrepeatpswd.text.isEmpty) {

        Map data = await Domain.callApi(Domain.getdealerinfo, {
          'updatenopswd': '1',
          'dealer_id': getdealerid.toString(),
          'name': _editName.text,
          'companyname': _editCompanyName.text,
          'person_in_charge': _editpersonname.text,
          'email': _editemail.text,
          'phone': _editphone.text,
          'country': _editcountry.text,
          'state': _editstate.text,
          'city': _editcity.text,
          'postcode': _editpostcode.text,
          'address1': _editaddress.text,
        });

        return showalert();
      } else {

        Map data = await Domain.callApi(Domain.getdealerinfo, {
          'check': '1',
          'dealer_id': getdealerid.toString(),
          'password': _editoldpswd.text,
        });
        if(data['status']=="1") {
          await Domain.callApi(Domain.getdealerinfo, {
            'update': '1',
            'dealer_id': getdealerid.toString(),
            'name': _editName.text,
            'companyname': _editCompanyName.text,
            'person_in_charge': _editpersonname.text,
            'email': _editemail.text,
            'phone': _editphone.text,
            'country': _editcountry.text,
            'state': _editstate.text,
            'city': _editcity.text,
            'postcode': _editpostcode.text,
            'address1': _editaddress.text,
            'newpassword': _editnewpswd.text,
          });
          return showalert();
        }else{
          return showpasswordalert();
        }
      }
    }else{
      return showalert();
    }
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: checkingvalue == true ? Text("Update Successfully.") : Text("Update Unsuccessfully."),
          content: checkingvalue == true ? Text(
              "You have changed your personal information successfully.") : Text("Your password and repeat password are incorrect."),
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

  void showpasswordalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error."),
          content: Text("Your password is incorrect."),
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
}
