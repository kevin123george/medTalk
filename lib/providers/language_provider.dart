import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LanguageProvider with ChangeNotifier {

   String _language = GetStorage().read('language') != null
       ? GetStorage().read('language') : 'German';

   List<String> _languageList = ['German', 'English'];
   Map<String, String> _german = {
     'language': 'Deutsch',
     'language_tooltip': 'Wähle eine Sprache',
     'language_label': 'Sprache',
     'brightness_tooltip': 'Helligkeit umschalten',
     'brightness': 'Helligkeit'  ,
     'color_tooltip': 'Wähle eine Farbe',
     'color': 'Farbe',
     'font_tooltip': 'Wähle eine Schriftgröße',
     'font_size': 'Schriftgröße',
     'font': 'Schrift',
     'font_small': 'Klein',
     'font_medium': 'Mittel',
     'font_large': 'Groß',
     'intro_text': 'Drück den Knopf um die Transkiption zu starten',
     'helper_text': 'Drück den Knopf um die Transkiption zu starten',
     'chat_label': 'Chat',
     'profile_label': 'Profil',
     'records_label': 'Aufzeichnungen',
     'name': 'Ihr Name',
     'name_hint': 'Bitte geben Sie Ihren Namen ein',
     'email': 'Email',
     'email_hint': 'Bitte geben Sie Ihre Email ein',
     'address': 'Adresse',
     'address_hint': 'Bitte geben Sie Ihre Adresse ein',
     'update': 'Aktualisieren',
     'items_select': 'Auswählen',
     'items_patient': 'Patient',
     'items_doctor': 'Doktor'
   };
   Map<String, String> _english = {
     'language': 'English',
     'language_tooltip': 'Choose a language',
     'language_label': 'Language',
     'brightness_tooltip': 'Toggle Brightness',
     'brightness': 'Brightness'  ,
     'color_tooltip': 'Choose a color',
     'color': 'Color',
     'font_tooltip': 'Choose a font size',
     'font_size': 'Font size',
     'font': 'Font ',
     'font_small': 'Small',
     'font_medium': 'Medium',
     'font_large': 'Large',
     'intro_text': 'Push the button to start the transcription',
     'helper_text': 'Push the button to start the transcription',
     'chat_label': 'Chat',
     'profile_label': 'Profile',
     'records_label': 'Records',
     'name': 'Your name',
     'name_hint': 'Please enter your name',
     'email': 'Email',
     'email_hint': 'Please enter your email adress',
     'address': 'Address',
     'address_hint': 'Please enter your address',
     'update': 'Update',
     'items_select': 'Select',
     'items_patient': 'Patient',
     'items_doctor': 'Doctor'

   };

   List<String> get languageList => _languageList;
   Map<String, String> get languageMap => _language == 'English' ? _english : _german;
   bool get language => _language == 'English' ? false : true;

   String? getTranslatedItem(String item) {
     return _language == 'English' ? _english[item] : _german[item];
   }

  void change_language(language) => {
    this._language = language,
    GetStorage().write('language', language),
    notifyListeners()
  };
}