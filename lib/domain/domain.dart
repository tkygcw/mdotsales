import 'dart:convert';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://mdotservice.com/mdot/testing/';

  static var getproduct = domain + 'product2/index.php';
  static var getdealerinfo = domain + 'dealer/index.php';
  static var insertorder = domain + 'Order/index.php';
  static var getpromotion = domain + 'promotion/index.php';
  static var getcategory = domain + 'category/index.php';
  static var getstatus = domain + 'status/index.php';
  static var getdelivery = domain + 'delivery/index.php';
  static var getdriverinfo = domain + 'driver/index.php';
  static var getsystem = domain + 'system/index.php';

  static callApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return jsonDecode(response.body);
  }
}
String websitefilelink="https://mdotservice.com/mdot/product/";

String imglink="https://mdotservice.com/mdot/product/product_img/";

String promotionlink="https://mdotservice.com/mdot/promotion/promotion_img/";

String filelink="https://mdotservice.com/mdot/testing/";

String categorylink="https://mdotservice.com/mdot/category/category_img/";


