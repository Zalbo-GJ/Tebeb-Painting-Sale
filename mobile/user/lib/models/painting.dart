import 'dart:convert';

class Painting {
  String? id;
  String? name;
  String? imageLink;
  String? imageId;
  String? clientId;
  double? width;
  double? height;
  Genre? genre;
  Type? type;
  bool? sold;
  DateTime? dateAdded;
  String? description;
  int? likes;

  Painting({
    this.id,
    this.name,
    this.imageLink,
    this.imageId,
    this.clientId,
    this.width,
    this.height,
    this.genre,
    this.type,
    this.sold,
    this.dateAdded,
    this.description,
    this.likes,
  });

  factory Painting.fromJson(Map<String, dynamic> json) {
    return Painting(
      id: json['id'],
      name: json['name'],
      imageLink: json['imageLink'],
      imageId: json['imageId'],
      clientId: json['clientId'],
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      genre: genreValues.map?[json['genre']],
      type: typeValues.map?[json['type']],
      sold: json['sold'],
      dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : null,
      description: json['description'],
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageLink': imageLink,
      'imageId': imageId,
      'clientId': clientId,
      'width': width,
      'height': height,
      'genre': genreValues.reverse?[genre],
      'type': typeValues.reverse?[type],
      'sold': sold,
      'dateAdded': dateAdded?.toString(),
      'description': description,
      'likes': likes,
    };
  }
}

enum Genre { LANDSCAPE, PORTRAIT, ABSTRACT, STILL_LIFE, IMPRESSIONISM, REALISM, MODERN, CONTEMPORARY, SURREALISM }

final genreValues = EnumValues({
  'LANDSCAPE': Genre.LANDSCAPE,
  'PORTRAIT': Genre.PORTRAIT,
  'ABSTRACT': Genre.ABSTRACT,
  'STILL_LIFE': Genre.STILL_LIFE,
  'IMPRESSIONISM': Genre.IMPRESSIONISM,
  'REALISM': Genre.REALISM,
  'MODERN': Genre.MODERN,
  'CONTEMPORARY': Genre.CONTEMPORARY,
  'SURREALISM': Genre.SURREALISM,
});

enum Type { OIL, WATERCOLOR, ACRYLIC, PASTEL, CHARCOAL, INK, MIXED_MEDIA }

final typeValues = EnumValues({
  'OIL': Type.OIL,
  'WATERCOLOR': Type.WATERCOLOR,
  'ACRYLIC': Type.ACRYLIC,
  'PASTEL': Type.PASTEL,
  'CHARCOAL': Type.CHARCOAL,
  'INK': Type.INK,
  'MIXED_MEDIA': Type.MIXED_MEDIA,
});

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    reverseMap ??= map!.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}