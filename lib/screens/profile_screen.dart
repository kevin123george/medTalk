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
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
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

  User? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final address = _addressController.text;
      final updatedUser = User(
        id: _user?.id, // Use the existing user's ID for update
        name: name,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
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
          SnackBar(content: Text('Benutzerdaten konnten nicht aktualisiert werden')),
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
    }
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
      if (!emailRegExp.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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


