import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../util/db_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  late final _userTypeController;
  String dropdownvalue = 'Patient'; // Declaration of dropdownvalue variable

  // List of items in our dropdown menu
  var items = [
    'Select',
    'Patient',
    'Doctor',
  ];
  User? _user;

  XFile? imgFile;
  final ImagePicker imagePicker = ImagePicker();
  String? profileImagePath;
  String? savedImageFilename;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _userTypeController = TextEditingController();
    _fetchUserData();
  }

  getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path;
        savedImageFilename = path.basename(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _saveImageToLocalPath();

      final name = _nameController.text;
      final email = _emailController.text;
      final address = _addressController.text;
      final userType = dropdownvalue == 'Select'
          ? UserType.Patient
          : _getUserTypeFromValue(dropdownvalue);

      final updatedUser = User(
        id: _user?.id,
        name: name,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
        userType: userType,
        profileImagePath: profileImagePath ?? _user?.profileImagePath,
      );

      try {
        if (_user?.id == null) {
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
    print('Fetched user: $_user'); // Add this line
    if (_user != null) {
      _nameController.text = _user!.name ?? '';
      _emailController.text = _user!.email ?? '';
      _addressController.text = _user!.address ?? '';

      setState(() {
        dropdownvalue = _user!.userType.toString().split('.').last;
        profileImagePath = _user!.profileImagePath;
      });
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

  Future<void> _saveImageToLocalPath() async {
    if (profileImagePath != null) {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = path.join(dir.path, savedImageFilename!);
      final File file = File(profileImagePath!);
      await file.copy(targetPath);
      profileImagePath = targetPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap the form with SingleChildScrollView
      child: SizedBox(
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
                  child: GestureDetector(
                    onTap: () {
                      getImageFromGallery();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.29,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImagePath != null
                              ? FileImage(File(profileImagePath!))
                              : null,
                        ),


                      if (profileImagePath == null)
                          Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width * 0.20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Ihr Name',
                  hintText: 'Geben Sie Ihren Namen ein',
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
                  hintText: 'Geben Sie Ihre E-Mail-Adresse ein',
                ),
                validator: _validateEmail,
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
                onPressed: () {
                  _submitForm();

                },
                child: Text('Aktualisieren'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
