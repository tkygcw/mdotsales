import 'dart:convert';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://mdotservice.com/mdot/testing/';

  static var getproduct = Uri.parse(domain + 'product2/index.php');
  static var getdealerinfo = Uri.parse(domain + 'dealer/index.php');
  static var insertorder = Uri.parse(domain + 'Order/index.php');
  static var getpromotion = Uri.parse(domain + 'promotion/index.php');
  static var getcategory = Uri.parse(domain + 'category/index.php');
  static var getstatus = Uri.parse(domain + 'status/index.php');
  static var getdelivery = Uri.parse(domain + 'delivery/index.php');
  static var getdriverinfo = Uri.parse(domain + 'driver/index.php');
  static var getsystem = Uri.parse(domain + 'system/index.php');
  static var getprotection = Uri.parse(domain + 'protection/index.php');
  static var getmaintain = Uri.parse(domain + 'maintain/index.php');
  static var sendtoleader = Uri.parse('https://mdotservice.com/mdot/sendtoLeader.php');
  static var sendtomaster = Uri.parse('https://mdotservice.com/mdot/sendtoMaster.php');

  static callApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return jsonDecode(response.body);
  }

  static callSpecialApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return response.body.toString();
  }
}
String websitefilelink="https://mdotservice.com/mdot/product/";

String imglink="https://mdotservice.com/mdot/product/product_img/";

String promotionlink="https://mdotservice.com/mdot/promotion/promotion_img/";

String filelink="https://mdotservice.com/mdot/testing/";

String categorylink="https://mdotservice.com/mdot/category/category_img/";

String brandlink="https://mdotservice.com/mdot/brand/brand_img/";

String softwarelink="https://mdotservice.com/mdot/software/softwaredriver/";




