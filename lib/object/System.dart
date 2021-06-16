class System {
  int accessadddelivery;
  String packagename;

  System({this.accessadddelivery, this.packagename});

  factory System.fromJson(Map<String, dynamic> json) {
    return System(
        accessadddelivery: json['access_driver_add_delivery'],
        packagename: json['package_name']);
  }
}
