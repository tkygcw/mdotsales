class Dealer {
  int id, levelid, verified;
  String name,
      phone,
      personname,
      email,
      address,
      postcode,
      city,
      state,
      country,
      picture,
      companyname;

  Dealer(
      {this.id,
        this.name,
        this.phone,
        this.levelid,
        this.personname,
        this.email,
        this.address,
        this.city,
        this.country,
        this.postcode,
        this.state,
        this.picture,
        this.verified,
        this.companyname});

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
        id: json['dealer_id'],
        name: json['name'],
        phone: json['phone'],
        levelid: json["level_id"],
        personname: json["person_in_charge"],
        email: json["email"],
        address: json["address1"],
        city: json["city"],
        country: json["country"],
        postcode: json["postcode"],
        state: json["state"],
        picture: json["picture"],
        verified: json["verified"],
        companyname: json["companyname"]);
  }
}
