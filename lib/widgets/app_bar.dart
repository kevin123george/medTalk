import 'package:flutter/material.dart';
import '../models/models.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  String selectedLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(31, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.stacked_bar_chart),
            const SizedBox(width: 23.5),
            Expanded(
              child: AppBar(
                centerTitle: false,
                title: const Text(
                  'MedTalk',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        print("-----------------");
                        selectedLanguage = 'EN';
                        print(selectedLanguage);
                      });
                    },
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        color: selectedLanguage == 'EN'
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    child: const Text('EN'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedLanguage = 'DE';
                        print(selectedLanguage);
                      });
                    },
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        color: selectedLanguage == 'DE'
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    child: const Text('DE'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'EN',
                        child: Text('Option 1'),
                      ),
                      PopupMenuItem<String>(
                        value: 'DE',
                        child: Text('Option 2'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(widget.currentUser.avatarUrl),
            ),
          ],
        ),
      ),
    );
  }
}