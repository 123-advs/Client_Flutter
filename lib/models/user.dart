import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String mobile;
  final String password;
  final String confirmationCode;
  final String images;
  final List<String> topicSaved;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.mobile,
    required this.password,
    required this.confirmationCode,
    required this.images,
    required this.topicSaved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] != null ? json['_id'] as String : '',
      firstname: json['firstname'] != null ? json['firstname'] as String : '',
      lastname: json['lastname'] != null ? json['lastname'] as String : '',
      email: json['email'] != null ? json['email'] as String : '',
      mobile: json['mobile'] != null ? json['mobile'] as String : '',
      password: json['password'] != null ? json['password'] as String : '',
      confirmationCode: json['confirmationCode'] != null
          ? json['confirmationCode'] as String
          : '',
      images: json['images'] != null ? json['images'] as String : '',
      topicSaved: json['topicSaved'] != null
          ? List<String>.from(json['topicSaved'] as List<dynamic>)
          : [],
    );
  }

  factory User.randomId({
    required String firstname,
    required String lastname,
    required String email,
    required String mobile,
    required String password,
    required String confirmationCode,
    required String images,
    required List<String> topicSaved,
  }) {
    String id = Uuid().v4();
    return User(
      id: id,
      firstname: firstname,
      lastname: lastname,
      email: email,
      mobile: mobile,
      password: password,
      confirmationCode: confirmationCode,
      images: images,
      topicSaved: topicSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'mobile': mobile,
      'password': password,
      'confirmationCode': confirmationCode,
      'images': images,
      'topicSaved': topicSaved,
    };
  }

  @override
  String toString() {
    return 'User { id: $id, firstname: $firstname, lastname: $lastname, email: $email, mobile: $mobile, password: $password, images: $images, topicSaved: $topicSaved }';
  }
}
