import 'package:flutter/material.dart';
import '../models/user.dart';
import '../util/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
      displayColor: Theme.of(context).colorScheme.onSurface,
    );
    return Expanded(
      child: Scaffold(
        body: Center(
          child: ProfileForm(),
        ),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController;
  late final _emailController;
  late final _addressController;
  late final _profileUrlController;
  late final _userTypeController;
  String dropdownvalue = 'Wählen'; // Declaration of dropdownvalue variable

  // List of items in our dropdown menu
  var items = [
    'Wählen',
    'Patient',
    'Doctor',
  ];
  User? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _profileUrlController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final address = _addressController.text;
      final userType = dropdownvalue == 'Wählen' ? UserType.Patient : _getUserTypeFromValue(dropdownvalue);

      final updatedUser = User(
        id: _user?.id, // Use the existing user's ID for update
        name: name,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
        userType:userType,
      );

      try {
        if (_user == null) {
          // User does not exist, insert as new user
          final generatedId = await DatabaseHelper.insertUser(updatedUser);
          updatedUser.id = generatedId;
        } else {
          // User exists, update the existing user

          await DatabaseHelper.updateUser(updatedUser);
        }

        // Update the user reference
        _user = updatedUser;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Benutzerdaten erfolgreich aktualisiert')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FBenutzerdaten konnten nicht aktualisiert werden')),
        );
      }
    }
  }

  Future<void> _fetchUserData() async {
    _user = await DatabaseHelper.fetchUser();

    // Update the input field values if the user exists
    if (_user != null) {
      _nameController.text = _user!.name ?? '';
      _emailController.text = _user!.email ?? '';
      _addressController.text = _user!.address ?? '';
      setState(() {
        dropdownvalue = _user!.userType.toString().split('.').last;
      });

      // _profileUrlController.text = _user!.profileUrl ?? '';
    }
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegExp = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$',
      );
      if (!emailRegExp.hasMatch(value)) {
        return 'Bitte geben Sie eine gültige E-Mail-Adresse ein';
      }
    }
    return null;
  }
  UserType _getUserTypeFromValue(String value) {
    switch (value) {
      case 'Patient':
        return UserType.Patient;
      case 'Doctor':
        return UserType.Doctor;
      default:
        return UserType.Patient;
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _profileUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 115,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: Center(
                child: CircleAvatar(
                  foregroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/727/727399.png?w=740&t=st=1685613822~exp=1685614422~hmac=1ce2ebe58c69cdeb7239355ef9a5ed555e21343888c887db3886afddcc292a45"),
                  radius: 110,
                ),
              ),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ihre Name',
                hintText: 'Gib deinen Namen ein',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie Ihren Namen ein';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Geben sie ihre E-Mailadresse ein',
              ),
              validator: _validateEmail,
            ),
            SizedBox(height: 10),
            Container(
              height: 120,
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Geben Sie Ihre Adresse ein',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 300,
              height: 65,
              child: DropdownButton<String>(
                value: dropdownvalue,
                underline: Container(
                  height: 1,
                  color: Colors.black54,
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Aktualisieren'),
            ),
          ],
        ),
      ),
    );
  }
}
