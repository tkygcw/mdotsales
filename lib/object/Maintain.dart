class Maintain {
  int id,havcase,maintainid,status;
  String serialnumber,name,startingdate,picture,customername,address,postcode,city,state,country,
      phone,email,created_at,image,reason,detail,remark,completed_date,technicianname;

  Maintain({
    this.id,
    this.maintainid,
    this.havcase,
    this.serialnumber,
    this.name,
    this.startingdate,
    this.picture,
    this.customername,
    this.state,
    this.city,
    this.country,
    this.address,
    this.phone,
    this.postcode,
    this.email,
    this.image,
    this.created_at,
    this.detail,
    this.remark,
    this.reason,
    this.completed_date,
    this.technicianname,
    this.status
  });

  factory Maintain.fromJson(Map<String, dynamic> json) {
    return Maintain(
      id: json['protection_id'],
      maintainid: json['maintain_id'],
      havcase: json['numbercase'],
      serialnumber: json['serial_number'],
      name: json['name'],
      startingdate: json["starting_date"],
      picture: json["product_locate"],
      customername: json["customername"],
      address: json["address"],
      postcode: json["postcode"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      phone: json["phone"],
      email: json["email"],
      image: json["file_name"],
      created_at: json["created_at"],
      reason: json["reason"],
      detail: json["detail"],
      remark: json["remark"],
      completed_date: json["completed_date"],
      technicianname: json["technicianname"],
      status: json["status"],
    );
  }
}
