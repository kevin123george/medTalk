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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final address = _addressController.text;
      final user = User(
        id: null, // Set to null for auto-generation
        name: name,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
      );

      try {
        int? generatedId;

        if (user.id == null) {
          // Insert new user and retrieve the generated ID
          generatedId = await DatabaseHelper.insertUser(user);

        } else {
          // Update existing user
          await DatabaseHelper.updateUser(user);
        }

        // Assign the generated ID if available
        if (generatedId != null) {
          user.id = generatedId;
        }

        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data updated successfully')),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user data')),
        );
      }
    }
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
                labelText: 'E-mail',
                hintText: 'Geben sie ihre E-Mail Adresse ein',
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 120,
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  hintText: 'Geben Sie Ihre Adresse ein',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

