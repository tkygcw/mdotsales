class Status {
  int id, dealerid, driverid, status, urgent, identify;
  String deliverycode, pickupgps, remark, picture, name, note, signature, type;

  Status({
    this.id,
    this.deliverycode,
    this.driverid,
    this.pickupgps,
    this.remark,
    this.status,
    this.dealerid,
    this.picture,
    this.name,
    this.urgent,
    this.note,
    this.identify,
    this.signature,
    this.type
  });

  static double checkDouble(num value) {
    try {
      return value is double ? value : value.toDouble();
    } catch ($e) {
      return 0.00;
    }
  }

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
        id: json['delivery_id'],
        deliverycode: json['deliverycode'],
        driverid: json['pick_up_driver'],
        pickupgps: json["pick_up_gps"],
        remark: json["remark"],
        status: json["status"],
        dealerid: json["dealerid"],
        picture: json["picture_record"],
        name: json["name"],
        urgent: json["urgent"],
        note: json["note"],
        identify: json["identify"],
        signature: json["signature"],
        type: json["type"]
    );
  }
}