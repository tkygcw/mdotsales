class Protection {
  int id,havcase,maintainid;
  String serialnumber,name,startingdate,expireddate,picture,customername,address,postcode,city,state,country,phone,email,created_at;

  Protection({
    this.id,
    this.maintainid,
    this.havcase,
    this.serialnumber,
    this.name,
    this.startingdate,
    this.expireddate,
    this.picture,
    this.customername,
    this.state,
    this.city,
    this.country,
    this.address,
    this.phone,
    this.postcode,
    this.email,
    this.created_at
  });

  factory Protection.fromJson(Map<String, dynamic> json) {
    return Protection(
      id: json['protection_id'],
      maintainid: json['maintain_id'],
      havcase: json['numbercase'],
      serialnumber: json['serial_number'],
      name: json['name'],
      startingdate: json["starting_date"],
      expireddate: json["expired_date"],
      picture: json["product_locate"],
      customername: json["customername"],
      address: json["address"],
      postcode: json["postcode"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      phone: json["phone"],
      email: json["email"],
      created_at: json["created_at"],
    );
  }
}
