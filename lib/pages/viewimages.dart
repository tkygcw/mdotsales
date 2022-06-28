import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mdotorder/domain/domain.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../object/product_image.dart';

class ViewImages extends StatefulWidget {
  final String id;

  ViewImages({this.id});

  @override
  State<ViewImages> createState() => _ViewImagesState();
}

class _ViewImagesState extends State<ViewImages> {
  List<ProductImage> productImage = [];


  Future fetchSlider() async {
    Map data = await Domain.callApi(Domain.getproduct, {
      'view_product_all_banner': '1',
      'product_id': widget.id,
    });

    productImage = [];
    if (data['product_banner'] != false) {
      List sliders = data['product_banner'];
      productImage.addAll(sliders
          .map((jsonObject) => ProductImage.fromJson(jsonObject))
          .toList());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
      body: mainContent(),
    );
  }

  Widget mainContent(){
    fetchSlider();
    return productImage.length > 0
        ? Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(imglink + productImage[index].productLocate),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: productImage[index].id),
            );
          },
          itemCount: productImage.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        )
    )
        : Container(
      height: 220,
      child: Image.asset('assets/noimg.jpg'),
    );
  }
}
