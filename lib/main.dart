import 'package:flutter/material.dart';

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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video trimer'),
      ),
      body: Center(
        child: Text(
          'Coming soon...',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
