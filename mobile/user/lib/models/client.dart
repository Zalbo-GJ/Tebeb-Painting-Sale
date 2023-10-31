class Client {
  String id;
  String name;
  String email;
  String role;
  List<String> paintingIdList;
  List<String> soldPaintingIdList;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.paintingIdList,
    required this.soldPaintingIdList,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      paintingIdList: List<String>.from(json['paintingIdList'] as List<dynamic>),
      soldPaintingIdList: List<String>.from(json['soldPaintingIdList'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'paintingIdList': paintingIdList,
      'soldPaintingIdList': soldPaintingIdList,
    };
  }
}