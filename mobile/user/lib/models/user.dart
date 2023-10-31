class User {
  String? id;
  String? name;
  String? email;
  String? image;
  String? token;
  String? role;
  List<String>? savedPaintingIdList;
  List<String>? boughtPaintingIdList;

  User({
     this.id,
     this.name,
     this.email,
     this.role,
     this.image,
     this.token,
     this.savedPaintingIdList,
     this.boughtPaintingIdList,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token:json['token'] as String,
      savedPaintingIdList: List<String>.from(json['savedPaintingIdList'] as List<dynamic>),
      boughtPaintingIdList: List<String>.from(json['boughtPaintingIdList'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'savedPaintingIdList': savedPaintingIdList,
      'boughtPaintingIdList': boughtPaintingIdList,
      'image':image,
      'token':token
    };
  }
}