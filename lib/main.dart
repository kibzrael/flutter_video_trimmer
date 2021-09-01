import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double videoDuration = 180;

  double maxDuration = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video trimer'),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: kToolbarHeight),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              padding: EdgeInsets.symmetric(horizontal: 45, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // video Thumbnail
                  Container(
                    // height: width / aspect ratio
                    height: (constraints.maxWidth - 90) * (9 / 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).cardColor),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Video Name',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 5),
                        // video duration
                        Text(
                          '3:12',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  // Maximum duration of the video to be trimmed

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set max duration:',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('${maxDuration.ceil()}')
                      ],
                    ),
                  ),
                  Slider.adaptive(
                      value: maxDuration,
                      max: videoDuration,
                      onChanged: (value) {
                        setState(() {
                          maxDuration = value;
                        });
                      }),
                  SizedBox(height: 12),
                  MaterialButton(
                      child: Text('Trim Video'),
                      elevation: 4,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Coming soon...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          backgroundColor: Colors.blue,
                        ));
                      })
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
