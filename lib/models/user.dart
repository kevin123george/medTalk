enum UserType {
  Doctor,
  Patient,
  Select,
}

class User {
  int? id;
  String name;
  String? email;
  String? address;
  UserType userType;
  String? profileImagePath;

  User({
    this.id,
    required this.name,
    this.email,
    this.address,
    this.userType = UserType.Patient,
    this.profileImagePath,
  });
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, address: $address, userType: $userType, profileImagePath: $profileImagePath}';
  }
  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'userType': userType.toString().split('.').last,
      'profileImagePath': profileImagePath,
    };
  }

}
