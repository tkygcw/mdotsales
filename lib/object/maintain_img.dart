class MaintainImage {
  String filename, type;

  MaintainImage({
    this.filename,
    this.type
  });

  factory MaintainImage.fromJson(Map<String, dynamic> json) {
    return MaintainImage(
        filename: json['file_name'],
        type: json['type']
    );
  }
}
