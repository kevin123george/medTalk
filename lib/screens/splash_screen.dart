import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  final ThemeMode themeMode;

  SplashScreen({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    ScreenUtil.init(context,
        designSize: Size(750, 1334));

    double aspectRatio = ScreenUtil().screenWidth / ScreenUtil().screenHeight;
    print('------------------->' + themeMode.toString());
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    String imagePath = '';
    if(themeMode == ThemeMode.dark){
      if (isLandscape) {
        if (aspectRatio <= 4 / 3) {
          imagePath = 'assets/images/4_3_landscape_dark.png';
        } else if (aspectRatio <= 3 / 2) {
          imagePath = 'assets/images/3_2_landscape_dark.png';
        } else if (aspectRatio <= 8 / 5) {
          imagePath = 'assets/images/8_5_landscape_dark.png';
        } else if (aspectRatio <= 5 / 3) {
          imagePath = 'assets/images/5_3_landscape_dark.png';
        } else if (aspectRatio <= 16 / 9) {
          imagePath = 'assets/images/16_9_landscape_dark.png';
        } else {
          imagePath = 'assets/images/19.5_9_landscape_dark.png';
        }
      } else {
        if (aspectRatio <= 10 / 19) {
          imagePath = 'assets/images/19.5_9_portrait_dark.png';
        } else if (aspectRatio <= 9 / 16) {
          imagePath = 'assets/images/16_9_portrait_dark.png';
        } else if (aspectRatio <= 3 / 5) {
          imagePath = 'assets/images/5_3_portrait_dark.png';
        } else if (aspectRatio <= 5 / 8) {
          imagePath = 'assets/images/8_5_portrait_dark.png';
        } else if (aspectRatio <= 2 / 3) {
          imagePath = 'assets/images/3_2_portrait_dark.png';
        } else {
          imagePath = 'assets/images/4_3_portrait_dark.png';
        }
      }
    }else{
      if (isLandscape) {
        if (aspectRatio <= 4 / 3) {
          imagePath = 'assets/images/4_3_landscape.png';
        } else if (aspectRatio <= 3 / 2) {
          imagePath = 'assets/images/3_2_landscape.png';
        } else if (aspectRatio <= 8 / 5) {
          imagePath = 'assets/images/8_5_landscape.png';
        } else if (aspectRatio <= 5 / 3) {
          imagePath = 'assets/images/5_3_landscape.png';
        } else if (aspectRatio <= 16 / 9) {
          imagePath = 'assets/images/16_9_landscape.png';
        } else {
          imagePath = 'assets/images/19.5_9_landscape.png';
        }
      } else {
        if (aspectRatio <= 10 / 19) {
          imagePath = 'assets/images/19.5_9_portrait.png';
        } else if (aspectRatio <= 9 / 16) {
          imagePath = 'assets/images/16_9_portrait.png';
        } else if (aspectRatio <= 3 / 5) {
          imagePath = 'assets/images/5_3_portrait.png';
        } else if (aspectRatio <= 5 / 8) {
          imagePath = 'assets/images/8_5_portrait.png';
        } else if (aspectRatio <= 2 / 3) {
          imagePath = 'assets/images/3_2_portrait.png';
        } else {
          imagePath = 'assets/images/4_3_portrait.png';
        }
      }
    }


    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

