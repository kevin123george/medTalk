import 'package:flutter/material.dart';

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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print('Name: ${_nameController.text}, Email: ${_emailController.text}, Address: ${_addressController.text}');
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
