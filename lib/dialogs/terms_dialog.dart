import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:medTalk/dialogs/policy_dialog.dart';
import 'package:medTalk/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsDialog extends StatefulWidget {
  TermsDialog({
    this.radius = 8,
  });

  final double radius;

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  late String mdFileName;

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = context.watch<LanguageProvider>();
    Map<String, String> language = languageProvider.languageMap;
    mdFileName = language['mdFileName']!;
    return WillPopScope(
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.radius)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    icon: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    tooltip: language['language_tooltip'],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    itemBuilder: (context) {
                      return List.generate(languageProvider.languageList.length,
                          (index) {
                        return PopupMenuItem(
                          value: languageProvider.languageList[index],
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child:
                                    Text(languageProvider.languageList[index]),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    onSelected: (value) {
                      setState(() {
                        context.read<LanguageProvider>().change_language(value);
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future:
                      Future.delayed(Duration(milliseconds: 150)).then((value) {
                    return rootBundle.loadString('assets/' + mdFileName);
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Markdown(
                        data: snapshot.requireData,
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          SystemNavigator.pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(widget.radius),
                              bottomRight: Radius.circular(widget.radius),
                            ),
                          ),
                          alignment: Alignment.center,
                          height: 50,
                          width: double.infinity,
                          child: Text(
                            language['decline']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('termsPreference', true);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(widget.radius),
                              bottomRight: Radius.circular(widget.radius),
                            ),
                          ),
                          alignment: Alignment.center,
                          height: 50,
                          width: double.infinity,
                          child: Text(
                            language['accept']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              // color: Theme.of(context).textTheme.button.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        onWillPop: () async => false);
  }
}
