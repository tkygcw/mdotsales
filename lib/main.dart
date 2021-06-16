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

void main() => runApp(MaterialApp(
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