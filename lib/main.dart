import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mdotorder/pages/Login.dart';
import 'package:mdotorder/pages/Home.dart';
import 'package:mdotorder/pages/Personalprofile.dart';
import 'package:mdotorder/pages/Mainpage.dart';
import 'package:mdotorder/pages/Product.dart';
import 'package:mdotorder/pages/Product_detail.dart';
import 'package:mdotorder/pages/Statusinfo.dart';
import 'package:mdotorder/pages/Branddetail.dart';
import 'package:mdotorder/pages/Productfilter.dart';
import 'package:mdotorder/pages/Cart.dart';
import 'package:mdotorder/pages/Editprofile.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',

    routes: {
      '/': (context) => Login(),
      '/Home': (context) => MyBottomNavigationBar(),
      '/product': (context) => productpage(),
      '/Personalprofile': (context) => PersonalProfile(),
      '/Mainpage': (context) => IndexPage(),
      '/statusinfo': (context) => statusinfo(),
      '/brand_detail': (context) => branddetail(),
      '/productfilter': (context) => ProductFilter(),
      '/productdetail': (context) => ProductDetail(),
      '/cart': (context) => Cart(),
      '/editprofile': (context) => EditProfile(),
    },

  ));
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


