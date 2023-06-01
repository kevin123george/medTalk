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
  final _profileUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String dropdownvalue = 'Select';

  // List of items in our dropdown menu
  var items = [
    'Select',
    'Patient',
    'Doctor',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/727/727399.png?w=740&t=st=1685613822~exp=1685614422~hmac=1ce2ebe58c69cdeb7239355ef9a5ed555e21343888c887db3886afddcc292a45"),
                    radius: 110,
                  ),
                ),
              ),
              TextFormField(
                controller: _profileUrlController,
                decoration: InputDecoration(
                  labelText: 'Profil-URL',
                  hintText: 'Geben Sie Ihre Profil-URL ein',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihre Profil-URL ein';
                  }
                  return null;
                },
              ),
              Container(
                width: 300,
                height: 65,
                child: DropdownButton(
                  // Initial Value

                  value: dropdownvalue,
                  underline: Container(
                    height: 1,
                    color: Colors.black54, //<-- SEE HERE
                  ),
                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),

                  // Array list of items
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(
                        items,
                        // style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                    });
                  },
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
                    print(
                        'Name: ${_nameController.text}, Email: ${_emailController.text}, Address: ${_addressController.text}');
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
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
