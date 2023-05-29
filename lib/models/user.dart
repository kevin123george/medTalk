enum UserType {
  Doctor,
  Patient, defaultValue,
}

class User {
  int? id;
  String name;
  String? email;
  String? address;
  UserType userType;

  User({
    this.id,
    required this.name,
    this.email,
    this.address,
    this.userType = UserType.Patient,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'userType': userType.toString(),
    };
  }
}