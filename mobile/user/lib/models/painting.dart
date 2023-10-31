
class Painting {
  String? id;
  String? name;
  String? artist;
  double? width;
  double? height;
  bool? sold;
  DateTime? date;
  String? description;


  Painting({
    this.id,
    this.name,
   this.artist,
   this.width,
   this.height,
   this.sold,
   this.date,
   this.description});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'width': width,
      'height': height,
      'sold': sold,
      'date': date?.toIso8601String(),
      'description': description,
    };
  }

  factory Painting.fromJson(Map<String, dynamic> json) {
    return Painting(
      id: json['id'] as String,
      name: json['name'] as String,
      artist: json['artist'] as String,
      width: json['width'] as double,
      height: json['height'] as double,
      sold: json['sold'] as bool,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    );
  }
}
