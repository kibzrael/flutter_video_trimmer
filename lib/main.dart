import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_trimmer/home.dart';

void main() {
  runApp(VideoTrimmerApp());
}

class VideoTrimmerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(secondary: Colors.deepOrangeAccent),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder()
        }),
        cardColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 1.0,
            shadowColor: Colors.grey),
      ),
      home: Home(),
    );
  }
}
