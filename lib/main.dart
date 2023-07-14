// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:medTalk/providers/language_provider.dart';
import 'package:medTalk/screens/splash_screen.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/records.dart';
import 'screens/home.dart';

void main() async {
  await GetStorage.init();
  final logger = Logger();

  // Assuming you have a list of Records called "records"
  try {
    logger.i("deleting older records ");
    final List<Records> fetchedRecords = await DatabaseHelper.fetchAllRecords();
    if(fetchedRecords.length > 0  ){
      DatabaseHelper().deleteOlderThanSixMonths(fetchedRecords);
    }
    logger.i("deleted older records ");
  } catch (e) {
    logger.e("unable to delete older records ");
  }
  // Call your function here after initializing GetStorage
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FontProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  late ThemeMode themeMode;
  late ColorSeed colorSelected;
  ColorImageProvider imageSelected = ColorImageProvider.leaves;
  ColorScheme? imageColorScheme = const ColorScheme.light();
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed;

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
    storeBrightnessChange(useLightMode);
  }

  void storeBrightnessChange(bool useLightMode) {
    if(useLightMode){
      GetStorage().write('themeMode', 'light');
    }else{
      GetStorage().write('themeMode', 'dark');
    }
  }

  ThemeMode getThemeModeFromStorage(){
    String theme = GetStorage().read('themeMode') != null
        ?  GetStorage().read('themeMode') : 'system';
    if(theme == 'light'){
      return ThemeMode.light;
    }
    if(theme == 'dark'){
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  void handleMaterialVersionChange() {
    setState(() {
      useMaterial3 = !useMaterial3;
    });
  }

  int getColorFromStorage(){
    return GetStorage().read('colorSeed') != null
        ?  GetStorage().read('colorSeed') : 0;
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;
      colorSelected = ColorSeed.values[value];
    });
    storeColorChange(value);
  }

  void storeColorChange(value){
    GetStorage().write('colorSeed', value);
  }

  void handleImageSelect(int value) {
    final String url = ColorImageProvider.values[value].url;
    ColorScheme.fromImageProvider(provider: NetworkImage(url))
        .then((newScheme) {
      setState(() {
        colorSelectionMethod = ColorSelectionMethod.image;
        imageSelected = ColorImageProvider.values[value];
        imageColorScheme = newScheme;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    themeMode = getThemeModeFromStorage();
    colorSelected = ColorSeed.values[getColorFromStorage()];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedTalk',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color
            : null,
        colorScheme: colorSelectionMethod == ColorSelectionMethod.image
            ? imageColorScheme
            : null,
        useMaterial3: useMaterial3,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color
            : imageColorScheme!.primary,
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(themeMode: themeMode),
        '/home': (context) => Home(
          useLightMode: useLightMode,
          useMaterial3: useMaterial3,
          colorSelected: colorSelected,
          imageSelected: imageSelected,
          handleBrightnessChange: handleBrightnessChange,
          handleMaterialVersionChange: handleMaterialVersionChange,
          handleColorSelect: handleColorSelect,
          handleImageSelect: handleImageSelect,
          colorSelectionMethod: colorSelectionMethod,
        ),
      },
    );
  }
}
